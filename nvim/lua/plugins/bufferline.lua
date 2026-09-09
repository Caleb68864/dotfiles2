-- ============================================================================
-- Bufferline -- clickable file tabs across the top, like VSCode
-- ============================================================================
-- Neovim tracks open files as "buffers", which are invisible by default --
-- you switch between them with commands. Bufferline draws them as tabs you
-- can actually see and click:
--   left-click   switch to that file
--   middle-click close that file
--   drag         reorder the tabs
--
-- This is the single biggest change that makes Neovim behave the way a
-- mouse-driven editor is expected to behave.
-- ============================================================================

return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },  -- File type icons on each tab
  event = "VeryLazy",  -- Load after startup so it never slows opening a file
  opts = {
    options = {
      mode = "buffers",                 -- Show buffers as tabs (not vim "tab pages")
      diagnostics = "nvim_lsp",         -- Show an error/warning count on each tab
      separator_style = "slant",
      show_buffer_close_icons = true,   -- The little x on each tab
      show_close_icon = false,          -- No global close button in the corner
      always_show_bufferline = true,

      -- Mouse behaviour. %d is filled in with the buffer number by bufferline.
      left_mouse_command = "buffer %d",     -- Click a tab to switch to it
      middle_mouse_command = "bdelete! %d", -- Middle-click a tab to close it
      -- Disable right-click's default action (close buffer). Bufferline defaults
      -- right_mouse_command to "bdelete! %d", which closes the file. We set it to
      -- false to prevent accidental closes; a context menu is coming in the next task.
      right_mouse_command = false,

      -- Reserve space on the left for the nvim-tree file explorer, so the
      -- tabs start BESIDE the tree instead of running underneath it. Without
      -- this the whole thing looks broken whenever the tree is open.
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          text_align = "left",
          separator = true,
        },
      },
    },
  },
}
