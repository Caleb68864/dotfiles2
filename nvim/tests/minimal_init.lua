-- Minimal Neovim init used ONLY by the headless test runner.
-- It loads plenary (the test framework) and puts our own lua/ directory on
-- the runtime path, so tests can `require("config.scratch")` etc.
-- It deliberately does NOT load lazy.nvim or any plugins -- tests must be
-- fast and must not depend on the full plugin set being installed.

local here = vim.fn.fnamemodify(vim.fn.expand("<sfile>:p"), ":h")   -- nvim/tests
local nvim_root = vim.fn.fnamemodify(here, ":h")                    -- nvim/

vim.opt.rtp:append(nvim_root)
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/plenary.nvim")
vim.cmd("runtime plugin/plenary.vim")
