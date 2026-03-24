-- ============================================================================
-- Caleb's Neovim Autocommands
-- ============================================================================
-- Autocommands are things that happen AUTOMATICALLY when certain events occur.
-- Think of them like "when THIS happens, do THAT" rules.
-- For example: "when I save a file, remove extra spaces at the end of lines."
-- ============================================================================

-- ============================================================================
-- Auto-reload files changed by external tools
-- ============================================================================
-- When something outside of Neovim changes a file you have open (for example,
-- an AI coding agent like Claude Code edits it, or you run "git pull"),
-- Neovim needs to know about it. This autocommand checks if files have changed
-- whenever:
--   FocusGained = you switch back to the Neovim window from another app
--   BufEnter    = you switch to a different buffer (open file) inside Neovim
--   CursorHold  = you stop moving your cursor for a moment (250ms, see options.lua)
-- The "checktime" command tells Neovim: "hey, go check if any files changed on disk."
vim.api.nvim_create_autocmd({"FocusGained", "BufEnter", "CursorHold"}, {
  command = "checktime",
})

-- ============================================================================
-- Highlight on yank (briefly flash text you just copied)
-- ============================================================================
-- When you "yank" (copy) text in Neovim, this briefly highlights the text
-- you copied with a flash of color. This is a nice visual confirmation so
-- you know exactly WHAT you just copied. The highlight disappears after a
-- moment. Very helpful when you're not sure if you selected the right text.
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()  -- Built-in Neovim function that does the flash
  end,
})

-- ============================================================================
-- Remove trailing whitespace on save
-- ============================================================================
-- "Trailing whitespace" means invisible spaces or tabs at the END of a line.
-- They serve no purpose and can cause problems:
--   - They make git diffs messy (git sees them as changes)
--   - Some linters and style checkers complain about them
--   - They're just sloppy
--
-- This autocommand automatically removes all trailing whitespace every time
-- you save ANY file. It also remembers where your cursor was and puts it
-- back so you don't get teleported somewhere unexpected after saving.
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",  -- Apply to ALL file types
  callback = function()
    local save_cursor = vim.fn.getpos(".")       -- Remember cursor position
    vim.cmd([[%s/\s\+$//e]])                     -- Find and remove trailing spaces
    -- The regex means: % = all lines, \s\+ = one or more spaces, $ = end of line
    -- The "e" flag means "don't show an error if nothing was found"
    vim.fn.setpos(".", save_cursor)              -- Restore cursor position
  end,
})
