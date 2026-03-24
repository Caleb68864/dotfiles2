-- ============================================================================
-- Completion Plugin (nvim-cmp) -- Smart autocomplete as you type
-- ============================================================================
-- nvim-cmp is the autocomplete engine. As you type code, it shows a popup
-- menu with suggestions from multiple sources:
--   - The language server (knows about your functions, variables, types)
--   - Snippets (pre-written code templates you can expand)
--   - Words from the current file (buffer)
--   - File paths on your computer
--
-- Think of it like your phone's autocomplete keyboard, but for code.
-- It even knows about function signatures and documentation!
-- ============================================================================

return {
  -- The main completion plugin
  "hrsh7th/nvim-cmp",

  -- These are the "sources" that feed suggestions into nvim-cmp.
  -- Each one provides a different kind of suggestion.
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",          -- Suggestions from the language server (smartest source)
    "hrsh7th/cmp-buffer",            -- Suggestions from words already in your current file
    "hrsh7th/cmp-path",              -- Suggestions for file/folder paths (like ~/Documents/...)
    "hrsh7th/cmp-cmdline",           -- Suggestions for Neovim's command line (:commands)
    "L3MON4D3/LuaSnip",             -- The snippet engine (expands code templates)
    "saadparwaiz1/cmp_luasnip",      -- Connects LuaSnip to nvim-cmp
    "rafamadriz/friendly-snippets",  -- A big collection of pre-made snippets for many languages
  },

  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    -- Load all the pre-made snippets from friendly-snippets.
    -- "lazy_load" means they load on demand (only when you open a Python file
    -- do the Python snippets load, etc.)
    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      -- How to expand snippets when you select one from the menu.
      -- When you pick a snippet, LuaSnip takes over and expands it,
      -- putting your cursor in the right spots to fill in the blanks.
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      -- KEYMAPS for the completion menu
      -- These control how you interact with the autocomplete popup.
      mapping = cmp.mapping.preset.insert({
        -- Ctrl+B = scroll UP in the documentation popup (B = back)
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),

        -- Ctrl+F = scroll DOWN in the documentation popup (F = forward)
        ["<C-f>"] = cmp.mapping.scroll_docs(4),

        -- Ctrl+Space = manually trigger the completion menu
        -- (useful if it didn't appear automatically)
        ["<C-Space>"] = cmp.mapping.complete(),

        -- Ctrl+E = close/dismiss the completion menu without picking anything
        ["<C-e>"] = cmp.mapping.abort(),

        -- Enter = accept the currently highlighted suggestion.
        -- "select = true" means if nothing is highlighted, it picks the first item.
        ["<CR>"] = cmp.mapping.confirm({ select = true }),

        -- Tab = smart tab behavior:
        --   1. If the completion menu is visible, move to the NEXT item
        --   2. If you're inside a snippet, jump to the NEXT placeholder
        --   3. Otherwise, just insert a regular Tab character
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()  -- Insert a normal Tab
          end
        end, { "i", "s" }),  -- Works in insert mode and snippet mode

        -- Shift+Tab = same as Tab but in REVERSE:
        --   1. If menu is visible, move to the PREVIOUS item
        --   2. If in a snippet, jump to the PREVIOUS placeholder
        --   3. Otherwise, just do normal Shift+Tab
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),

      -- WHERE the suggestions come from, in PRIORITY ORDER.
      -- The first group is higher priority. If items from "nvim_lsp" are
      -- available, they'll appear above items from "buffer".
      sources = cmp.config.sources({
        { name = "nvim_lsp" },   -- Language server suggestions (highest priority)
        { name = "luasnip" },    -- Snippet suggestions
        { name = "buffer" },     -- Words from the current file
        { name = "path" },       -- File path suggestions
      }),
    })
  end,
}
