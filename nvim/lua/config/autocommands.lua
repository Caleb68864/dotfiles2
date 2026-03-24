-- Caleb's Neovim Autocommands

-- Auto-reload files changed by external tools (AI agents, git, etc.)
vim.api.nvim_create_autocmd({"FocusGained", "BufEnter", "CursorHold"}, {
  command = "checktime",
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})
