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
local config = {
  root = vim.fn.expand("~/scratch"),
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
  return config.root .. "/quick.md"
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

return M
