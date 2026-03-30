-- ============================================================================
-- Editor Plugins -- Tools that enhance everyday editing and file navigation
-- ============================================================================
-- This is the biggest plugin file. It contains plugins that make the core
-- editing experience better: file explorer, fuzzy finder, bookmarks, file
-- manager integration, auto-pairs, commenting, code folding, and more.
-- ============================================================================

return {
  -- =========================================================================
  -- NvimTree -- A file explorer sidebar (like the one in VS Code)
  -- =========================================================================
  -- Shows your project's files and folders in a tree on the left side.
  -- You can browse, open, rename, delete, and create files from here.
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },  -- Adds file type icons (folder, Python, etc.)
    keys = {
      -- Space+e = toggle the file explorer open/closed
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file [e]xplorer" },
    },
    config = function()
      require("nvim-tree").setup({
        view = { width = 35 },            -- The tree panel is 35 characters wide
        renderer = {
          group_empty = true,              -- Collapse folders that only contain one subfolder
                                           -- (shows "src/utils" instead of "src" > "utils")
          icons = { show = { git = true } },  -- Show git status icons (modified, added, etc.)
        },
        filters = { dotfiles = false },    -- Show hidden files (files starting with .)
      })
    end,
  },

  -- =========================================================================
  -- Telescope -- A fuzzy finder for files, text, and more
  -- =========================================================================
  -- Telescope is one of the most-used plugins. It lets you quickly find
  -- anything by typing a few characters. It uses "fuzzy matching" so you
  -- don't need to type exact names -- "kmp" would match "keymaps.lua".
  --
  -- Uses: find files, search text across your project, switch buffers,
  -- browse help docs, find recent files, and much more.
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",  -- Use the stable 0.1 branch
    dependencies = {
      "nvim-lua/plenary.nvim",  -- Utility library (required by many plugins)
      -- fzf-native makes Telescope MUCH faster by using a compiled C program
      -- for the fuzzy matching instead of pure Lua.
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              -- Disable Ctrl+U and Ctrl+D in Telescope's insert mode
              -- (they conflict with other keymaps we prefer)
              ["<C-u>"] = false,
              ["<C-d>"] = false,
            },
          },
        },
      })
      -- Try to load the fzf extension for faster searching.
      -- "pcall" means "try this, and if it fails, don't crash" (safe call).
      pcall(require("telescope").load_extension, "fzf")

      -- Telescope keymaps -- All start with Space+f (f for find)
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[f]ind [f]iles" })
        -- Space+f+f = find files by name in your project
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[f]ind by [g]rep" })
        -- Space+f+g = search for TEXT inside all files (like grep)
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[f]ind [b]uffers" })
        -- Space+f+b = switch between open files (buffers)
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[f]ind [h]elp" })
        -- Space+f+h = search Neovim's help documentation
      vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "[f]ind [r]ecent files" })
        -- Space+f+r = find recently opened files
      vim.keymap.set("n", "<leader>fs", builtin.grep_string, { desc = "[f]ind [s]tring under cursor" })
        -- Space+f+s = search for the word under your cursor across all files
    end,
  },

  -- =========================================================================
  -- Harpoon 2 -- Bookmark your most-used files for instant switching
  -- =========================================================================
  -- Harpoon lets you "pin" up to 4 files and instantly jump between them
  -- with a single keystroke. Much faster than using Telescope or the file
  -- explorer for files you edit constantly.
  --
  -- Think of it like browser bookmarks, but for code files.
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",  -- Use the newer, rewritten version
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      -- Space+h+a = ADD the current file to your harpoon list
      vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "[h]arpoon [a]dd file" })
      -- Space+h+l = show the LIST of harpooned files (you can reorder/remove here)
      vim.keymap.set("n", "<leader>hl", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "[h]arpoon [l]ist" })
      -- Space+1 through Space+4 = jump INSTANTLY to harpooned file 1, 2, 3, or 4
      vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
      vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
      vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
      vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })
    end,
  },

  -- =========================================================================
  -- Yazi -- Open the Yazi terminal file manager inside Neovim
  -- =========================================================================
  -- Yazi is a fast terminal file manager (like Ranger). This plugin lets
  -- you open it right inside Neovim as a floating window. You can browse
  -- files, preview them, and open them without leaving Neovim.
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",  -- Load only when first needed (not at startup)
    keys = {
      -- Space+y = open Yazi showing the CURRENT file's directory
      { "<leader>y", "<cmd>Yazi<CR>", desc = "[y]azi (current file)" },
      -- Space+Y = open Yazi showing the project's working directory
      { "<leader>Y", "<cmd>Yazi cwd<CR>", desc = "[Y]azi (working dir)" },
    },
    opts = {
      -- If you open Neovim on a directory (like "nvim ."), open Yazi
      -- instead of the default directory listing.
      open_for_directories = true,
    },
  },

  -- =========================================================================
  -- Surround -- Easily add, change, or delete surrounding characters
  -- =========================================================================
  -- Lets you work with "surrounding" characters like quotes, brackets, tags.
  -- Examples:
  --   cs"'  = change surrounding double quotes to single quotes
  --   ds"   = delete surrounding double quotes
  --   ysiw" = add double quotes around the current word
  --   S"    = in visual mode, surround selection with double quotes
  {
    "kylechui/nvim-surround",
    version = "*",          -- Use the latest stable release
    event = "VeryLazy",     -- Load only when first needed
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  -- =========================================================================
  -- Autopairs -- Automatically close brackets, quotes, etc.
  -- =========================================================================
  -- When you type an opening character like ( or " or {, this plugin
  -- automatically inserts the matching closing character ) or " or }.
  -- Your cursor is placed between them so you can type inside.
  -- Saves a LOT of keystrokes and prevents mismatched brackets.
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",  -- Only load when you start typing (enter insert mode)
    opts = {},              -- Use default settings
  },

  -- =========================================================================
  -- Comment -- Easily comment/uncomment code
  -- =========================================================================
  -- Press "gcc" to comment/uncomment the current line.
  -- In visual mode, press "gc" to comment/uncomment the selection.
  -- It automatically uses the right comment syntax for each language
  -- (// for JavaScript, # for Python, -- for Lua, etc.)
  {
    "numToStr/Comment.nvim",
    opts = {},  -- Use default settings
  },

  -- =========================================================================
  -- Better Escape -- Exit insert mode faster
  -- =========================================================================
  -- In Vim, you press Escape to leave insert mode and go back to normal mode.
  -- But Escape is far from the home row. This plugin lets you type "jk" or
  -- "jj" quickly to escape instead (configurable). Much faster and more
  -- ergonomic since your fingers don't have to move far.
  {
    "max397574/better-escape.nvim",
    config = function()
      require("better_escape").setup()
    end,
  },

  -- =========================================================================
  -- UFO -- Better code folding (collapsing sections of code)
  -- =========================================================================
  -- "Folding" means collapsing a section of code (like a whole function)
  -- into a single line, so you can focus on the big picture without seeing
  -- every detail. UFO makes folding smarter by using Treesitter to understand
  -- code structure (it knows where functions and classes start and end).
  {
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",         -- Async library UFO needs
      "nvim-treesitter/nvim-treesitter",    -- Treesitter powers the smart folding
    },
    config = function()
      -- Show a "fold column" on the left edge (shows fold indicators)
      vim.o.foldcolumn = "1"
      -- Start with ALL folds open (level 99 = basically everything unfolded).
      -- Without this, opening a file would show everything collapsed.
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      -- Enable folding in general
      vim.o.foldenable = true

      require("ufo").setup({
        -- Use Treesitter first to figure out where folds should be,
        -- and fall back to indentation-based folding if Treesitter
        -- doesn't work for a file type.
        provider_selector = function(bufnr, filetype, buftype)
          return { "treesitter", "indent" }
        end,
      })

      -- Fold keymaps (z is the traditional Vim fold key prefix)
      vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
        -- zR = unfold EVERYTHING in the file
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
        -- zM = fold EVERYTHING in the file
      vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds except kinds" })
        -- zr = open most folds but keep some closed
      vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "Close folds with" })
        -- zm = close folds at a certain depth level
    end,
  },

  -- =========================================================================
  -- Flash -- Jump anywhere on screen with labeled keystrokes
  -- =========================================================================
  -- Type s + 2 chars to search, then a label key to jump directly there.
  -- Much faster than f/t// for moving around. Works across windows too.
  -- In operator-pending mode (d, y, c), use s to jump-select text.
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter select" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Flash remote (operator)" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash search" },
    },
    opts = {},
  },

  -- =========================================================================
  -- Undotree -- Visual undo history with branches
  -- =========================================================================
  -- Vim's undo is a tree, not a line — if you undo then make a new edit,
  -- the old branch isn't gone, but it's invisible without this plugin.
  -- Undotree shows every branch so you never lose work.
  {
    "mbbill/undotree",
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "[u]ndotree toggle" },
    },
  },

  -- =========================================================================
  -- Zen Mode -- Distraction-free writing/coding
  -- =========================================================================
  -- Strips away the file explorer, status bar, line numbers, and centers
  -- the buffer. Great for focused editing on small screens (like a tablet).
  {
    "folke/zen-mode.nvim",
    keys = {
      { "<leader>z", "<cmd>ZenMode<CR>", desc = "[z]en mode toggle" },
    },
    opts = {
      window = {
        width = 90,          -- Centered column width
        options = {
          number = false,
          relativenumber = false,
          signcolumn = "no",
        },
      },
      plugins = {
        tmux = { enabled = true },   -- Hide tmux status bar in zen mode
      },
    },
  },

  -- =========================================================================
  -- Vim-Tmux Navigator -- Move between Neovim and Tmux seamlessly
  -- =========================================================================
  -- If you use Tmux (a terminal multiplexer that lets you have multiple
  -- terminal panes), this plugin lets you use the SAME keys (Ctrl+h/j/k/l)
  -- to move between Neovim splits AND Tmux panes. Without this, you'd need
  -- different keys for Neovim splits vs Tmux panes, which is confusing.
  --
  -- Ctrl+H = move left, Ctrl+J = move down, Ctrl+K = move up, Ctrl+L = move right
  -- These work whether you're moving between Neovim windows or Tmux panes!
  {
    "christoomey/vim-tmux-navigator",
    -- Only load this plugin when one of these commands is triggered
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    -- The keymaps that trigger the commands above
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },     -- Ctrl+H = move left
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },     -- Ctrl+J = move down
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },       -- Ctrl+K = move up
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },    -- Ctrl+L = move right
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" }, -- Ctrl+\ = go to previous pane
    },
  },
}
