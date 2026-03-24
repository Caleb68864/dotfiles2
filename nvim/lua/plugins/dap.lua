-- ============================================================================
-- DAP (Debug Adapter Protocol) Plugins -- Run code step-by-step to find bugs
-- ============================================================================
-- DAP is the debugging system. "Debugging" means running your program one
-- line at a time, pausing it, and inspecting what's happening inside --
-- what values variables have, which path the code is taking, etc.
--
-- Think of it like slow-motion replay for your code. You set "breakpoints"
-- (pause points) and the program stops there so you can look around.
--
-- This file sets up debugging for:
--   - Python (using debugpy)
--   - C# / .NET (using netcoredbg)
--
-- Four plugins work together:
--   1. nvim-dap        -- The core debugger engine
--   2. nvim-dap-ui     -- A nice visual interface for debugging
--   3. nvim-dap-python -- Pre-configured Python debugging
--   4. nvim-dap-virtual-text -- Shows variable values right in your code
-- ============================================================================

return {
  -- =========================================================================
  -- DAP Core -- The main debugging engine
  -- =========================================================================
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",        -- Visual debugging interface
      "nvim-neotest/nvim-nio",       -- Async I/O library (required by dap-ui)
      "mfussenegger/nvim-dap-python", -- Python-specific debug configuration
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- =======================================================================
      -- Auto-open and auto-close the debug UI
      -- =======================================================================
      -- When debugging STARTS, automatically open the debug panels (showing
      -- variables, call stack, breakpoints, console output, etc.)
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      -- When debugging ENDS (program finished or was stopped), automatically
      -- close the debug panels to get your screen space back.
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      -- Same thing if the debugged program exits (slightly different event).
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- =======================================================================
      -- C# / .NET debugging setup with netcoredbg
      -- =======================================================================
      -- "netcoredbg" is the debugger for C# / .NET Core applications.
      -- We tell DAP how to start it and that it speaks the VS Code debug protocol.
      dap.adapters.coreclr = {
        type = "executable",                  -- It's a program we run
        command = "netcoredbg",               -- The program name
        args = { "--interpreter=vscode" },    -- Speak VS Code's debug language
      }

      -- Configuration for launching C# programs in debug mode.
      -- When you press F5 in a .cs file, it asks you for the path to the
      -- compiled .dll file and then starts debugging it.
      dap.configurations.cs = {
        {
          type = "coreclr",                  -- Use the coreclr adapter defined above
          name = "launch - netcoredbg",      -- Name shown in the debug menu
          request = "launch",                -- Launch a new program (vs. attach to running one)
          program = function()
            -- Ask the user which .dll to debug. Pre-fills the path to the
            -- Debug build output folder since that's where .NET puts compiled files.
            return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
        },
      }

      -- =======================================================================
      -- Debug keymaps -- Keyboard shortcuts for debugging
      -- =======================================================================
      -- These use the F-keys (like a traditional IDE) for the most common
      -- debugging actions.

      -- F5 = Start debugging (or continue if paused at a breakpoint)
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })

      -- F10 = Step OVER the current line (run it, but don't go inside functions)
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })

      -- F11 = Step INTO a function call (go inside the function to see what it does)
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })

      -- F12 = Step OUT of the current function (finish it and go back to the caller)
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })

      -- Space+b = Toggle a BREAKPOINT on the current line
      -- A breakpoint is a "stop here" marker. When the program reaches this
      -- line, it pauses so you can inspect everything.
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle [b]reakpoint" })

      -- Space+B = Set a CONDITIONAL breakpoint
      -- This only pauses if a condition is true (e.g., "x > 100").
      -- Useful when a line runs 1000 times but you only care about one case.
      vim.keymap.set("n", "<leader>B", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Debug: Set conditional [B]reakpoint" })

      -- Space+d+r = Open the debug REPL (an interactive console where you can
      -- type expressions and see their values while paused)
      vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "[d]ebug [r]epl" })

      -- Space+d+l = Re-run the LAST debug session (same program, same settings)
      vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "[d]ebug [l]ast" })
    end,
  },

  -- =========================================================================
  -- DAP UI -- The visual debugging interface
  -- =========================================================================
  -- This plugin creates nice panels that show you:
  --   - All your variables and their current values
  --   - The call stack (which function called which)
  --   - Your breakpoints
  --   - Console output from the program
  --   - A REPL to evaluate expressions
  -- Without this, you'd be debugging with just text commands (much harder).
  {
    "rcarriga/nvim-dap-ui",
    config = function()
      require("dapui").setup()  -- Use default layout and settings
    end,
  },

  -- =========================================================================
  -- DAP Python -- Pre-configured Python debugging
  -- =========================================================================
  -- This plugin knows how to set up Python debugging with "debugpy"
  -- (Python's standard debug tool). You don't have to configure Python
  -- debugging manually -- this does it all for you.
  -- The "python" argument tells it to use the "python" command from your PATH.
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      require("dap-python").setup("python")
    end,
  },

  -- =========================================================================
  -- DAP Virtual Text -- Show variable values right inside your code
  -- =========================================================================
  -- When you're paused at a breakpoint, this plugin shows the current value
  -- of each variable right next to where it's used in your code, as faded
  -- text at the end of the line. For example:
  --   x = calculate_thing()   -- x = 42
  --   if x > 10:              -- x = 42
  -- This is incredibly helpful -- you don't have to hover over each variable
  -- to see its value.
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
    opts = {
      enabled = true,                      -- Turn on virtual text display
      enabled_commands = true,             -- Create commands like :DapVirtualTextEnable
      highlight_changed_variables = true,  -- Highlight variables whose value just changed
      highlight_new_as_changed = false,    -- Don't highlight brand-new variables as "changed"
      show_stop_reason = true,             -- Show WHY the debugger stopped (breakpoint, exception, etc.)
      commented = false,                   -- Don't wrap the virtual text in comment syntax
      only_first_definition = true,        -- Only show the value at the first place a variable appears
      all_references = false,              -- Don't show values at every reference (would be too noisy)
      filter_references_pattern = '<module', -- Filter out module-level references
      virt_text_pos = 'eol',              -- Show the value at the End Of Line
      all_frames = false,                  -- Only show values for the current stack frame
      virt_lines = false,                  -- Show as inline text, not on separate lines
      virt_text_win_col = nil,            -- Don't align to a specific column
    },
  },
}
