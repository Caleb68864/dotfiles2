return {
  -- Primary: Pi Coding Agent
  {
    "carderne/pi-nvim",
    config = function()
      require("pi-nvim").setup({})

      -- Pi keymaps (<leader>p namespace)
      vim.keymap.set("n", "<leader>pp", ":Pi ", { desc = "[p]i [p]rompt" })
      vim.keymap.set("v", "<leader>ps", ":PiSendSelection<CR>", { desc = "[p]i send [s]election" })
      vim.keymap.set("n", "<leader>pf", ":PiSendFile<CR>", { desc = "[p]i send [f]ile" })
      vim.keymap.set("n", "<leader>pb", ":PiSendBuffer<CR>", { desc = "[p]i send [b]uffer" })
    end,
  },

  -- Claude Code integration (WebSocket MCP protocol, like VS Code extension)
  {
    "coder/claudecode.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("claudecode").setup({})
    end,
  },

  -- CodeCompanion (commented out, replaced by Pi)
  -- To restore: uncomment and comment out pi-nvim above
  -- {
  --   "olimorris/codecompanion.nvim",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  --   config = function()
  --     require("codecompanion").setup({
  --       strategies = {
  --         chat = { adapter = "anthropic" },
  --         inline = { adapter = "anthropic" },
  --       },
  --       adapters = {
  --         http = {
  --           anthropic = function()
  --             return require("codecompanion.adapters").extend("anthropic", {
  --               env = { api_key = "ANTHROPIC_API_KEY" },
  --             })
  --           end,
  --         },
  --       },
  --     })
  --     vim.keymap.set({ "n", "v" }, "<leader>cc", "<cmd>CodeCompanionChat<CR>", { desc = "[c]ode[c]ompanion chat" })
  --     vim.keymap.set({ "n", "v" }, "<leader>ci", "<cmd>CodeCompanion<CR>", { desc = "[c]ode[c]ompanion [i]nline" })
  --     vim.keymap.set("n", "<leader>ca", "<cmd>CodeCompanionActions<CR>", { desc = "[c]ode[c]ompanion [a]ctions" })
  --   end,
  -- },

  -- Avante (commented out, Cursor-like experience)
  -- {
  --   "yetone/avante.nvim",
  --   event = "VeryLazy",
  --   build = "make",
  --   dependencies = {
  --     "nvim-tree/nvim-web-devicons",
  --     "stevearc/dressing.nvim",
  --     "nvim-lua/plenary.nvim",
  --     "MunifTanjim/nui.nvim",
  --   },
  --   config = function()
  --     require("avante").setup({ provider = "claude" })
  --   end,
  -- },
}
