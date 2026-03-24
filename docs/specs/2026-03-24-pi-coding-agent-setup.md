# Pi Coding Agent Setup for EndeavourOS Dotfiles

## Meta

- Client: [[Logic]]
- Project: dotfiles2
- Repo: git@github.com:Caleb68864/dotfiles2.git
- Date: 2026-03-24
- Author: Caleb Bennett
- Status: partial
- Executed: 2026-03-24
- Result: 4/5 sub-specs passed, 1 partial (Hyprland keybinding conflict with Super+Shift+A)
- Quality Score: 30/35
  - Outcome clarity: 5/5
  - Scope boundaries: 5/5
  - Decision guidance: 4/5
  - Edge coverage: 4/5
  - Acceptance criteria: 4/5
  - Decomposition: 4/5
  - Purpose alignment: 4/5

## Outcome

When complete, the dotfiles2 repo contains a fully configured `pi/` Stow package with Pi Coding Agent settings, 9 prompt templates, and a tmux workspace launcher. Hyprland has 3 new keybindings for launching Pi. Neovim has pi-nvim installed with CodeCompanion commented out. Zsh has 4 Pi aliases. The install script deploys everything automatically. All changes can be pushed from Windows, pulled on the Linux machine, and deployed with `stow -Rv -t "$HOME" pi` + re-stowing edited packages.

## Intent

**Trade-off hierarchy:**
1. Follow existing dotfiles patterns over ideal Pi setup -- consistency matters more than optimization
2. Minimal changes to existing files over comprehensive refactoring -- surgical edits only
3. Reversibility over cleanliness -- comment out CodeCompanion rather than deleting it

**Decision boundaries -- decide autonomously:**
- File placement within the pi/ Stow package
- Prompt template content (use the notes verbatim)
- Ordering of sections within existing config files

**Escalation triggers -- stop and ask:**
- Any change to existing keybindings (not just additions)
- Removing (not commenting) existing plugin configurations
- Changes to Stow target mappings for existing packages

## Context

Pi Coding Agent ("Shitty Coding Agent") is a terminal-native AI coding agent by Mario Zechner. It complements Claude Code by offering multi-model support (324 models, 20+ providers), TypeScript extensibility, and deep tmux integration. Caleb has a Claude Max subscription ($200/mo) providing unlimited Claude model access through Pi at zero additional cost.

The dotfiles2 repo uses GNU Stow with flat package structure -- config files sit directly in the package root, no hidden directory nesting. Each package has a specific stow target defined in `install.sh`. Packages targeting `$HOME` (like zsh, tmux, git, bin) use the default; packages targeting `~/.config/<app>` are in the `STOW_TARGETS` associative array.

Research notes with full implementation details:
- [[1145-1300 - Logic Operations - R&D - Pi Coding Agent Setup Guide]]
- [[Shitty Coding Agent]]

## Requirements

1. A new `pi/` directory exists at the repo root containing all Pi config files
2. `pi/.pi/agent/settings.json` contains Tokyo Night theme, Claude model defaults
3. `pi/.pi/agent/keybindings.json` exists (empty object)
4. 9 prompt template files exist in `pi/.pi/agent/prompts/`
5. `pi/bin/pi-workspace` exists and is executable
6. `hypr/hyprland.conf` has 3 new Pi keybindings (Super+Shift+P/A/N)
7. `hypr/hyprland.conf` has 2 new window rules for pi-scratch and pi-notes
8. `zsh/.zsh/aliases.zsh` has a Pi aliases section with pa, pac, par, paf
9. `nvim/init.lua` has pi-nvim plugin added to lazy.nvim plugins table
10. `nvim/init.lua` has CodeCompanion plugin and keybindings commented out
11. `nvim/init.lua` has Pi keybindings remapping the old CodeCompanion keys
12. `install.sh` has "pi" in the PACKAGES array
13. `install.sh` has "$HOME/.pi" in the CONFLICT_ITEMS array
14. `install.sh` has `mkdir -p ~/scratch` in the directory creation section
15. `CLAUDE.md` has pi package documented in the Stow Package Targets table

## Sub-Specs

### Sub-Spec 1: Create pi/ Stow Package

**Scope:** Create all new files for the pi/ package from scratch.

**Files to create:**
- `pi/.pi/agent/settings.json`
- `pi/.pi/agent/keybindings.json`
- `pi/.pi/agent/prompts/review.md`
- `pi/.pi/agent/prompts/dotnet.md`
- `pi/.pi/agent/prompts/sql.md`
- `pi/.pi/agent/prompts/python.md`
- `pi/.pi/agent/prompts/obsidian.md`
- `pi/.pi/agent/prompts/explain.md`
- `pi/.pi/agent/prompts/fix.md`
- `pi/.pi/agent/prompts/test.md`
- `pi/.pi/agent/prompts/refactor.md`
- `pi/bin/pi-workspace`

