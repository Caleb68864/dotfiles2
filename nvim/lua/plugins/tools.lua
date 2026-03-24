return {
  -- Neotest - Modern test runner with UI
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/nvim-nio",
      "nvim-neotest/neotest-python",
    },
    config = function()
      local neotest = require("neotest")
      neotest.setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
            args = { "--log-level", "DEBUG" },
            runner = "pytest",
          }),
        },
        icons = {
          running = "",
          passed = "",
          failed = "",
        },
      })

      vim.keymap.set("n", "<leader>tt", function() neotest.run.run() end, { desc = "[t]est run neares[t]" })
      vim.keymap.set("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "[t]est run [f]ile" })
      vim.keymap.set("n", "<leader>td", function() neotest.run.run({strategy = "dap"}) end, { desc = "[t]est [d]ebug nearest" })
      vim.keymap.set("n", "<leader>ts", function() neotest.summary.toggle() end, { desc = "[t]est [s]ummary" })
      vim.keymap.set("n", "<leader>to", function() neotest.output.open({ enter = true }) end, { desc = "[t]est [o]utput" })
      vim.keymap.set("n", "<leader>tO", function() neotest.output_panel.toggle() end, { desc = "[t]est [O]utput panel" })
      vim.keymap.set("n", "<leader>tS", function() neotest.run.stop() end, { desc = "[t]est [S]top" })
    end,
  },

  -- Conform.nvim - Modern formatter
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python = { "ruff_organize_imports", "ruff_format" },
          lua = { "stylua" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
          sh = { "shfmt" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
    end,
  },

  -- Trouble - Better diagnostics UI
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      position = "bottom",
      height = 10,
      icons = true,
      mode = "workspace_diagnostics",
      fold_open = "",
      fold_closed = "",
      indent_lines = true,
      auto_open = false,
      auto_close = false,
      auto_preview = true,
      auto_fold = false,
      use_diagnostic_signs = true,
    },
    keys = {
      { "<leader>xx", "<cmd>Trouble<CR>", desc = "Trouble toggle" },
      { "<leader>xw", "<cmd>Trouble workspace_diagnostics<CR>", desc = "Trouble [w]orkspace diagnostics" },
      { "<leader>xd", "<cmd>Trouble document_diagnostics<CR>", desc = "Trouble [d]ocument diagnostics" },
      { "<leader>xl", "<cmd>Trouble loclist<CR>", desc = "Trouble [l]ocation list" },
      { "<leader>xq", "<cmd>Trouble quickfix<CR>", desc = "Trouble [q]uickfix" },
      { "gR", "<cmd>Trouble lsp_references<CR>", desc = "Trouble LSP references" },
    },
  },

  -- Aerial - Code outline sidebar
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>a", "<cmd>AerialToggle!<CR>", desc = "[a]erial code outline" },
    },
    opts = {
      backends = { "treesitter", "lsp", "markdown" },
      layout = {
        max_width = { 40, 0.2 },
        width = nil,
        min_width = 20,
        default_direction = "prefer_right",
      },
      attach_mode = "window",
      filter_kind = false,
      show_guides = true,
      guides = {
        mid_item = "├─",
        last_item = "└─",
        nested_top = "│ ",
        whitespace = "  ",
      },
    },
  },

  -- Refactoring - Automated refactoring operations
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("refactoring").setup({})

      vim.keymap.set("x", "<leader>re", ":Refactor extract ", { desc = "[r]efactor [e]xtract function" })
      vim.keymap.set("x", "<leader>rf", ":Refactor extract_to_file ", { desc = "[r]efactor extract to [f]ile" })
      vim.keymap.set("x", "<leader>rv", ":Refactor extract_var ", { desc = "[r]efactor extract [v]ariable" })
      vim.keymap.set({ "n", "x" }, "<leader>ri", ":Refactor inline_var", { desc = "[r]efactor [i]nline variable" })
      vim.keymap.set("n", "<leader>rI", ":Refactor inline_func", { desc = "[r]efactor [I]nline function" })
      vim.keymap.set("n", "<leader>rb", ":Refactor extract_block", { desc = "[r]efactor extract [b]lock" })
      vim.keymap.set("n", "<leader>rbf", ":Refactor extract_block_to_file", { desc = "[r]efactor extract [b]lock to [f]ile" })
    end,
  },

  -- Spectre - Project-wide find and replace
  {
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>S", function() require("spectre").toggle() end, desc = "[S]pectre toggle" },
      { "<leader>sw", function() require("spectre").open_visual({select_word=true}) end, desc = "[s]earch current [w]ord" },
      { "<leader>sw", function() require("spectre").open_visual() end, mode = "v", desc = "[s]earch selection" },
      { "<leader>sp", function() require("spectre").open_file_search({select_word=true}) end, desc = "[s]earch in current file" },
    },
    config = function()
      require("spectre").setup({
        color_devicons = true,
        highlight = {
          ui = "String",
          search = "DiffChange",
          replace = "DiffDelete",
        },
      })
    end,
  },

  -- Todo Comments - Highlight and search TODO comments
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
      { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "[f]ind [t]odos" },
    },
    opts = {
      signs = true,
      sign_priority = 8,
      keywords = {
        FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
      highlight = {
        before = "",
        keyword = "wide",
        after = "fg",
        pattern = [[.*<(KEYWORDS)\s*:]],
        comments_only = true,
        max_line_len = 400,
        exclude = {},
      },
    },
  },
}
