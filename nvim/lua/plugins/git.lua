-- ============================================================================
-- Git Plugins -- Tools for working with Git version control inside Neovim
-- ============================================================================
-- Git is the version control system that tracks changes to your code.
-- These plugins bring Git features directly into Neovim so you don't have
-- to leave your editor to see changes, view history, or manage commits.
-- ============================================================================

return {
  -- =========================================================================
  -- Gitsigns -- Show git changes in the left margin (gutter)
  -- =========================================================================
  -- This plugin puts little symbols next to line numbers to show what has
  -- changed since the last git commit:
  --   + = a new line was ADDED
  --   ~ = a line was CHANGED (modified)
  --   _ = a line was DELETED (shown at the line above where it was)
  --   ~ = a line was changed AND something was deleted here
  -- This gives you an at-a-glance view of what you've modified.
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },           -- New line added
        change = { text = "~" },         -- Existing line modified
        delete = { text = "_" },         -- Line deleted (underscore at the line above)
        topdelete = { text = "‾" },      -- Line deleted at the top of a block (overline)
        changedelete = { text = "~" },   -- Line changed AND something deleted here
      },
    },
  },

  -- =========================================================================
  -- Diffview -- A full-screen Git diff viewer and history browser
  -- =========================================================================
  -- Diffview shows you a side-by-side comparison of your changes, lets you
  -- browse the history of a file or the whole repo, and helps resolve
  -- merge conflicts with a visual UI.
  --
  -- Much nicer than reading raw "git diff" output in the terminal!
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      -- Space+g+d = open diffview showing ALL uncommitted changes
      { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "[g]it [d]iffview open" },
      -- Space+g+c = close the diffview window
      { "<leader>gc", "<cmd>DiffviewClose<CR>", desc = "[g]it diffview [c]lose" },
      -- Space+g+h = show the git history of the CURRENT file
      -- (see every commit that changed this file)
      { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "[g]it file [h]istory" },
      -- Space+g+H = show the git history of the ENTIRE repository
      { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "[g]it repo [H]istory" },
    },
    config = function()
      require("diffview").setup()
    end,
  },

  -- =========================================================================
  -- Lazygit -- A beautiful terminal Git UI, right inside Neovim
  -- =========================================================================
  -- Lazygit is a standalone terminal app for managing Git. This plugin opens
  -- it in a floating window inside Neovim. From Lazygit you can:
  --   - Stage and unstage files
  --   - Write commit messages and commit
  --   - Push and pull
  --   - Browse branches
  --   - Resolve conflicts
  --   - And much more, all with keyboard shortcuts
  -- It's like a visual Git GUI but stays in the terminal.
  {
    "kdheepak/lazygit.nvim",
    -- Only load if the lazygit binary is actually installed. Without this the
    -- keybinding exists but fails with a confusing error.
    cond = require("config.platform").has("lazygit"),
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      -- Space+l+g = open Lazygit in a floating window
      { "<leader>lg", "<cmd>LazyGit<CR>", desc = "[l]azy[g]it" },
    },
  },
}
