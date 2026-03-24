-- ============================================================================
-- AI Assistant Plugins -- Tools that let AI help you write code
-- ============================================================================
-- This file configures AI-powered coding assistants that work inside Neovim.
-- Currently two are active:
--
--   1. Pi (pi-nvim) -- A lightweight AI coding agent that runs in a terminal
--      pane. You send it prompts, code selections, or whole files and it
--      helps you write, explain, or fix code.
--
--   2. Claude Code (claudecode.nvim) -- Connects Neovim to the Claude Code
--      CLI agent via WebSocket (like the VS Code extension). This lets
--      Claude Code see what files you have open and interact with your editor.
--
-- There are also two COMMENTED OUT alternatives (CodeCompanion and Avante)
-- that were previously used but replaced by Pi. They're kept as comments
-- in case you want to switch back.
-- ============================================================================

return {
  -- =========================================================================
  -- Pi Coding Agent -- The primary AI assistant
  -- =========================================================================
  -- Pi is a simple, focused AI coding assistant. It opens a terminal pane
  -- where you can chat with an AI about your code.
  {
    "carderne/pi-nvim",
    config = function()
      require("pi-nvim").setup({})

      -- Pi keymaps -- All start with Space+p (p for Pi)
      -- Space+p+p = open the Pi prompt (type your question after ":Pi ")
      vim.keymap.set("n", "<leader>pp", ":Pi ", { desc = "[p]i [p]rompt" })
      -- Space+p+s = send the currently SELECTED text to Pi (in visual mode)
      -- Select some code, then press this to ask Pi about it
      vim.keymap.set("v", "<leader>ps", ":PiSendSelection<CR>", { desc = "[p]i send [s]election" })
      -- Space+p+f = send the entire current FILE to Pi
      vim.keymap.set("n", "<leader>pf", ":PiSendFile<CR>", { desc = "[p]i send [f]ile" })
      -- Space+p+b = send the entire current BUFFER (same as file, basically) to Pi
      vim.keymap.set("n", "<leader>pb", ":PiSendBuffer<CR>", { desc = "[p]i send [b]uffer" })
    end,
  },

  -- =========================================================================
  -- Claude Code -- Integration with the Claude Code CLI
  -- =========================================================================
  -- This plugin connects Neovim to the Claude Code command-line tool using
  -- a WebSocket connection (similar to how the VS Code extension works).
  -- It lets Claude Code know which files you have open, what you're looking
  -- at, and enables Claude Code to interact with your editor (like reading
  -- file contents or seeing your selections).
  -- "plenary.nvim" is a utility library that many plugins depend on.
  {
    "coder/claudecode.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("claudecode").setup({})
    end,
  },

  -- =========================================================================
  -- CodeCompanion (COMMENTED OUT -- replaced by Pi)
  -- =========================================================================
  -- CodeCompanion was a previous AI assistant that talked directly to
  -- Anthropic's Claude API. It had a chat window and inline code editing.
  -- To restore: uncomment this block and comment out pi-nvim above.
  -- {
  --   "olimorris/codecompanion.nvim",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  --   config = function()
  --     require("codecompanion").setup({
  --       strategies = {
  --         chat = { adapter = "anthropic" },     -- Use Claude for chat
  --         inline = { adapter = "anthropic" },   -- Use Claude for inline edits
  --       },
  --       adapters = {
  --         http = {
  --           anthropic = function()
  --             return require("codecompanion.adapters").extend("anthropic", {
  --               env = { api_key = "ANTHROPIC_API_KEY" },  -- Needs this env var set
  --             })
  --           end,
  --         },
  --       },
  --     })
  --     -- Keymaps were: Space+c+c for chat, Space+c+i for inline, Space+c+a for actions
  --     vim.keymap.set({ "n", "v" }, "<leader>cc", "<cmd>CodeCompanionChat<CR>", { desc = "[c]ode[c]ompanion chat" })
  --     vim.keymap.set({ "n", "v" }, "<leader>ci", "<cmd>CodeCompanion<CR>", { desc = "[c]ode[c]ompanion [i]nline" })
  --     vim.keymap.set("n", "<leader>ca", "<cmd>CodeCompanionActions<CR>", { desc = "[c]ode[c]ompanion [a]ctions" })
  --   end,
  -- },

  -- =========================================================================
  -- Avante (COMMENTED OUT -- Cursor-like AI experience)
  -- =========================================================================
  -- Avante tried to replicate the "Cursor" AI editor experience inside Neovim.
  -- It was another option for AI-assisted coding but wasn't as good a fit.
  -- {
  --   "yetone/avante.nvim",
  --   event = "VeryLazy",           -- Load lazily (only when needed)
  --   build = "make",               -- Needs to compile native code
  --   dependencies = {
  --     "nvim-tree/nvim-web-devicons",  -- File icons
  --     "stevearc/dressing.nvim",       -- Better UI for input prompts
  --     "nvim-lua/plenary.nvim",        -- Utility library
  --     "MunifTanjim/nui.nvim",         -- UI component library
  --   },
  --   config = function()
  --     require("avante").setup({ provider = "claude" })
  --   end,
  -- },
}
