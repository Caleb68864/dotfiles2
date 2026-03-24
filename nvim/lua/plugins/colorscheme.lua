-- ============================================================================
-- Colorscheme Plugin -- Makes Neovim look pretty with Tokyo Night colors
-- ============================================================================
-- This plugin provides the "Tokyo Night" color theme, which is a dark theme
-- with blue/purple tones inspired by Tokyo city lights at night.
-- It controls ALL the colors you see: background, text, keywords, strings,
-- comments, the statusline, and everything else.
--
-- This is the SAME Tokyo Night theme used across the whole system (Hyprland,
-- Waybar, Kitty terminal, etc.) so everything looks consistent.
-- ============================================================================

return {
  -- The plugin: folke/tokyonight.nvim from GitHub
  "folke/tokyonight.nvim",

  -- priority = 1000 means "load this plugin FIRST, before almost everything else."
  -- Why? Because other plugins need to know what colors to use. If the
  -- colorscheme loads late, you'd see ugly default colors flash briefly
  -- before the real theme kicks in.
  priority = 1000,

  -- "config" runs after the plugin is loaded. This is where we set it up.
  config = function()
    require("tokyonight").setup({
      -- "night" is the darkest variant. Other options are:
      --   "storm" = slightly lighter dark blue background
      --   "moon"  = medium dark with more contrast
      --   "night" = darkest, deepest background (#1a1b26)
      style = "night",

      -- Don't make the background transparent (show the theme's own background
      -- color instead of letting the terminal background show through).
      transparent = false,

      -- Apply Tokyo Night colors to the built-in terminal too (when you open
      -- a terminal inside Neovim with :terminal).
      terminal_colors = true,

      -- Control how different code elements look:
      styles = {
        comments = { italic = true },   -- Comments are italicized to stand out
        keywords = { italic = true },   -- Keywords (if, for, return) are also italic
        functions = {},                  -- Functions use default style (no special formatting)
        variables = {},                  -- Variables use default style too
      },
    })

    -- Actually APPLY the colorscheme. The setup() above configures it,
    -- but this line is what switches Neovim to use it.
    vim.cmd.colorscheme("tokyonight")
  end,
}
