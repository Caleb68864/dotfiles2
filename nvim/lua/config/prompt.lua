-- ============================================================================
-- Prompt writing -- helpers for composing Claude Code prompts in Neovim
-- ============================================================================
-- In Claude Code, Ctrl+G opens the prompt you are typing in $EDITOR (this
-- Neovim). This module makes that round trip pleasant:
--
--   1. insert_paths() -- a fuzzy file picker that INSERTS "@relative/path"
--      at the cursor instead of opening the file. Claude Code reads "@path"
--      as a file reference.
--   2. setup() -- when Neovim was opened by Ctrl+G, start in insert mode at
--      the end of the prompt so you can type immediately.
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
      if not M.is_claude_prompt() then return end
      -- Jump to the last line and start typing at the end of it.
      -- ("startinsert!" is the same as pressing A.)
      vim.cmd("normal! G")
      vim.cmd("startinsert!")
    end,
    desc = "Start in insert mode at the end of a Claude Code prompt",
  })
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
