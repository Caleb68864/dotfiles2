-- ============================================================================
-- Scratchpad -- a place to park temporary text that survives restarts
-- ============================================================================
-- This replaces the way Notepad++ gets used as a parking spot: you open a
-- tab, paste a command or a snippet, never save it, and it is still there
-- tomorrow.
--
-- Neovim cannot persist a truly unnamed buffer across a restart -- there is
-- nowhere to put the text. So instead these scratches ARE real files, but the
-- module saves them for you so aggressively that you never see a save prompt
-- or have to invent a filename. It should feel like nothing is ever saved,
-- while in fact everything always is.
--
-- Two kinds of scratch:
--   1. THE quick pad (~/scratch/quick.md) -- one eternal pad, one keypress.
--   2. Named scratches (~/scratch/2026-09-08-1432.md) -- for things that
--      turned out to matter.
-- ============================================================================

local M = {}

-- Where scratches live. Machine-local on purpose -- these are NOT synced.
-- Kept in a table field (not a local) so tests can point it at a temp dir.
-- Normalized at declaration so that production and test paths use the same
-- absolute form on all platforms, preventing silent data loss on Windows.
local config = {
  root = vim.fs.normalize(vim.fn.expand("~/scratch")),
}

--- Configure the module. Called from init.lua, and from tests with a temp dir.
--- @param opts table|nil  { root = string }
function M.setup(opts)
  opts = opts or {}
  if opts.root then
    -- vim.fs.normalize turns backslashes into forward slashes and expands ~,
    -- so the rest of this file can assume one path style on every platform.
    config.root = vim.fs.normalize(opts.root)
  end
end

--- @return string the scratch root directory
function M.root()
  return config.root
end

--- Create the scratch directory if it does not exist yet.
--- Safe to call repeatedly. "p" means "create parent directories too".
--- @return string the root directory
function M.ensure_root()
  if vim.fn.isdirectory(config.root) == 0 then
    vim.fn.mkdir(config.root, "p")
  end
  return config.root
end

--- @return string path to THE quick pad
function M.quick_path()
  return vim.fs.normalize(config.root .. "/quick.md")
end

--- Absolutize and normalize a path for consistent comparison across spelling
--- variations (relative vs absolute, backslashes on Windows, etc).
--- @param path string
--- @return string absolute, normalized path
local function _normalize_path(path)
  return vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
end

--- Build a unique path for a new named scratch.
--- If a file with that timestamp already exists (you made two in the same
--- minute), append -2, -3, and so on rather than silently overwriting.
--- @param timestamp number|nil os.time() value; defaults to now
--- @return string
function M.new_path(timestamp)
  local stamp = os.date("%Y-%m-%d-%H%M", timestamp or os.time())
  local path = config.root .. "/" .. stamp .. ".md"
  local n = 1
  while vim.fn.filereadable(path) == 1 do
    n = n + 1
    path = config.root .. "/" .. stamp .. "-" .. n .. ".md"
  end
  return path
end

--- Human-readable label for a scratch: its first non-empty line.
--- This is what makes the picker usable -- a list of timestamps tells you
--- nothing, but "az login --tenant contoso" tells you everything.
--- @param path string
--- @return string
function M.title_of(path)
  if vim.fn.filereadable(path) == 0 then
    return "(empty)"
  end
  -- Only read the first 20 lines; we just need the first non-empty one and
  -- there is no reason to pull a huge pad into memory to find it.
  for _, line in ipairs(vim.fn.readfile(path, "", 20)) do
    local trimmed = vim.trim(line)
    if trimmed ~= "" then
      if #trimmed > 60 then
        return trimmed:sub(1, 57) .. "..."
      end
      return trimmed
    end
  end
  return "(empty)"
end

