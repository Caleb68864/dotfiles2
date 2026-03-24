-- ============================================================================
-- LSP (Language Server Protocol) Plugins
-- ============================================================================
-- LSP is what makes Neovim act like a real IDE (like VS Code). A "language
-- server" is a background program that understands a programming language
-- deeply. It provides:
--   - Error checking (red squiggles under mistakes)
--   - Autocomplete suggestions
--   - "Go to definition" (jump to where a function is defined)
--   - "Find references" (find everywhere a function is used)
--   - Renaming variables across your whole project
--   - Hover documentation (see what a function does)
--   - Code actions (quick fixes and refactorings)
--
-- This file sets up THREE plugins that work together:
--   1. nvim-lspconfig   -- Tells Neovim how to talk to language servers
--   2. mason.nvim       -- Automatically INSTALLS language servers for you
--   3. mason-lspconfig  -- Connects mason and lspconfig together
-- Plus "fidget" which shows a little spinner when the LSP is working.
-- ============================================================================

return {
  -- =========================================================================
  -- LSP Core -- The main plugin that configures language servers
  -- =========================================================================
  -- This plugin knows how to configure dozens of language servers.
  -- It doesn't install them -- that's mason's job. It just knows how
  -- to start them and talk to them.
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",          -- Installs language servers
      "williamboman/mason-lspconfig.nvim", -- Bridges mason and lspconfig
      "j-hui/fidget.nvim",                -- Shows LSP loading progress
    },
  },

  -- =========================================================================
  -- Mason -- The language server installer
  -- =========================================================================
  -- Mason is like an "app store" for language servers, formatters, linters,
  -- and debuggers. Instead of manually downloading and configuring each tool,
  -- Mason handles it all. You can run ":Mason" to see a nice UI showing
  -- what's installed.
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          -- Custom icons shown in the Mason UI for each package status
          icons = {
            package_installed = "✓",     -- Checkmark = installed and ready
            package_pending = "➜",       -- Arrow = currently installing
            package_uninstalled = "✗"    -- X = not installed yet
          }
        }
      })
    end,
  },

  -- =========================================================================
  -- Mason-LSPConfig -- The bridge between Mason and LSP configuration
  -- =========================================================================
  -- This plugin makes Mason and lspconfig work together seamlessly.
  -- It ensures the right language servers are installed and configures
  -- them automatically.
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      -- Get the autocomplete capabilities from the completion plugin (nvim-cmp).
      -- This tells each language server "hey, our editor supports these
      -- autocomplete features" so the server sends us richer suggestions.
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      require("mason-lspconfig").setup({
        -- These language servers will be automatically installed if missing.
        -- You don't have to install them yourself!
        ensure_installed = {
          "pyright",        -- Python language server (by Microsoft)
          "omnisharp",      -- C# / .NET language server (by Microsoft)
          "lua_ls",         -- Lua language server (for editing this config!)
          "ts_ls",          -- TypeScript/JavaScript language server
          "bashls",         -- Bash/shell script language server
          "jsonls",         -- JSON language server
        },

        -- If a language server is needed but not installed, install it automatically.
        automatic_installation = true,

        -- "handlers" define how each language server gets configured.
        -- There's a default handler for most servers, plus custom ones for
        -- servers that need special settings.
        handlers = {
          -- DEFAULT HANDLER: Used for any server that doesn't have a custom
          -- handler below. Just starts the server with autocomplete support.
          function(server_name)
            require("lspconfig")[server_name].setup({
              capabilities = capabilities,
            })
          end,

          -- PYTHON (Pyright) -- Custom settings for better Python support
          ["pyright"] = function()
            require("lspconfig").pyright.setup({
              capabilities = capabilities,
              settings = {
                python = {
                  analysis = {
                    -- Automatically find where Python packages are installed
                    autoSearchPaths = true,
                    -- Read type information from installed libraries so you
                    -- get better autocomplete for things like requests, pandas, etc.
                    useLibraryCodeForTypes = true,
                    -- Check the ENTIRE project for errors, not just open files.
                    -- "workspace" mode catches more bugs but uses more memory.
                    diagnosticMode = "workspace",
                  },
                },
              },
            })
          end,

          -- C# (OmniSharp) -- Custom settings for .NET development
          ["omnisharp"] = function()
            require("lspconfig").omnisharp.setup({
              capabilities = capabilities,
              -- The command to start the OmniSharp server
              cmd = { "omnisharp" },
              -- Enable Roslyn analyzers for deeper code analysis
              -- (catches more bugs and style issues)
              enable_roslyn_analyzers = true,
              -- Automatically organize "using" statements when formatting
              organize_imports_on_format = true,
              -- Show completions for things you haven't imported yet
              -- (and auto-add the import when you select one)
              enable_import_completion = true,
            })
          end,

          -- LUA (lua_ls) -- Custom settings so it understands Neovim's API
          ["lua_ls"] = function()
            require("lspconfig").lua_ls.setup({
              capabilities = capabilities,
              settings = {
                Lua = {
                  -- Tell the Lua server we're using LuaJIT (which is what
                  -- Neovim uses internally), not standard Lua.
                  runtime = {
                    version = "LuaJIT",
                  },
                  diagnostics = {
                    -- Tell the server that "vim" is a valid global variable.
                    -- Without this, every line using "vim.xxx" would show
                    -- a warning saying "undefined global 'vim'".
                    globals = { "vim" },
                  },
                  workspace = {
                    -- Load Neovim's runtime files so the server knows about
                    -- all of Neovim's built-in functions (vim.api, vim.fn, etc.)
                    library = vim.api.nvim_get_runtime_file("", true),
                    -- Don't prompt "do you want to configure this as a third
                    -- party library?" every time you open a Lua file.
                    checkThirdParty = false,
                  },
                  -- Don't send usage data to the lua_ls developers.
                  telemetry = {
                    enable = false,
                  },
                },
              },
            })
          end,
        },
      })

      -- =====================================================================
      -- LSP Keymaps -- Keyboard shortcuts for LSP features
      -- =====================================================================
      -- These keymaps are ONLY active when a language server is connected to
      -- the current file. They wouldn't make sense in a plain text file that
      -- has no language server.
      --
      -- "LspAttach" fires every time a language server connects to a buffer.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          -- { buffer = ev.buf } means these keymaps only work in THIS file,
          -- not globally across all buffers.
          local opts = { buffer = ev.buf }

          -- NAVIGATION keymaps: jump around your codebase
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
            -- gD = go to where something is DECLARED (e.g., "class Foo" line)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            -- gd = go to where something is DEFINED (most commonly used)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            -- K = show a popup with documentation about what's under your cursor
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
            -- gi = go to the implementation (useful for interfaces/abstract classes)
          vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
            -- Ctrl+k = show function signature (what arguments it takes)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            -- gr = find all REFERENCES (everywhere this thing is used)
          vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
            -- Space+D = go to the TYPE definition (e.g., what type a variable is)

          -- WORKSPACE keymaps: manage project folders the LSP tracks
          vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
            -- Space+w+a = add a folder to the workspace
          vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
            -- Space+w+r = remove a folder from the workspace
          vim.keymap.set("n", "<leader>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
            -- Space+w+l = list all workspace folders

          -- EDITING keymaps: change code with LSP intelligence
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            -- Space+r+n = RENAME a variable/function everywhere it's used
            -- This is incredibly powerful -- it renames across all files!
          vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
            -- Space+c+a = show CODE ACTIONS (quick fixes, refactorings)
            -- For example: auto-import, extract variable, fix spelling, etc.
          vim.keymap.set("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true })
          end, opts)
            -- Space+f = FORMAT the file (auto-indent, fix spacing, etc.)
            -- "async = true" means you can keep working while it formats
        end,
      })
    end,
  },

  -- =========================================================================
  -- Fidget -- Shows a little progress spinner for LSP operations
  -- =========================================================================
  -- When a language server is starting up, indexing your project, or doing
  -- heavy analysis, fidget shows a small, unobtrusive notification in the
  -- bottom-right corner so you know it's working. Without this, you'd have
  -- no idea why autocomplete isn't working yet (the server is still loading!).
  {
    "j-hui/fidget.nvim",
    opts = {},  -- Use default settings (empty table means "just use defaults")
  },
}
