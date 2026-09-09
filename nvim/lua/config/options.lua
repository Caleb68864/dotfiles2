-- ============================================================================
-- Caleb's Neovim Options
-- ============================================================================
-- This file controls how the editor looks and behaves -- things like line
-- numbers, how tabs work, where new windows open, and more.
-- These are the "preferences" or "settings" of the editor.
-- ============================================================================

-- Create a shortcut variable so we can type "opt" instead of "vim.opt" every time.
-- "vim.opt" is how you change Neovim settings from Lua.
local opt = vim.opt

-- ============================================================================
-- UI (User Interface) -- How the editor LOOKS
-- ============================================================================

-- Show line numbers on the left side (1, 2, 3, ...)
opt.number = true

-- Show RELATIVE line numbers (how far each line is from your cursor).
-- This makes it easy to jump: press "5j" to go down 5 lines.
-- The current line still shows the absolute number because "number" is also true.
opt.relativenumber = true

-- Always show the "sign column" on the left edge (where git changes, errors,
-- and breakpoints appear). "yes" means always show it, even if empty, so the
-- text doesn't jump left/right when signs appear or disappear.
opt.signcolumn = "yes"

-- Highlight the entire line your cursor is on, making it easier to find.
opt.cursorline = true

-- Enable 24-bit RGB colors in the terminal. Without this, Neovim is limited
-- to only 256 colors and the Tokyo Night theme would look wrong.
opt.termguicolors = true

-- Don't show "-- INSERT --" or "-- VISUAL --" at the bottom of the screen.
-- We hide it because the statusline plugin (lualine) already shows the mode
-- in a prettier way.
opt.showmode = false

-- Set the command line at the bottom to be 1 row tall.
opt.cmdheight = 1

-- Use a single shared statusline at the very bottom of the window, instead of
-- one statusline per split. This looks cleaner when you have multiple splits open.
opt.laststatus = 3  -- Global statusline

-- Always show the tab bar at the top, even with only one file open.
-- bufferline draws our clickable file tabs there; without this the tabs
-- appear and disappear as you open files, which makes the layout jump.
opt.showtabline = 2

-- Report mouse MOVEMENT (not just clicks) to Neovim. Required for bufferline
-- to highlight the tab you are hovering over, and for the close "x" on each
-- tab to light up. Without it the tabs are clickable but feel dead.
opt.mousemoveevent = true

-- Always keep at least 8 lines visible above and below the cursor when scrolling.
-- This way you can always see context around where you are typing.
opt.scrolloff = 8

-- Same as scrolloff but for horizontal scrolling -- keep 8 columns visible
-- to the left and right of the cursor.
opt.sidescrolloff = 8

-- Show vertical guide lines at columns 80 and 120. These are common line
-- length limits in coding style guides. The lines remind you when a line
-- is getting too long.
opt.colorcolumn = "80,120"

-- Don't wrap long lines to the next line on screen. Instead, you scroll
-- sideways to see the rest. This keeps code lined up properly.
opt.wrap = false

-- ============================================================================
-- Search -- How finding text works
-- ============================================================================

-- Ignore uppercase vs lowercase when searching (so searching "hello" also
-- finds "Hello" and "HELLO").
opt.ignorecase = true

-- BUT if you type any uppercase letter in your search, it becomes
-- case-sensitive. So "hello" finds "Hello", but "Hello" only finds "Hello".
-- This gives you the best of both worlds.
opt.smartcase = true

-- Highlight ALL matches when you search for something, not just the one
-- you jumped to. Makes it easy to see every occurrence.
opt.hlsearch = true

-- Show search results as you type, updating live with each character.
-- You don't have to press Enter first to see where matches are.
opt.incsearch = true

-- ============================================================================
-- Indentation -- How tabs and spacing work
-- ============================================================================

-- When you press Tab, insert spaces instead of a real tab character.
-- Spaces are more portable and look the same everywhere.
opt.expandtab = true

-- When you indent code (with >> or auto-indent), move it 4 spaces.
opt.shiftwidth = 4

-- A real Tab character is displayed as 4 spaces wide.
opt.tabstop = 4

-- When you press Tab while typing, insert 4 spaces.
opt.softtabstop = 4

-- Automatically indent new lines to match the code structure (like after
-- an opening brace or colon). Neovim tries to be smart about it.
opt.smartindent = true

-- Copy the indentation of the current line when starting a new one.
-- Works together with smartindent for even better auto-indentation.
opt.autoindent = true

-- ============================================================================
-- Splits -- How new windows open when you split the screen
-- ============================================================================

-- When you split horizontally (top/bottom), put the new window BELOW.
-- Default is above, which feels backwards to most people.
opt.splitbelow = true

-- When you split vertically (left/right), put the new window to the RIGHT.
-- Default is left, which also feels backwards.
opt.splitright = true

-- ============================================================================
-- Files -- How Neovim handles saving and file management
-- ============================================================================

-- Don't create .swp swap files. Swap files are meant to recover from crashes,
-- but they create clutter and we have git for backup instead.
opt.swapfile = false

-- Don't create backup~ files before saving. Same reasoning as above.
opt.backup = false

-- DO save undo history to a file, so you can undo changes even after closing
-- and reopening a file. This is extremely useful -- you can undo changes
-- from yesterday!
opt.undofile = true

-- Where to store those undo history files on disk.
-- Keeps them in Neovim's data directory so they don't clutter your projects.
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- ============================================================================
-- Misc -- Other useful settings
-- ============================================================================

-- Enable mouse support in all modes. You can click to place your cursor,
-- scroll, select text, resize splits, etc. Useful when you want to be lazy.
opt.mouse = "a"

-- Share the clipboard with your operating system. When you copy (yank) text
-- in Neovim, it goes to the system clipboard so you can paste it in other
-- apps, and vice versa.
opt.clipboard = "unnamedplus"

-- Settings for the autocomplete popup menu:
-- "menu"     = show a popup menu with options
-- "menuone"  = show the menu even if there's only one match
-- "noselect" = don't auto-select the first item; let the user choose
opt.completeopt = "menu,menuone,noselect"

-- How quickly (in milliseconds) Neovim waits after you stop typing before
-- triggering things like the CursorHold event (used by some plugins).
-- 250ms is snappy. Default is 4000ms which feels slow.
opt.updatetime = 250

-- How long (in milliseconds) Neovim waits after you press a key before
-- deciding you're not going to press another key in a sequence.
-- 300ms means key combos like <leader>ff need to be pressed within 300ms.
opt.timeoutlen = 300

-- Don't hide special characters in markdown or JSON files. Some files use
-- "concealing" to replace characters with prettier versions, but this can
-- be confusing when editing. Level 0 = show everything as-is.
opt.conceallevel = 0

-- Automatically reload files that were changed outside of Neovim (for example,
-- by an AI coding agent like Claude Code, or by git operations).
-- Without this, you'd have to manually tell Neovim to re-read the file.
opt.autoread = true  -- Auto-reload files changed externally (e.g., by AI agents)

-- ============================================================================
-- Disable netrw (Neovim's built-in file explorer)
-- ============================================================================
-- We disable the built-in file explorer because we use nvim-tree instead,
-- which is much more feature-rich and looks better. Setting these to 1
-- tells Neovim "pretend these plugins are already loaded" so they never start.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