--- All named scratches, newest first. The quick pad is deliberately excluded:
--- it is always reachable by its own keypress and would otherwise always sit
--- at the top of the list as noise.
--- @return table array of { path, title, mtime }
function M.list()
  if vim.fn.isdirectory(config.root) == 0 then
    return {}
  end
  local quick = M.quick_path()
  local items = {}
  -- vim.fn.glob with the last two args as 0,1 returns a LIST of paths.
  for _, path in ipairs(vim.fn.glob(config.root .. "/*.md", 0, 1)) do
    local normalized = _normalize_path(path)
    if normalized ~= quick then
      table.insert(items, {
        path = normalized,
        title = M.title_of(normalized),
        mtime = vim.fn.getftime(normalized),
      })
    end
  end
  table.sort(items, function(a, b) return a.mtime > b.mtime end)
  return items
end

--- Return true if the file has no non-whitespace content.
--- @param path string
--- @return boolean
local function is_blank(path)
  if vim.fn.filereadable(path) == 0 then
    return true
  end
  for _, line in ipairs(vim.fn.readfile(path)) do
    if vim.trim(line) ~= "" then
      return false
    end
  end
  return true
end

--- Move the quick pad's contents into a new dated scratch, leaving the pad
--- empty. This exists because you usually only realise something matters
--- AFTER you have already scribbled it into the pad.
--- @return string|nil path of the new scratch, or nil if the pad was empty or the copy failed
function M.promote()
  local quick = M.quick_path()
  if is_blank(quick) then
    return nil
  end
  M.ensure_root()
  local target = M.new_path()
  -- vim.fn.writefile returns -1 on failure (permission error, disk full, etc).
  -- Copy MUST succeed before we touch the pad. If it fails, leave the pad intact.
  local copy_result = vim.fn.writefile(vim.fn.readfile(quick), target)
  if copy_result == -1 then
    return nil
  end
  -- Truncate the pad rather than deleting it -- it must always exist.
  vim.fn.writefile({}, quick)

  -- If the pad is currently open in a buffer, reload it so the window does
  -- not keep showing the text we just moved away.
  local buf = vim.fn.bufnr(quick)
  if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then
    vim.api.nvim_buf_call(buf, function() vim.cmd("silent edit!") end)
  end
  return target
end

--- Delete a named scratch. The quick pad is protected: deleting it would
--- break the "there is always a pad" guarantee, and the user almost
--- certainly meant to clear it instead.
--- @param path string
--- @return boolean ok, string|nil reason
function M.delete(path)
  local absolute = _normalize_path(path)
  if absolute == M.quick_path() then
    return false, "refusing to delete the quick pad -- clear its contents instead"
  end
  if vim.fn.filereadable(absolute) == 0 then
    return false, "not a scratch file: " .. absolute
  end
  vim.fn.delete(absolute)
  return true
end

-- Handle of the currently open scratch float, so toggling can close it.
local float_win = nil

--- Is the given path inside our scratch directory?
--- Used by autosave. We compare normalized prefixes rather than using an
--- autocmd `pattern`, because autocmd patterns and Windows backslashes
--- interact badly.
--- @param path string
--- @return boolean
local function is_scratch_file(path)
  if path == nil or path == "" then
    return false
  end
  return vim.startswith(_normalize_path(path), config.root .. "/")
end