**Acceptance Criteria:**
- `[STRUCTURAL]` `pi/.pi/agent/settings.json` exists with `theme: "tokyonight"`, `defaultModel: "anthropic:claude-sonnet-4-6"`, 3 scoped models (opus, sonnet, haiku), `thinkingLevel: "medium"`, `messageDelivery: "after_tool"`
- `[STRUCTURAL]` `pi/.pi/agent/keybindings.json` exists with contents `{}`
- `[STRUCTURAL]` All 9 prompt files exist in `pi/.pi/agent/prompts/`: review.md, dotnet.md, sql.md, python.md, obsidian.md, explain.md, fix.md, test.md, refactor.md
- `[STRUCTURAL]` `pi/bin/pi-workspace` exists with shebang `#!/bin/bash`, references SESSION="command-center", creates "agent" window, splits nvim left (60%) and pi right (40%), adds bottom terminal pane
- `[MECHANICAL]` `pi/bin/pi-workspace` has executable content (starts with `#!/bin/bash`)

**Dependencies:** none

### Sub-Spec 2: Update Hyprland Config

**Scope:** Add Pi keybindings and window rules to `hypr/hyprland.conf`.

**Files to edit:**
- `hypr/hyprland.conf`

**Details:**
- Add 3 keybindings in the KEYBINDINGS section (before the WINDOWS AND WORKSPACES section):
  - `bind = $mainMod SHIFT, P, exec, kitty -e pi-workspace`
  - `bind = $mainMod SHIFT, A, exec, kitty --class pi-scratch -d ~/scratch -e pi`
  - `bind = $mainMod SHIFT, N, exec, kitty --class pi-notes -d ~/Documents/Notes/Logic -e pi`
- Add 2 window rules (block syntax) after the existing yazi/ripdrag rules:
  - `pi-scratch`: float, size 1400 900, center
  - `pi-notes`: float, size 1600 1000, center
- Group under a `# Pi Coding Agent` comment

**Acceptance Criteria:**
- `[MECHANICAL]` `grep -c "pi-workspace" hypr/hyprland.conf` returns 1
- `[MECHANICAL]` `grep -c "pi-scratch" hypr/hyprland.conf` returns >= 2 (keybinding + window rule)
- `[MECHANICAL]` `grep -c "pi-notes" hypr/hyprland.conf` returns >= 2 (keybinding + window rule)
- `[STRUCTURAL]` Window rules use block syntax (not inline) with `float = yes`, `size`, and `center = yes`
- `[STRUCTURAL]` No use of deprecated `windowrulev2`

**Dependencies:** none

### Sub-Spec 3: Update Zsh Aliases

**Scope:** Add Pi alias section to `zsh/.zsh/aliases.zsh`.

**Files to edit:**
- `zsh/.zsh/aliases.zsh`

**Details:**
- Add a new section after the Hyprland section (at end of file)
- Section header: `# Pi Coding Agent`
- 4 aliases: `pa="pi"`, `pac="pi -c"`, `par="pi -r"`, `paf="pi --fork"`

**Acceptance Criteria:**
- `[MECHANICAL]` `grep -c 'alias pa=' zsh/.zsh/aliases.zsh` returns 1
- `[MECHANICAL]` `grep -c 'alias pac=' zsh/.zsh/aliases.zsh` returns 1
- `[STRUCTURAL]` Section is placed after the Hyprland section, follows existing formatting pattern (header comment + aliases)

**Dependencies:** none

### Sub-Spec 4: Update Neovim Config

**Scope:** Add pi-nvim plugin, comment out CodeCompanion, remap keybindings in `nvim/init.lua`.

**Files to edit:**
- `nvim/init.lua`

**Details:**
- Add pi-nvim plugin to the lazy.nvim plugins table:
  ```lua
  {
      "carderne/pi-nvim",
      config = function()
          require("pi-nvim").setup({})
      end,
  },
  ```
- Comment out the CodeCompanion plugin block (the `"olimorris/codecompanion.nvim"` entry and its config)
- Comment out the existing CodeCompanion keybindings (`<leader>cc`, `<leader>ci`, `<leader>ca`)
- Add Pi keybindings:
  ```lua
  vim.keymap.set("n", "<leader>cc", ":Pi ", { desc = "Pi chat prompt" })
  vim.keymap.set("v", "<leader>ci", ":PiSendSelection<CR>", { desc = "Send selection to Pi" })
  vim.keymap.set("n", "<leader>ca", ":PiSendFile<CR>", { desc = "Send file to Pi" })
  vim.keymap.set("n", "<leader>cb", ":PiSendBuffer<CR>", { desc = "Send buffer to Pi" })
  ```

**Acceptance Criteria:**
- `[MECHANICAL]` `grep -c "pi-nvim" nvim/init.lua` returns >= 2 (plugin name + require)
- `[MECHANICAL]` `grep -c "codecompanion" nvim/init.lua` returns >= 1 (still present but commented)
- `[STRUCTURAL]` All CodeCompanion lines are prefixed with `--` (commented, not deleted)
- `[STRUCTURAL]` Pi keybindings exist with correct mappings for `<leader>cc`, `<leader>ci`, `<leader>ca`, `<leader>cb`
- `[MECHANICAL]` No syntax errors: the lua content should have balanced braces/parentheses around the changes

