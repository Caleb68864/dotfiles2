-- ============================================================================
-- Caleb's Neovim Keymaps
-- ============================================================================
-- These are custom keyboard shortcuts (keymaps) for common actions.
-- Plugin-specific keymaps live in their own plugin files (lua/plugins/*.lua).
--
-- How keymaps work:
--   vim.keymap.set(MODE, KEYS, ACTION, OPTIONS)
--   MODE: "n" = normal mode, "v" = visual mode, "i" = insert mode
--   KEYS: what you press on the keyboard
--   ACTION: what happens when you press those keys
-- ============================================================================

-- ============================================================================
-- Resize windows -- Make split windows bigger or smaller
-- ============================================================================
-- When you have multiple windows open side by side (splits), these let you
-- resize them with Ctrl + arrow keys.
-- Think of it like dragging the edge of a window with your keyboard.
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>")           -- Ctrl+Up = make window shorter
vim.keymap.set("n", "<C-Down>", ":resize +2<CR>")         -- Ctrl+Down = make window taller
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>")  -- Ctrl+Left = make window narrower
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>") -- Ctrl+Right = make window wider

-- ============================================================================
-- Navigate buffers -- Switch between open files
-- ============================================================================
-- "Buffers" are like browser tabs -- each open file is a buffer.
-- Shift+L goes to the next file, Shift+H goes to the previous one.
-- (L and H are like "right" and "left" in Vim's world.)
vim.keymap.set("n", "<S-l>", ":bnext<CR>")      -- Shift+L = next buffer (file)
vim.keymap.set("n", "<S-h>", ":bprevious<CR>")  -- Shift+H = previous buffer (file)

-- ============================================================================
-- Close buffer -- Close a file without closing the whole window
-- ============================================================================
-- These close the current file but keep the window open.
-- Space+b+d and Space+q both do the same thing (two ways to remember it).
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "[b]uffer [d]elete" })
vim.keymap.set("n", "<leader>q", "<cmd>bdelete<CR>", { desc = "[q]uit buffer" })

-- ============================================================================
-- Move text up and down -- Rearrange lines in visual mode
-- ============================================================================
-- When you select lines in visual mode, pressing J moves them down and K
-- moves them up. The "gv=gv" part re-selects the text and re-indents it
-- so everything stays lined up properly.
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")  -- Move selected lines DOWN
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")  -- Move selected lines UP

-- ============================================================================
-- Stay in indent mode -- Keep your selection after indenting
-- ============================================================================
-- Normally when you indent selected text with < or >, you lose your selection.
-- These keymaps re-select the text after indenting so you can keep going
-- without having to re-select everything.
vim.keymap.set("v", "<", "<gv")  -- Indent left and keep selection
vim.keymap.set("v", ">", ">gv")  -- Indent right and keep selection

-- ============================================================================
-- Clear search highlight -- Get rid of yellow highlighted search results
-- ============================================================================
-- After you search for something (like /hello), all matches stay highlighted.
-- Pressing Escape clears those highlights so they stop distracting you.
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- ============================================================================
-- Path yanking -- Copy file paths to clipboard
-- ============================================================================
-- These are super useful when working with AI tools (like Claude Code or Pi).
-- You can quickly copy the path of the file you're editing to paste into
-- a chat or command.

-- Space+y+r = copy the RELATIVE path (like "lua/config/keymaps.lua")
-- Relative means relative to your project root -- shorter and cleaner.
vim.keymap.set("n", "<leader>yr", function()
  local path = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")  -- Get relative path
  vim.fn.setreg("+", path)   -- Put it in the system clipboard
  vim.notify("Copied: " .. path)  -- Show a little notification
end, { desc = "[y]ank [r]elative path" })

-- Space+y+p = copy the ABSOLUTE path (like "/home/caleb/dotfiles/nvim/lua/config/keymaps.lua")
-- Absolute means the full path from the root of the filesystem.
vim.keymap.set("n", "<leader>yp", function()
  local path = vim.fn.expand("%:p")  -- Get absolute path
  vim.fn.setreg("+", path)           -- Put it in the system clipboard
  vim.notify("Copied: " .. path)     -- Show a little notification
end, { desc = "[y]ank absolute [p]ath" })
