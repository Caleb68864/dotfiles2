return {
  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
          component_separators = "|",
          section_separators = "",
        },
      })
    end,
  },

  -- Which-key - Show available keybindings
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    config = function()
      local wk = require("which-key")
      wk.setup({})
      wk.register({
        ["<leader>f"] = { name = "Find" },
        ["<leader>g"] = { name = "Git" },
        ["<leader>p"] = { name = "Pi" },
        ["<leader>t"] = { name = "Test" },
        ["<leader>x"] = { name = "Trouble" },
        ["<leader>r"] = { name = "Refactor" },
        ["<leader>d"] = { name = "Debug" },
        ["<leader>y"] = { name = "Yank" },
        ["<leader>h"] = { name = "Harpoon" },
        ["<leader>s"] = { name = "Search/Replace" },
        ["<leader>w"] = { name = "Workspace" },
      })
    end,
  },

  -- Indent blankline
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope = { enabled = true },
    },
  },

  -- Colorizer - Show hex colors inline
  {
    "NvChad/nvim-colorizer.lua",
    opts = {
      filetypes = { "*" },
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = false,
        RRGGBBAA = false,
        AARRGGBB = false,
        rgb_fn = false,
        hsl_fn = false,
        css = false,
        css_fn = false,
        mode = "background",
        tailwind = false,
        sass = { enable = false },
        virtualtext = "■",
      },
      buftypes = {},
    },
  },
}
