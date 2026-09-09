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
-- Shift+L / Shift+H cycle through open files.
-- These use BufferLineCycle rather than :bnext/:bprevious so that keyboard
-- cycling follows the order the tabs are DISPLAYED in. Plain :bnext follows
-- internal buffer numbers, which stop matching the visible order as soon as
-- you close a file or drag a tab -- very disorienting.
vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })

-- Space+b+p = PIN a tab so it stays at the left and is not closed by
-- "close others". Space+b+c = pick a tab to close by pressing its letter.
vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineTogglePin<CR>", { desc = "[b]uffer [p]in" })
vim.keymap.set("n", "<leader>bc", "<cmd>BufferLinePickClose<CR>", { desc = "[b]uffer pick [c]lose" })

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

-- ============================================================================
-- Cheat Sheet -- Quick reference for all custom keybindings
-- ============================================================================
-- Press Space+? to open a floating window with all keybindings.
-- Press q or Escape to close it. This supplements which-key (which shows
-- bindings as you type) with a full overview you can read at a glance.
vim.keymap.set("n", "<leader>?", function()
  local lines = {
    "╔═══════════════════════════════════════════════════════════╗",
    "║              Neovim Cheat Sheet  (Space = leader)        ║",
    "╚═══════════════════════════════════════════════════════════╝",
    "",
    "── Navigation ──────────────────────────────────────────────",
    "  Ctrl+h/j/k/l    Move between splits (shared with tmux)",
    "  Shift+H / L      Previous / next buffer (file)",
    "  gd               Go to definition",
    "  gr               Find all references",
    "  K                Hover documentation",
    "  ]t / [t          Next / previous TODO comment",
    "",
    "── Find (Space+f) ─────────────────────────────────────────",
    "  ff  Find files        fg  Grep text in project",
    "  fb  Find buffers      fh  Find help docs",
    "  fr  Find recent files fs  Find string under cursor",
    "  ft  Find TODOs",
    "",
    "── Git (Space+g) ──────────────────────────────────────────",
    "  gd  Diffview open     gc  Diffview close",
    "  gh  File history      gH  Repo history",
    "  lg  LazyGit",
    "",
    "── Pi AI (Space+p) ────────────────────────────────────────",
    "  pp  Pi prompt          ps  Send selection to Pi",
    "  pf  Send file to Pi    pb  Send buffer to Pi",
    "",
    "── Test (Space+t) ─────────────────────────────────────────",
    "  tt  Run nearest test   tf  Run file tests",
    "  td  Debug nearest      ts  Test summary",
    "  to  Test output        tS  Stop test",
    "",
    "── Debug ──────────────────────────────────────────────────",
    "  F5   Start/Continue    F10  Step over",
    "  F11  Step into         F12  Step out",
    "  Space+b  Toggle breakpoint",
    "  Space+B  Conditional breakpoint",
    "",
    "── Code ───────────────────────────────────────────────────",
    "  Space+ca  Code action      Space+rn  Rename symbol",
    "  Space+f   Format file      Space+e   File explorer",
    "  Space+a   Code outline     Space+S   Find & replace (Spectre)",
    "  Space+xx  Toggle Trouble   gcc       Comment line",
    "",
    "── Harpoon (Space+h) ─────────────────────────────────────",
    "  ha  Add file to harpoon    hl  Harpoon list",
    "  Space+1-4  Jump to harpoon file 1-4",
    "",
    "── Scratchpad (Space+n) ───────────────────────────────────",
    "  Space Space    Toggle the quick pad (autosaves for you)",
    "  nn  New named scratch    nf  Find scratches",
    "  ng  Grep scratches       np  Promote pad to a named file",
    "  nd  Delete this scratch",
    "",
    "── Other ──────────────────────────────────────────────────",
    "  Space+yr  Yank relative path   Space+yp  Yank absolute path",
    "  Space+bd  Close buffer         Space+q   Close buffer",
    "  Space+bp  Pin buffer           Space+bc  Pick-close buffer",
    "  Space+y   Yazi (current file)  Space+Y   Yazi (working dir)",
    "  zR / zM   Open / close all folds",
    "",
    "  Press q to close",
  }

  -- Create a scratch buffer with the cheat sheet content
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  -- Calculate floating window size and position (centered)
  local width = 63
  local height = #lines
  local ui = vim.api.nvim_list_uis()[1]
  local row = math.floor((ui.height - height) / 2)
  local col = math.floor((ui.width - width) / 2)

  -- Open the floating window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Cheat Sheet ",
    title_pos = "center",
  })

  -- Close with q or Escape
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = buf, silent = true })
end, { desc = "Show cheat sheet" })

-- ============================================================================
-- Scratchpad -- park temporary text that survives a restart
-- ============================================================================
-- Space+Space is THE quick pad: one eternal note, one keypress. Use it the
-- way you would use an unsaved Notepad++ tab -- paste a command, come back
-- to it tomorrow. Nothing here ever asks you to save or name a file.
local scratch = require("config.scratch")

vim.keymap.set("n", "<leader><leader>", scratch.toggle_quick, { desc = "Scratch: toggle quick pad" })
vim.keymap.set("n", "<leader>nn", scratch.new_scratch, { desc = "Scratch: [n]ew [n]amed scratch" })
vim.keymap.set("n", "<leader>nf", scratch.pick, { desc = "Scratch: [f]ind scratches" })
vim.keymap.set("n", "<leader>ng", scratch.grep, { desc = "Scratch: [g]rep scratches" })
vim.keymap.set("n", "<leader>nd", scratch.delete_current, { desc = "Scratch: [d]elete this scratch" })

-- Promote moves the quick pad's contents into a dated file and clears the
-- pad, for when something you scribbled turns out to be worth keeping.
vim.keymap.set("n", "<leader>np", function()
  local path = scratch.promote()
  if path then
    vim.notify("Promoted to " .. vim.fn.fnamemodify(path, ":t"))
  else
    vim.notify("Quick pad is empty -- nothing to promote", vim.log.levels.INFO)
  end
end, { desc = "Scratch: [p]romote quick pad" })
