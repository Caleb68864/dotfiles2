-- ============================================================================
-- Caleb's Neovim Configuration - Entry Point
-- ============================================================================
-- This is the very first file Neovim reads when it starts up.
-- Think of it like the "main()" of the entire editor configuration.
--
-- Managed by GNU Stow from ~/dotfiles/nvim/
-- Full IDE setup for Python & C# with AI assistants (Pi, Claude Code)
--
-- Structure (how the config is organized into separate files):
--   lua/config/options.lua       -- Editor settings (how things look and behave)
--   lua/config/keymaps.lua       -- Keyboard shortcuts
--   lua/config/autocommands.lua  -- Things that happen automatically (like on save)
--   lua/plugins/*.lua            -- Plugin specs (all the extra tools we add)
-- ============================================================================

-- ============================================================================
-- Leader key (must be set before lazy.nvim loads any plugins)
-- ============================================================================
-- The "leader" key is a special key you press first before other keys to
-- trigger custom shortcuts. We set it to the spacebar because it is the
-- biggest key and easy to reach. For example, pressing Space then f then f
-- will search for files.
--
-- "mapleader" is for global shortcuts; "maplocalleader" is for shortcuts
-- that only apply to certain file types. We set both to space for simplicity.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================================
-- Bootstrap lazy.nvim (the plugin manager)
-- ============================================================================
-- lazy.nvim is the tool that downloads and manages all our plugins (extra
-- features we add to Neovim). This section checks if lazy.nvim is already
-- installed. If not, it automatically downloads it from GitHub.
-- This means you can clone this config on a brand-new machine and everything
-- will just work on first launch.

-- Figure out where lazy.nvim should live on disk
-- vim.fn.stdpath("data") is Neovim's data folder (usually ~/.local/share/nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- If lazy.nvim is NOT already downloaded, clone it from GitHub
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",                                          -- Use git to download
    "clone",                                        -- Clone the repository
    "--filter=blob:none",                           -- Don't download file history (faster)
    "https://github.com/folke/lazy.nvim.git",       -- Where to download from
    "--branch=stable",                              -- Use the stable release, not bleeding edge
    lazypath,                                       -- Where to save it on disk
  })
end

-- Add lazy.nvim to Neovim's "runtime path" so Neovim can find and use it
-- This is like adding a folder to your system PATH so programs can be found
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- Load config modules (our settings, keymaps, and autocommands)
-- ============================================================================
-- These three lines load our custom configuration files.
-- "require" in Lua is like "import" in Python -- it runs the code in that file.
-- Neovim automatically looks inside the "lua/" folder, so "config.options"
-- means "lua/config/options.lua".
require("config.options")      -- Editor settings (line numbers, tabs, etc.)
require("config.keymaps")      -- Custom keyboard shortcuts
require("config.autocommands") -- Automatic actions (trim whitespace on save, etc.)

-- Scratchpad: persistent parking spot for temporary text.
-- setup() with no arguments uses the default root of ~/scratch.
local scratch = require("config.scratch")
scratch.setup()
scratch.enable_autosave()

-- ============================================================================
-- Load plugins (auto-discovers all files in lua/plugins/)
-- ============================================================================
-- This tells lazy.nvim to find and load every .lua file inside lua/plugins/.
-- Each file in that folder defines one or more plugins. lazy.nvim handles
-- downloading them, keeping them updated, and loading them at the right time.
--
-- The "ui.border = rounded" option makes the lazy.nvim popup window have
-- nice rounded corners instead of sharp ones.
require("lazy").setup("plugins", {
  ui = {
    border = "rounded",
  },
})