--- Open a scratch file in a centered floating window.
--- @param path string
local function open_float(path)
  M.ensure_root()
  -- Make sure the file exists so the buffer is backed by something on disk.
  if vim.fn.filereadable(path) == 0 then
    vim.fn.writefile({}, path)
  end

  local buf = vim.fn.bufadd(path)
  vim.fn.bufload(buf)

  -- markdown gives us syntax highlighting inside ``` fences, which is exactly
  -- what you want when parking shell commands.
  vim.bo[buf].filetype = "markdown"
  -- No swap file: closing a scratch by closing its window must never produce
  -- a "swap file found" recovery prompt next time.
  vim.bo[buf].swapfile = false
  -- Keep the buffer alive when the float closes, so reopening is instant.
  vim.bo[buf].bufhidden = "hide"

  local width = math.min(100, math.floor(vim.o.columns * 0.8))
  local height = math.floor(vim.o.lines * 0.8)

  float_win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " " .. vim.fn.fnamemodify(path, ":t") .. " ",
    title_pos = "center",
  })

  -- q and Esc close the float. The autosave autocommand writes on the way out,
  -- so there is nothing for the user to do.
  local function close()
    if float_win and vim.api.nvim_win_is_valid(float_win) then
      vim.api.nvim_win_close(float_win, false)
    end
    float_win = nil
  end
  vim.keymap.set("n", "q", close, { buffer = buf, silent = true, desc = "Close scratch" })
  vim.keymap.set("n", "<Esc>", close, { buffer = buf, silent = true, desc = "Close scratch" })
end

--- Toggle THE quick pad. This is the 30-second parking spot.
function M.toggle_quick()
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    vim.api.nvim_win_close(float_win, false)
    float_win = nil
    return
  end
  open_float(M.quick_path())
end

--- Create and open a brand new named scratch.
function M.new_scratch()
  M.ensure_root()
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    vim.api.nvim_win_close(float_win, false)
    float_win = nil
  end
  open_float(M.new_path())
end

--- Delete the scratch shown in the current buffer, then close the float.
function M.delete_current()
  local path = vim.api.nvim_buf_get_name(0)
  if not is_scratch_file(path) then
    vim.notify("Not a scratch file", vim.log.levels.WARN)
    return
  end
  local ok, reason = M.delete(path)
  if not ok then
    vim.notify(reason, vim.log.levels.WARN)
    return
  end
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    vim.api.nvim_win_close(float_win, true)
    float_win = nil
  end
  vim.notify("Deleted " .. vim.fn.fnamemodify(path, ":t"))
end

--- Install autosave. Scratches are written whenever you look away, so the
--- user never types :w and never sees a prompt.
function M.enable_autosave()
  local group = vim.api.nvim_create_augroup("ScratchAutosave", { clear = true })
  vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "VimLeavePre" }, {
    group = group,
    pattern = "*",
    callback = function(ev)
      local name = vim.api.nvim_buf_get_name(ev.buf)
      if is_scratch_file(name) and vim.bo[ev.buf].modified then
        vim.api.nvim_buf_call(ev.buf, function()
          vim.cmd("silent write")
        end)
      end
    end,
    desc = "Autosave scratch buffers -- the user never saves manually",
  })
end

--- Pick a scratch to open.
--- Uses Telescope when available. Telescope is disabled in PDA_MODE, so this
--- falls back to vim.ui.select rather than erroring on that profile.
function M.pick()
  local items = M.list()
  if #items == 0 then
    vim.notify("No named scratches yet -- <leader>nn makes one", vim.log.levels.INFO)
    return
  end

  local has_telescope, pickers = pcall(require, "telescope.pickers")
  if not has_telescope then
    vim.ui.select(items, {
      prompt = "Scratches",
      format_item = function(item) return item.title end,
    }, function(choice)
      if choice then vim.cmd.edit(vim.fn.fnameescape(choice.path)) end
    end)
    return
  end

  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers.new({}, {
    prompt_title = "Scratches",
    finder = finders.new_table({
      results = items,
      -- display is what you see; ordinal is what fuzzy matching searches.
      entry_maker = function(item)
        return {
          value = item,
          display = string.format("%-60s  %s", item.title,
            os.date("%Y-%m-%d %H:%M", item.mtime)),
          ordinal = item.title .. " " .. item.path,
          path = item.path,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = conf.file_previewer({}),
    attach_mappings = function(bufnr)
      actions.select_default:replace(function()
        actions.close(bufnr)
        local entry = action_state.get_selected_entry()
        if entry then vim.cmd.edit(vim.fn.fnameescape(entry.path)) end
      end)
      return true
    end,
  }):find()
end

--- Live-grep across every scratch. Telescope-only; there is no sensible
--- built-in fallback for interactive grep.
function M.grep()
  local ok, builtin = pcall(require, "telescope.builtin")
  if not ok then
    vim.notify("Telescope not available -- scratch grep is disabled", vim.log.levels.WARN)
    return
  end
  M.ensure_root()
  builtin.live_grep({ search_dirs = { config.root }, prompt_title = "Grep scratches" })
end

return M
