-- ============================================================================
-- Prompt writing -- helpers for composing Claude Code prompts in Neovim
-- ============================================================================
-- In Claude Code, Ctrl+G opens the prompt you are typing in $EDITOR (this
-- Neovim). This module makes that round trip pleasant:
--
--   1. insert_paths() -- a fuzzy file picker that INSERTS "@relative/path"
--      at the cursor instead of opening the file. Claude Code reads "@path"
--      as a file reference.
--   2. insert_tree_node() -- the same thing from the file explorer: press @
--      on a file or folder to drop its "@relative/path" into the prompt.
--   3. PROMPT MODE -- when Neovim was opened by Ctrl+G, init.lua sets
--      vim.g.claude_prompt. Plugin specs read that flag to leave out the
--      code-only tools (LSP, debugger, tests, formatter, snippets, git
--      signs), and setup() turns the window into a writing surface: insert
--      mode at the end of the prompt, soft-wrapped lines, spell check.
--      The file explorer, fuzzy finder and Yazi all still work.
--
-- To force prompt mode by hand (for testing, or if the automatic detection
-- misses), start Neovim with NVIM_PROMPT_MODE=1 in the environment.
-- ============================================================================

local M = {}

-- Is this Neovim a child of Claude Code? Claude Code sets CLAUDECODE=1 for
-- the programs it starts. As a fallback (Linux only) we walk a few steps up
-- the process tree looking for a process named "claude".
local function launched_by_claude()
  if vim.env.CLAUDECODE == "1" then
    return true
  end
  local pid = vim.uv.os_getppid()
  for _ = 1, 3 do
    local f = io.open("/proc/" .. pid .. "/stat")
    if not f then return false end
    local stat = f:read("*a")
    f:close()
    -- /proc/PID/stat looks like: "1234 (name) S 1200 ..." -- name, then parent.
    local name, ppid = stat:match("%((.*)%) %S+ (%d+)")
    if name == "claude" then return true end
    pid = tonumber(ppid)
    if not pid or pid <= 1 then return false end
  end
  return false
end

-- True when Neovim was started on a Claude Code prompt: launched by Claude
-- Code, with exactly one file, and that file lives in the temp directory
-- (Ctrl+G writes the prompt to a temp file and reads it back when you quit).
function M.is_claude_prompt()
  if vim.env.NVIM_PROMPT_MODE == "1" then
    return true
  end
  if vim.fn.argc() ~= 1 then
    return false
  end
  local file = vim.fs.normalize(vim.fn.fnamemodify(vim.fn.argv(0), ":p"))
  local tmp = vim.fs.normalize(vim.uv.os_tmpdir())
  return vim.startswith(file, tmp .. "/") and launched_by_claude()
end

