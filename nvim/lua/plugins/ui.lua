-- ============================================================================
-- UI (User Interface) Plugins -- Make Neovim look nicer
-- ============================================================================
-- These plugins improve how Neovim looks without changing how it works.
-- They add a pretty statusline, show available keybindings, display
-- indent guides, and colorize hex color codes.
-- ============================================================================

return {
  -- =========================================================================
  -- Lualine -- A fancy statusline at the bottom of the screen
  -- =========================================================================
  -- The statusline shows useful info about your current state:
  --   - What MODE you're in (Normal, Insert, Visual, etc.)
  --   - The file name you're editing
  --   - Git branch name
  --   - Error/warning counts from the language server
  --   - File type, encoding, cursor position, etc.
  -- Lualine makes this look much prettier than the default statusline.
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },  -- File type icons in the statusline
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",         -- Use Tokyo Night colors to match our colorscheme
          component_separators = "|",   -- Use a simple pipe character between sections
          section_separators = "",      -- No fancy arrow separators between major sections
                                        -- (cleaner, simpler look)
        },
      })
    end,
  },

  -- =========================================================================
  -- Which-Key -- Shows available keybindings in a popup
  -- =========================================================================
  -- When you press a key like Space (the leader key) and then WAIT,
  -- which-key pops up a menu showing ALL the possible next keys you can
  -- press and what they do. This is incredible for learning keybindings
  -- because you don't have to memorize everything -- just press Space
  -- and the cheat sheet appears!
  --
  -- For example, pressing Space shows: f = Find, g = Git, p = Pi, etc.
  -- Then pressing f shows: f = files, g = grep, b = buffers, etc.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",  -- Load after startup (not needed immediately)
    init = function()
      -- These settings control how long you have to wait before which-key
      -- shows up. "timeout = true" enables the timeout, and 300ms means
      -- if you pause for 300ms after pressing the first key, the popup appears.
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    config = function()
      local wk = require("which-key")
      wk.setup({})
      -- Register group NAMES so which-key shows descriptive labels
      -- instead of just listing individual keymaps.
      -- For example, when you press Space, it shows "f = Find" instead
      -- of listing every Space+f+? keymap individually.
      wk.register({
        ["<leader>f"] = { name = "Find" },           -- Space+f = Find things (Telescope)
        ["<leader>g"] = { name = "Git" },             -- Space+g = Git operations
        ["<leader>p"] = { name = "Pi" },              -- Space+p = Pi AI assistant
        ["<leader>t"] = { name = "Test" },            -- Space+t = Testing (Neotest)
        ["<leader>x"] = { name = "Trouble" },         -- Space+x = Trouble diagnostics
        ["<leader>r"] = { name = "Refactor" },        -- Space+r = Refactoring tools
        ["<leader>d"] = { name = "Debug" },           -- Space+d = Debugging
        ["<leader>y"] = { name = "Yank" },            -- Space+y = Yank (copy) paths
        ["<leader>h"] = { name = "Harpoon" },         -- Space+h = Harpoon file bookmarks
        ["<leader>s"] = { name = "Search/Replace" },  -- Space+s = Search and replace (Spectre)
        ["<leader>w"] = { name = "Workspace" },       -- Space+w = Workspace management
      })
    end,
  },

  -- =========================================================================
  -- Indent Blankline -- Show vertical lines for indentation levels
  -- =========================================================================
  -- This draws thin vertical lines at each indentation level so you can
  -- easily see which code belongs to which block. For example, you can
  -- visually trace from an "if" statement down to its "end" by following
  -- the indent guide line.
  --
  -- The "scope" feature highlights the indent guide for the block your
  -- cursor is currently inside, making it even easier to see context.
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",  -- The module name to require (it's "ibl", not "indent-blankline")
    opts = {
      indent = { char = "│" },          -- The character used for indent lines (thin vertical bar)
      scope = { enabled = true },       -- Highlight the indent guide for the current scope
    },
  },

  -- =========================================================================
  -- Colorizer -- Display hex color codes with their actual color
  -- =========================================================================
  -- When you write a color code like #7aa2f7 in a file, this plugin shows
  -- the actual color as a background highlight on that text. Super useful
  -- when editing CSS, theme files, or any config that uses colors.
  -- Without this, you'd have to look up every hex code to know what
  -- color it actually is.
  {
    "NvChad/nvim-colorizer.lua",
    opts = {
      filetypes = { "*" },  -- Enable in ALL file types
      user_default_options = {
        RGB = true,         -- Colorize short hex like #FFF (3 digits)
        RRGGBB = true,      -- Colorize full hex like #7aa2f7 (6 digits)
        names = false,       -- Don't colorize color names like "Blue" (too many false positives)
        RRGGBBAA = false,    -- Don't colorize 8-digit hex (with alpha channel)
        AARRGGBB = false,    -- Don't colorize ARGB format
        rgb_fn = false,      -- Don't colorize rgb() CSS functions
        hsl_fn = false,      -- Don't colorize hsl() CSS functions
        css = false,         -- Don't enable full CSS color parsing
        css_fn = false,      -- Don't colorize CSS color functions
        mode = "background", -- Show colors as BACKGROUND highlight on the text
                             -- (other option is "foreground" which colors the text itself)
        tailwind = false,    -- Don't parse Tailwind CSS color classes
        sass = { enable = false },  -- Don't parse Sass color variables
        virtualtext = "■",  -- When using virtualtext mode, show this square character
      },
      buftypes = {},  -- No restrictions on buffer types
    },
  },
}
