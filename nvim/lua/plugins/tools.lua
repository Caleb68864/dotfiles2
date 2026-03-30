-- ============================================================================
-- Tools Plugins -- Testing, formatting, diagnostics, code outline, and more
-- ============================================================================
-- These are "power tools" that go beyond basic editing. They help you:
--   - Run tests and see results right in Neovim
--   - Automatically format code on save
--   - See all errors/warnings in a nice list
--   - View a code outline (like a table of contents for your code)
--   - Refactor code (rename, extract functions, etc.)
--   - Find and replace text across your entire project
--   - Track TODO/FIXME/HACK comments across your codebase
-- ============================================================================

return {
  -- =========================================================================
  -- Neotest -- Run tests and see results without leaving Neovim
  -- =========================================================================
  -- Neotest lets you run your test suite (or a single test) and see the
  -- results right inside the editor. Green check = passed, red X = failed.
  -- You can even debug a failing test by running it with the debugger attached.
  --
  -- Currently configured for Python (using pytest), but supports many
  -- languages through adapters.
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",              -- Utility library
      "nvim-treesitter/nvim-treesitter",    -- Understands code structure to find tests
      "antoinemadec/FixCursorHold.nvim",    -- Fixes a Neovim bug with CursorHold events
      "nvim-neotest/nvim-nio",              -- Async I/O library
      "nvim-neotest/neotest-python",        -- Python test adapter (pytest/unittest)
    },
    config = function()
      local neotest = require("neotest")
      neotest.setup({
        adapters = {
          -- Configure the Python test adapter
          require("neotest-python")({
            dap = { justMyCode = false },   -- When debugging tests, also step into library code
            args = { "--log-level", "DEBUG" },  -- Run pytest with DEBUG logging for more detail
            runner = "pytest",              -- Use pytest (not unittest) as the test runner
          }),
        },
        -- Custom icons shown next to tests in the UI
        icons = {
          running = "",    -- Spinning icon for tests currently running
          passed = "",     -- Green check for passed tests
          failed = "",     -- Red X for failed tests
        },
      })

      -- Test keymaps -- All start with Space+t (t for test)
      vim.keymap.set("n", "<leader>tt", function() neotest.run.run() end, { desc = "[t]est run neares[t]" })
        -- Space+t+t = run the NEAREST test to your cursor
      vim.keymap.set("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "[t]est run [f]ile" })
        -- Space+t+f = run ALL tests in the current file
      vim.keymap.set("n", "<leader>td", function() neotest.run.run({strategy = "dap"}) end, { desc = "[t]est [d]ebug nearest" })
        -- Space+t+d = run the nearest test with the DEBUGGER attached
        -- (so you can set breakpoints and step through the test)
      vim.keymap.set("n", "<leader>ts", function() neotest.summary.toggle() end, { desc = "[t]est [s]ummary" })
        -- Space+t+s = toggle the test SUMMARY panel (shows all tests and their status)
      vim.keymap.set("n", "<leader>to", function() neotest.output.open({ enter = true }) end, { desc = "[t]est [o]utput" })
        -- Space+t+o = show the OUTPUT of the last test run (print statements, errors, etc.)
      vim.keymap.set("n", "<leader>tO", function() neotest.output_panel.toggle() end, { desc = "[t]est [O]utput panel" })
        -- Space+t+O = toggle the output PANEL (persistent, stays open)
      vim.keymap.set("n", "<leader>tS", function() neotest.run.stop() end, { desc = "[t]est [S]top" })
        -- Space+t+S = STOP a currently running test
    end,
  },

  -- =========================================================================
  -- Conform -- Automatically format code on save
  -- =========================================================================
  -- When you save a file, Conform runs the appropriate code formatter to
  -- fix indentation, spacing, line length, and other style issues.
  -- Each programming language uses its own formatter tool.
  --
  -- This means you never have to worry about code style -- just write code
  -- and save, and it gets formatted perfectly every time.
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },  -- Load when opening any file
    config = function()
      require("conform").setup({
        -- Which formatter to use for each file type
        formatters_by_ft = {
          python = { "ruff_organize_imports", "ruff_format" },
            -- Python: first organize imports (sort/group them), then format the code
            -- Ruff is a super-fast Python linter/formatter written in Rust
          lua = { "stylua" },
            -- Lua: use StyLua to format Lua code (like this config!)
          javascript = { "prettier" },
            -- JavaScript: use Prettier (the standard JS formatter)
          typescript = { "prettier" },
            -- TypeScript: also Prettier
          json = { "prettier" },
            -- JSON: also Prettier (makes JSON files readable)
          yaml = { "prettier" },
            -- YAML: also Prettier
          markdown = { "prettier" },
            -- Markdown: also Prettier (fixes heading spacing, list formatting, etc.)
          sh = { "shfmt" },
            -- Shell scripts: use shfmt (shell format)
        },
        -- Automatically format every time you save a file
        format_on_save = {
          timeout_ms = 500,     -- Give the formatter up to 500ms to finish
          lsp_fallback = true,  -- If no formatter is configured, try using the LSP instead
        },
      })
    end,
  },

  -- =========================================================================
  -- Trouble -- A better list of errors, warnings, and other diagnostics
  -- =========================================================================
  -- The language server finds problems in your code (errors, warnings, hints).
  -- Trouble shows ALL of them in a clean, organized list at the bottom of
  -- the screen. You can click on any item to jump to that exact location.
  --
  -- Much better than squinting at tiny icons in the gutter trying to figure
  -- out what's wrong!
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      position = "bottom",              -- Show the list at the bottom of the screen
      height = 10,                      -- The panel is 10 lines tall
      icons = true,                     -- Show icons next to each diagnostic
      mode = "workspace_diagnostics",   -- Default: show problems from ALL files in the project
      fold_open = "",                 -- Icon for expanded groups
      fold_closed = "",                -- Icon for collapsed groups
      indent_lines = true,              -- Show indent lines for nested items
      auto_open = false,                -- Don't open automatically when problems are found
      auto_close = false,               -- Don't close automatically when all problems are fixed
      auto_preview = true,              -- Automatically preview the code when you highlight an item
      auto_fold = false,                -- Don't auto-collapse groups
      use_diagnostic_signs = true,      -- Use the same error/warning icons as the sign column
    },
    keys = {
      -- Space+x+x = toggle the Trouble panel open/closed
      { "<leader>xx", "<cmd>Trouble<CR>", desc = "Trouble toggle" },
      -- Space+x+w = show diagnostics from the WHOLE workspace (all files)
      { "<leader>xw", "<cmd>Trouble workspace_diagnostics<CR>", desc = "Trouble [w]orkspace diagnostics" },
      -- Space+x+d = show diagnostics from just the CURRENT document (file)
      { "<leader>xd", "<cmd>Trouble document_diagnostics<CR>", desc = "Trouble [d]ocument diagnostics" },
      -- Space+x+l = show the location list (results from certain commands)
      { "<leader>xl", "<cmd>Trouble loclist<CR>", desc = "Trouble [l]ocation list" },
      -- Space+x+q = show the quickfix list (results from grep, make, etc.)
      { "<leader>xq", "<cmd>Trouble quickfix<CR>", desc = "Trouble [q]uickfix" },
      -- gR = show all references to the symbol under cursor (using LSP)
      { "gR", "<cmd>Trouble lsp_references<CR>", desc = "Trouble LSP references" },
    },
  },

  -- =========================================================================
  -- Aerial -- A code outline sidebar (table of contents for your code)
  -- =========================================================================
  -- Aerial shows a sidebar with all the functions, classes, methods, and
  -- other symbols in the current file. It's like a table of contents that
  -- lets you quickly see the structure of a file and jump to any section.
  --
  -- Very useful for large files where scrolling takes too long.
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",  -- Uses treesitter to understand code structure
      "nvim-tree/nvim-web-devicons",       -- File type icons
    },
    keys = {
      -- Space+a = toggle the code outline sidebar
      { "<leader>a", "<cmd>AerialToggle!<CR>", desc = "[a]erial code outline" },
    },
    opts = {
      -- Where to get the list of symbols from (in order of preference):
      -- 1. Treesitter (best for most languages)
      -- 2. LSP (good fallback if treesitter doesn't support a language)
      -- 3. Markdown headers (for .md files)
      backends = { "treesitter", "lsp", "markdown" },
      layout = {
        max_width = { 40, 0.2 },          -- Max width: 40 chars or 20% of screen, whichever is less
        width = nil,                       -- Auto-calculate width
        min_width = 20,                    -- At least 20 characters wide
        default_direction = "prefer_right", -- Open the sidebar on the RIGHT side
      },
      attach_mode = "window",             -- Attach the outline to the current window
      filter_kind = false,                -- Show ALL symbol types (functions, variables, classes, etc.)
      show_guides = true,                 -- Show tree guide lines connecting parent/child symbols
      -- Characters used to draw the tree structure
      guides = {
        mid_item = "├─",         -- Branch connector for middle items
        last_item = "└─",       -- Branch connector for the last item
        nested_top = "│ ",      -- Vertical line for nested levels
        whitespace = "  ",       -- Spacing for indentation
      },
    },
  },

  -- =========================================================================
  -- Refactoring -- Automated code refactoring operations
  -- =========================================================================
  -- "Refactoring" means restructuring code without changing what it does.
  -- This plugin automates common refactoring operations:
  --   - Extract: pull selected code into a new function or variable
  --   - Inline: replace a variable/function with its value/body
  --   - Extract to file: move code to a separate file
  --
  -- These operations are things you COULD do by hand, but the plugin does
  -- them correctly and instantly, updating all references.
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("refactoring").setup({})

      -- Refactoring keymaps -- All start with Space+r (r for refactor)
      -- "x" mode means these work on SELECTED text (visual mode)
      vim.keymap.set("x", "<leader>re", ":Refactor extract ", { desc = "[r]efactor [e]xtract function" })
        -- Space+r+e = extract selected code into a NEW FUNCTION
      vim.keymap.set("x", "<leader>rf", ":Refactor extract_to_file ", { desc = "[r]efactor extract to [f]ile" })
        -- Space+r+f = extract selected code into a function in a NEW FILE
      vim.keymap.set("x", "<leader>rv", ":Refactor extract_var ", { desc = "[r]efactor extract [v]ariable" })
        -- Space+r+v = extract selected expression into a NEW VARIABLE
      vim.keymap.set({ "n", "x" }, "<leader>ri", ":Refactor inline_var", { desc = "[r]efactor [i]nline variable" })
        -- Space+r+i = INLINE a variable (replace the variable name with its value everywhere)
      vim.keymap.set("n", "<leader>rI", ":Refactor inline_func", { desc = "[r]efactor [I]nline function" })
        -- Space+r+I = INLINE a function (replace the function call with its body)
      vim.keymap.set("n", "<leader>rb", ":Refactor extract_block", { desc = "[r]efactor extract [b]lock" })
        -- Space+r+b = extract a code block into a new function
      vim.keymap.set("n", "<leader>rbf", ":Refactor extract_block_to_file", { desc = "[r]efactor extract [b]lock to [f]ile" })
        -- Space+r+b+f = extract a code block into a function in a new file
    end,
  },

  -- =========================================================================
  -- Spectre -- Find and replace text across your ENTIRE project
  -- =========================================================================
  -- Spectre is like a super-powered "Find and Replace" that works across
  -- ALL files in your project at once. It shows you every match, lets you
  -- preview what will change, and you can selectively include/exclude
  -- individual matches before replacing.
  --
  -- Very useful for renaming things that the LSP can't handle (like
  -- strings in comments, config files, etc.)
  {
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      -- Space+S = toggle the Spectre find-and-replace panel
      { "<leader>S", function() require("spectre").toggle() end, desc = "[S]pectre toggle" },
      -- Space+s+w = search for the word under your cursor across all files
      { "<leader>sw", function() require("spectre").open_visual({select_word=true}) end, desc = "[s]earch current [w]ord" },
      -- Space+s+w (visual mode) = search for whatever text you have selected
      { "<leader>sw", function() require("spectre").open_visual() end, mode = "v", desc = "[s]earch selection" },
      -- Space+s+p = search within just the CURRENT file (not the whole project)
      { "<leader>sp", function() require("spectre").open_file_search({select_word=true}) end, desc = "[s]earch in current file" },
    },
    config = function()
      require("spectre").setup({
        color_devicons = true,  -- Show colorful file type icons
        highlight = {
          ui = "String",         -- Color for the Spectre UI text
          search = "DiffChange", -- Color for search matches (yellowish)
          replace = "DiffDelete", -- Color for text that will be replaced (reddish)
        },
      })
    end,
  },

  -- =========================================================================
  -- Todo Comments -- Highlight and find TODO/FIXME/HACK comments
  -- =========================================================================
  -- Developers leave special comments in code like "TODO: fix this later"
  -- or "FIXME: this is broken" or "HACK: ugly workaround". This plugin:
  --   1. Highlights these comments with bright, distinct colors
  --   2. Shows an icon in the sign column (left margin)
  --   3. Lets you search for ALL todos across your project with Telescope
  --   4. Lets you jump between todos with ]t and [t
  --
  -- Makes it impossible to forget about things you need to fix!
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      -- ]t = jump to the NEXT todo comment in the file
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      -- [t = jump to the PREVIOUS todo comment in the file
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
      -- Space+f+t = use Telescope to search ALL todo comments in the project
      { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "[f]ind [t]odos" },
    },
    opts = {
      signs = true,          -- Show icons in the sign column (left margin)
      sign_priority = 8,     -- Priority for sign placement (higher = shown on top of other signs)

      -- Define the different types of special comments and how they look
      keywords = {
        FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
          -- FIX/FIXME/BUG = something is broken and needs fixing (red)
        TODO = { icon = " ", color = "info" },
          -- TODO = something that needs to be done later (blue)
        HACK = { icon = " ", color = "warning" },
          -- HACK = a workaround or ugly solution that should be improved (yellow)
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
          -- WARN/WARNING/XXX = something potentially dangerous or important to know (yellow)
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
          -- PERF/OPTIM = something that could be made faster (purple)
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
          -- NOTE/INFO = useful information for other developers (green)
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
          -- TEST = testing-related notes (yellow)
      },

      -- How todo comments are highlighted in the code
      highlight = {
        before = "",                          -- Don't highlight anything before the keyword
        keyword = "wide",                     -- Highlight the keyword AND surrounding space
        after = "fg",                         -- Highlight the text after the keyword with foreground color
        pattern = [[.*<(KEYWORDS)\s*:]],      -- The pattern to match: "KEYWORD:" with optional spaces
        comments_only = true,                 -- Only match inside actual comments (not in strings or code)
        max_line_len = 400,                   -- Don't check lines longer than 400 characters
        exclude = {},                         -- No file types excluded
      },
    },
  },

  -- =========================================================================
  -- Obsidian.nvim -- Edit Obsidian vaults natively in Neovim
  -- =========================================================================
  -- Adds Obsidian-aware features when editing markdown files in your vaults:
  --   - Follow [[wikilinks]] with gf
  --   - Autocomplete note names with [[
  --   - Create new notes from links that don't exist yet
  --   - Search notes by name or content
  --   - Open daily notes
  --
  -- The vault paths below must match your actual Obsidian vault locations.
  -- $OBSIDIAN_VAULT is set in .zshrc for the default (work) vault.
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    -- Only load when opening a markdown file inside a vault directory
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      workspaces = {
        { name = "Logic", path = "~/Documents/Notes/Logic" },
        { name = "Personal", path = "~/Documents/Notes/Caleb's Vault" },
      },
      -- Daily note settings (matches .obsidian/daily-notes.json in each vault)
      daily_notes = {
        folder = "Calendar Notes/Daily Notes",
        date_format = "%Y-%m-%d",
        template = "Daily Note - Template.md",
      },
      -- Where templates live
      templates = {
        folder = "Templates",
        date_format = "%Y-%m-%d",
      },
      -- Use Telescope for note searching
      picker = { name = "telescope.nvim" },
      -- Don't add frontmatter automatically — let Obsidian/Templater handle it
      disable_frontmatter = true,
      -- Follow wikilinks with gf
      follow_url_func = function(url)
        vim.fn.jobstart({ "xdg-open", url })
      end,
    },
    keys = {
      { "<leader>oo", "<cmd>ObsidianQuickSwitch<CR>", desc = "[o]bsidian [o]pen note" },
      { "<leader>os", "<cmd>ObsidianSearch<CR>", desc = "[o]bsidian [s]earch" },
      { "<leader>od", "<cmd>ObsidianToday<CR>", desc = "[o]bsidian [d]aily note" },
      { "<leader>ob", "<cmd>ObsidianBacklinks<CR>", desc = "[o]bsidian [b]acklinks" },
      { "<leader>on", "<cmd>ObsidianNew<CR>", desc = "[o]bsidian [n]ew note" },
      { "<leader>ol", "<cmd>ObsidianLinks<CR>", desc = "[o]bsidian [l]inks in note" },
      { "<leader>ot", "<cmd>ObsidianTags<CR>", desc = "[o]bsidian [t]ags" },
      { "<leader>ow", "<cmd>ObsidianWorkspace<CR>", desc = "[o]bsidian [w]orkspace switch" },
    },
  },
}
