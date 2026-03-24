-- Caleb's Neovim Configuration
-- Managed by GNU Stow from ~/dotfiles/nvim/
-- Full IDE setup for Python & C# with AI assistants (Pi, Claude Code)
--
-- Structure:
--   lua/config/options.lua       -- Editor settings
--   lua/config/keymaps.lua       -- General keymaps
--   lua/config/autocommands.lua  -- Autocommands
--   lua/plugins/*.lua            -- Plugin specs (auto-loaded by lazy.nvim)

-- ============================================================================
-- Leader key (must be set before lazy.nvim)
-- ============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================================
-- Bootstrap lazy.nvim
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- Load config modules
-- ============================================================================
require("config.options")
require("config.keymaps")
require("config.autocommands")

-- ============================================================================
-- Load plugins (auto-discovers all files in lua/plugins/)
-- ============================================================================
require("lazy").setup("plugins", {
  ui = {
    border = "rounded",
  },
})
