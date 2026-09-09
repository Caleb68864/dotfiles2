-- ============================================================================
-- Neovide -- GUI-only settings
-- ============================================================================
-- Neovide is a standalone graphical window that runs Neovim, instead of
-- Neovim running inside a terminal emulator.
--
-- This exists because Windows Terminal cannot pass many key combinations
-- through to Neovim at all -- Ctrl+Shift+anything, most Alt combinations, and
-- it cannot even tell Ctrl+I apart from Tab. That is a limitation of the
-- terminal, not something a config can fix. Removing the terminal from the
-- picture removes the whole class of problem, and gives real mouse support,
-- font ligatures and smooth scrolling as a bonus.
--
-- Every line here is inert unless we are actually inside Neovide.
-- ============================================================================

if not vim.g.neovide then
  return
end

-- ---------------------------------------------------------------------------
-- Font
-- ---------------------------------------------------------------------------
-- Matches the Kitty terminal config on Linux so both look identical.
vim.o.guifont = "JetBrainsMono Nerd Font:h12"

-- ---------------------------------------------------------------------------
-- Animations -- SET THIS TO false IF YOU EVER USE THIS MACHINE OVER RDP
-- ---------------------------------------------------------------------------
-- Smooth scrolling and the cursor particle trail look great on a local
-- display and are genuinely unpleasant over a remote desktop connection,
-- where every animated frame becomes network traffic. One switch kills them.
local animations = true

if animations then
  vim.g.neovide_cursor_animation_length = 0.06   -- Seconds for the cursor to glide
  vim.g.neovide_cursor_trail_size = 0.4          -- How long the trail behind it is
  vim.g.neovide_cursor_vfx_mode = "railgun"      -- Particle effect; "" disables
  vim.g.neovide_scroll_animation_length = 0.25   -- Smooth scrolling
else
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_cursor_trail_size = 0
  vim.g.neovide_cursor_vfx_mode = ""
  vim.g.neovide_scroll_animation_length = 0
end

-- ---------------------------------------------------------------------------
-- Window behaviour
-- ---------------------------------------------------------------------------
vim.g.neovide_remember_window_size = true   -- Reopen at the size you left it
vim.g.neovide_hide_mouse_when_typing = true -- Pointer gets out of the way

-- Frames per second to render at. This is a fixed value, not auto-detected,
-- so set it to match your monitor's refresh rate. On a 60Hz display it is
-- correct as-is; on 144Hz or higher, change it. `idle` drops the rate right
-- down when nothing is happening, so an open-but-unused window is not burning GPU.
vim.g.neovide_refresh_rate = 60
vim.g.neovide_refresh_rate_idle = 5
vim.g.neovide_padding_top = 4
vim.g.neovide_padding_left = 4
vim.g.neovide_padding_right = 4
vim.g.neovide_padding_bottom = 4

-- ---------------------------------------------------------------------------
-- Zoom -- Ctrl+= / Ctrl+- / Ctrl+0, and Ctrl+scroll
-- ---------------------------------------------------------------------------
-- Neovide scales the whole window by a factor rather than changing the font
-- size, so this zooms everything crisply.
vim.g.neovide_scale_factor = 1.0

local function change_scale(delta)
  -- Clamp so you cannot zoom to something unusable and get stuck.
  local new = vim.g.neovide_scale_factor + delta
  vim.g.neovide_scale_factor = math.min(math.max(new, 0.5), 3.0)
end

vim.keymap.set({ "n", "i" }, "<C-=>", function() change_scale(0.1) end, { desc = "Zoom in" })
vim.keymap.set({ "n", "i" }, "<C-->", function() change_scale(-0.1) end, { desc = "Zoom out" })
vim.keymap.set({ "n", "i" }, "<C-0>", function() vim.g.neovide_scale_factor = 1.0 end, { desc = "Zoom reset" })
vim.keymap.set({ "n", "i" }, "<C-ScrollWheelUp>", function() change_scale(0.1) end, { desc = "Zoom in" })
vim.keymap.set({ "n", "i" }, "<C-ScrollWheelDown>", function() change_scale(-0.1) end, { desc = "Zoom out" })
