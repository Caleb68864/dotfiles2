-- ============================================================================
-- Treesitter Plugin -- Makes Neovim understand your code's structure
-- ============================================================================
-- Treesitter is like giving Neovim a brain that can READ and UNDERSTAND code.
-- Without treesitter, Neovim just sees text and uses simple rules (regex) to
-- guess what's a keyword, string, comment, etc. With treesitter, Neovim
-- builds a real "syntax tree" -- a map of your code's structure.
--
-- This gives us:
--   - MUCH better syntax highlighting (colors are more accurate)
--   - Smart indentation (it knows where code blocks start and end)
--   - Smart text selection (select a whole function with a keystroke)
--   - Powers other plugins like code folding, refactoring, and more
-- ============================================================================

return {
  -- The plugin from GitHub
  "nvim-treesitter/nvim-treesitter",

  -- After installing or updating treesitter, run ":TSUpdate" to download/update
  -- the language parsers (the things that understand each programming language).
  build = ":TSUpdate",

  config = function()
    require("nvim-treesitter.configs").setup({
      -- These are the programming languages we want treesitter to understand.
      -- It will automatically download a "parser" (language brain) for each one.
      ensure_installed = {
        "python",           -- For Python development
        "c_sharp",          -- For C# / .NET development
        "lua",              -- For editing this very Neovim config!
        "vim",              -- For Vim script (legacy Neovim config language)
        "vimdoc",           -- For reading Neovim help files
        "query",            -- For treesitter query files themselves
        "javascript",       -- For web development
        "typescript",       -- For web development (typed JavaScript)
        "html",             -- For web pages
        "css",              -- For web styling
        "json",             -- For config files and data
        "bash",             -- For shell scripts
        "markdown",         -- For documentation files
        "markdown_inline",  -- For inline markdown elements (bold, links, etc.)
        "regex"             -- For understanding regular expressions
      },

      -- If you open a file type that's not in the list above, treesitter will
      -- automatically download its parser. No need to manually add every language.
      auto_install = true,

      -- Use treesitter for syntax highlighting (coloring code).
      -- This replaces Neovim's old regex-based highlighting with much smarter,
      -- more accurate colors.
      highlight = { enable = true },

      -- Use treesitter to figure out how to indent code.
      -- When you press Enter, treesitter knows if you're inside a function,
      -- loop, etc. and indents accordingly.
      indent = { enable = true },

      -- Incremental selection: press a key to select bigger and bigger chunks
      -- of code based on the syntax tree.
      incremental_selection = {
        enable = true,
        keymaps = {
          -- Ctrl+Space = start selecting the smallest unit (like a word),
          -- then press Ctrl+Space again to expand to the expression,
          -- then the statement, then the function, then the whole file.
          -- It's like zooming out your selection each time.
          init_selection = "<C-space>",     -- First press: start selection
          node_incremental = "<C-space>",   -- Next presses: grow selection
          scope_incremental = false,        -- Disabled: don't use scope-based expansion
          node_decremental = "<bs>",        -- Backspace: shrink selection back down
        },
      },
    })
  end,
}