function M.setup()
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("ClaudePrompt", { clear = true }),
    callback = function()
      if not vim.g.claude_prompt then return end

      -- Prose settings, for this window only.
      vim.opt_local.wrap = true         -- Wrap long lines instead of scrolling sideways
      vim.opt_local.linebreak = true    -- ...and break between words, not mid-word
      vim.opt_local.conceallevel = 0    -- Show markdown symbols (`, *, [ ]) as typed
      -- Spell check: misspelled words get a squiggly underline, nothing more.
      --   z=  suggest fixes      zg  "this word is fine", remember it
      --   ]s / [s  next / previous misspelling      :set nospell  turn it off
      vim.opt_local.spell = true
      vim.opt_local.spelllang = "en_us"

      -- With wrapped lines, make j/k move by SCREEN line so a long paragraph
      -- is not one giant jump. (A count like 5j still moves by real lines.)
      for _, key in ipairs({ "j", "k" }) do
        vim.keymap.set("n", key, function()
          return vim.v.count == 0 and "g" .. key or key
        end, { buffer = true, expr = true, desc = "Move by screen line" })
      end

      -- Jump to the last line and start typing at the end of it.
      -- ("startinsert!" is the same as pressing A.)
      vim.cmd("normal! G")
      vim.cmd("startinsert!")
    end,
    desc = "Set up the window for writing a Claude Code prompt",
  })
end

-- Called from the file explorer (nvim-tree) when you press @ on a node:
-- insert that file or folder as "@relative/path" into the window you were in
-- before the explorer, just after its cursor. Focus stays in the explorer so
-- you can add several in a row; each one is separated by a space.
function M.insert_tree_node()
  local node = require("nvim-tree.api").tree.get_node_under_cursor()
  if not node or not node.absolute_path then return end

  -- winnr("#") is the window you were in before this one.
  local win = vim.fn.win_getid(vim.fn.winnr("#"))
  local buf = win ~= 0 and vim.api.nvim_win_get_buf(win) or nil
  if not buf or win == vim.api.nvim_get_current_win()
      or vim.bo[buf].buftype ~= "" or not vim.bo[buf].modifiable then
    vim.notify("No text window to insert into", vim.log.levels.WARN)
    return
  end

  -- ":." makes the path relative to the working directory.
  local text = "@" .. vim.fn.fnamemodify(node.absolute_path, ":.")
  if node.type == "directory" then
    text = text .. "/"
  end

  local row, col = unpack(vim.api.nvim_win_get_cursor(win))
  local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1]
  if #line > 0 then
    col = col + 1 + vim.str_utf_end(line, col + 1)  -- Just after the cursor
  end
  if col > 0 and not line:sub(col, col):match("%s") then
    text = " " .. text  -- Keep it apart from whatever came before
  end

  vim.api.nvim_buf_set_text(buf, row - 1, col, row - 1, col, { text })
  vim.api.nvim_win_set_cursor(win, { row, col + #text - 1 })
  vim.notify("Inserted " .. vim.trim(text))
end

-- Fuzzy-find files and insert them as "@relative/path" at the cursor.
-- Tab marks several files; Enter inserts them all, separated by spaces.
-- Works from normal mode (text goes after the cursor) and from insert mode
-- (text goes at the cursor, and you stay in insert mode afterwards).
function M.insert_paths()
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  -- Remember WHERE to insert before the picker steals focus.
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local was_insert = vim.fn.mode():sub(1, 1) == "i"
  local row, col = unpack(vim.api.nvim_win_get_cursor(win))
  if not was_insert then
    -- In normal mode the cursor sits ON a character, so insert just after
    -- it. str_utf_end handles multi-byte characters (accents, emoji).
    local line = vim.api.nvim_get_current_line()
    if #line > 0 then
      col = col + 1 + vim.str_utf_end(line, col + 1)
    end
  end

  require("telescope.builtin").find_files({
    prompt_title = "Insert @path",
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        -- Tab-marked files if there are any, otherwise the highlighted one.
        local entries = action_state.get_current_picker(prompt_bufnr):get_multi_selection()
        if #entries == 0 then
          entries = { action_state.get_selected_entry() }
        end
        actions.close(prompt_bufnr)

        local paths = {}
        for _, entry in ipairs(entries) do
          -- ":." makes the path relative to the working directory.
          table.insert(paths, "@" .. vim.fn.fnamemodify(entry.path or entry[1], ":."))
        end
        if #paths == 0 then return end

        local text = table.concat(paths, " ")
        vim.api.nvim_buf_set_text(buf, row - 1, col, row - 1, col, { text })

        -- Leave the cursor on the last inserted character. Telescope drops
        -- back to normal mode as it closes, so if we started in insert mode
        -- we press "a" (append) afterwards to carry on typing after the path.
        vim.schedule(function()
          vim.api.nvim_win_set_cursor(win, { row, col + #text - 1 })
          if was_insert then
            vim.api.nvim_feedkeys("a", "n", false)
          end
        end)
      end)
      return true  -- Keep every other default Telescope mapping
    end,
  })
end

return M
