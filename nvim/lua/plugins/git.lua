return {
  -- Git signs in the gutter
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },

  -- Diffview - Git diff viewer, history browser, merge conflict UI
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "[g]it [d]iffview open" },
      { "<leader>gc", "<cmd>DiffviewClose<CR>", desc = "[g]it diffview [c]lose" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "[g]it file [h]istory" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "[g]it repo [H]istory" },
    },
    config = function()
      require("diffview").setup()
    end,
  },

  -- Lazygit - TUI git client floating inside Neovim
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>lg", "<cmd>LazyGit<CR>", desc = "[l]azy[g]it" },
    },
  },
}
