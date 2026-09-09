-- ============================================================================
-- Platform detection
-- ============================================================================
-- This config runs on two machines: Linux (EndeavourOS/Hyprland) and native
-- Windows with the Neovide GUI. Rather than keeping two copies of the config
-- -- which always rot, because every improvement has to be made twice --
-- there is ONE config that asks at runtime where it is running.
--
-- Everything here is computed once when this file is first required, so
-- checking these flags is free.
-- ============================================================================

local M = {}

--- True on native Windows. Note this is TRUE for Neovim built for Windows and
--- FALSE for Neovim running inside WSL, which is Linux as far as it knows.
M.is_windows = vim.fn.has("win32") == 1

--- True on Linux, including WSL.
M.is_linux = vim.fn.has("linux") == 1

--- True when this Linux is actually WSL.
--- WSL is a non-goal for this setup -- Windows uses native Neovim -- but the
--- flag costs one line and is what you would branch on to disable clipboard
--- and GUI assumptions if the config is ever opened under WSL by accident.
M.is_wsl = (function()
  if not M.is_linux then
    return false
  end
  local ok, lines = pcall(vim.fn.readfile, "/proc/version")
  if not ok or not lines or not lines[1] then
    return false
  end
  return lines[1]:lower():find("microsoft") ~= nil
end)()

--- True when running inside the Neovide GUI rather than a terminal.
--- Neovide sets vim.g.neovide before any config is read.
M.is_neovide = vim.g.neovide ~= nil

--- Is this program available on PATH?
--- Used to enable plugins only when the tool they wrap is actually installed,
--- so a missing `lazygit` produces no plugin rather than a broken keybinding.
--- @param exe string
--- @return boolean
function M.has(exe)
  return vim.fn.executable(exe) == 1
end

return M