**Dependencies:** none

### Sub-Spec 5: Update Install Script and CLAUDE.md

**Scope:** Add pi to install.sh arrays and document in CLAUDE.md.

**Files to edit:**
- `install.sh`
- `CLAUDE.md`

**Details for install.sh:**
- Add `"pi"` to the `PACKAGES` array (after `"bin"`)
- Add `"$HOME/.pi"` to the `CONFLICT_ITEMS` array
- Add `mkdir -p "$HOME/scratch"` in the "Creating necessary directories" section (after `mkdir -p "$HOME/.config"`)

**Details for CLAUDE.md:**
- Add pi to the Stow Package Targets table: `| pi | $HOME | .pi/agent/settings.json, bin/pi-workspace, prompts/ |`
- Add stow command example: `stow -Rv -t "$HOME" pi`

**Acceptance Criteria:**
- `[MECHANICAL]` `grep -c '"pi"' install.sh` returns >= 1 (in PACKAGES array)
- `[MECHANICAL]` `grep -c '.pi' install.sh` returns >= 1 (in CONFLICT_ITEMS)
- `[MECHANICAL]` `grep -c 'scratch' install.sh` returns >= 1 (mkdir)
- `[STRUCTURAL]` CLAUDE.md Stow Package Targets table includes pi row with target `$HOME`

**Dependencies:** none

## Edge Cases

1. **Stow conflicts with existing `~/.pi`:** If Pi was previously installed manually on the Linux machine, `~/.pi` may already exist as a real directory (not a symlink). The install.sh backup logic handles this -- `$HOME/.pi` is added to `CONFLICT_ITEMS`, so existing configs get backed up before stowing. Agent should add this to CONFLICT_ITEMS.

2. **Hyprland keybinding conflicts:** `Super+Shift+P`, `Super+Shift+A`, and `Super+Shift+N` were confirmed free in the existing config. However, if other changes land before this spec runs, conflicts could appear. The agent should grep hyprland.conf for `SHIFT, P`, `SHIFT, A`, and `SHIFT, N` before adding the bindings. If conflicts found, stop and report.

3. **CodeCompanion removal breaks Neovim:** Commenting out CodeCompanion may cause lazy.nvim to show warnings about missing keybinding targets. The mitigation is: (a) comment out BOTH the plugin block AND the keybindings, (b) add Pi keybindings that reuse the same leader keys, so muscle memory and which-key entries still work. The agent should ensure the CodeCompanion keybindings are commented in the same edit as the Pi keybindings are added.

## Out of Scope

- Installing Pi on the Linux machine (that's a manual step using `npm install -g`)
- Pi extension installation (pi-nvim, pi-side-agents, etc. -- manual via `pi install`)
- Authentication with Claude Max (`/login` inside Pi)
- Creating `~/scratch/` on the Linux machine (install.sh handles it)
- oh-my-pi evaluation (deferred)
- Modifying tmux config (.tmux.conf) -- pi-workspace creates windows in the existing session
- Adding `nodejs-lts-jod` to packages.txt (already there)

## Constraints

### Musts
- All new files in `pi/` follow the flat Stow package structure (no `.config/` nesting)
- Window rules use block syntax (not deprecated `windowrulev2` or inline boolean rules)
- CodeCompanion is commented out, not deleted
- pi-workspace script targets the "command-center" tmux session (matches .zshrc auto-attach)

### Must-Nots
- Do not modify existing keybindings -- only add new ones
- Do not delete any existing code -- only comment out or add
- Do not change Stow targets for existing packages
- Do not add Pi-related environment variables to .zshrc (Pi uses its own auth via /login)

### Preferences
- Group Pi-related additions under clear comment headers (`# Pi Coding Agent`)
- Place new sections at the end of existing files where possible
- Match existing code style (indentation, comment format, spacing)

### Escalation Triggers
- If any of Super+Shift+P/A/N are already bound in hyprland.conf, stop and report
- If CodeCompanion plugin block cannot be cleanly commented (e.g., nested in a conditional), stop and report
- If init.lua structure doesn't match expected patterns (can't find plugins table), stop and report

## Verification

End-to-end check after all sub-specs complete:

1. `[STRUCTURAL]` Verify complete pi/ package structure: settings.json, keybindings.json, 9 prompts, pi-workspace script
2. `[MECHANICAL]` `grep -c '"pi"' install.sh` confirms pi is in PACKAGES
3. `[MECHANICAL]` `grep -c "pi-workspace\|pi-scratch\|pi-notes" hypr/hyprland.conf` returns 5+ (3 keybindings + 2 window rule names)
4. `[MECHANICAL]` `grep -c "pi-nvim" nvim/init.lua` returns >= 2
5. `[MECHANICAL]` `grep -c 'alias pa' zsh/.zsh/aliases.zsh` returns >= 1
6. `[STRUCTURAL]` CLAUDE.md documents the pi package
