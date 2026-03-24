---
date: 2026-03-24
topic: "Pi Coding Agent Setup for EndeavourOS Dotfiles"
author: Caleb Bennett
status: draft
tags:
  - design
  - pi-coding-agent
  - dotfiles
---

# Pi Coding Agent Setup -- Design

## Summary

Add Pi Coding Agent (the "Shitty Coding Agent") as a first-class Stow package in dotfiles2, with integration into Hyprland keybindings, Neovim (replacing CodeCompanion), Zsh aliases, and the install script. Pi complements Claude Code as a terminal-native, multi-model, extensible coding agent that leverages the existing Claude Max subscription at zero additional cost.

## Approach Selected

**Single Stow package + surgical edits to existing configs.** All Pi-specific files live in a new `pi/` package stowed to `$HOME`. Existing configs (hyprland.conf, aliases.zsh, init.lua, install.sh) get targeted additions. This follows the established dotfiles pattern exactly.

## Architecture

The integration touches 5 areas of the dotfiles repo:

```
dotfiles2/
├── pi/                          # NEW Stow package (target: $HOME)
│   ├── .pi/agent/
│   │   ├── settings.json        # Global Pi settings
│   │   ├── keybindings.json     # Custom keybindings (empty to start)
│   │   └── prompts/             # Slash-command templates
│   │       ├── review.md
│   │       ├── dotnet.md
│   │       ├── sql.md
│   │       ├── python.md
│   │       ├── obsidian.md
│   │       ├── explain.md
│   │       ├── fix.md
│   │       ├── test.md
│   │       └── refactor.md
│   └── bin/
│       └── pi-workspace         # Tmux workspace launcher script
├── hypr/hyprland.conf           # EDIT: add Pi keybindings + window rules
├── zsh/.zsh/aliases.zsh         # EDIT: add Pi aliases section
├── nvim/init.lua                # EDIT: add pi-nvim, remap CodeCompanion keys
└── install.sh                   # EDIT: add pi to PACKAGES and STOW_TARGETS
```

### How it fits the existing Stow model

- `pi/` stows to `$HOME` (like zsh, tmux, git, bin)
- `.pi/agent/` lands at `~/.pi/agent/` -- Pi's global config directory
- `bin/pi-workspace` lands at `~/bin/pi-workspace` -- already on `$PATH` via the existing `bin/` package

**Note:** `bin/pi-workspace` is in the `pi/` package, not the existing `bin/` package. Both stow to `$HOME`, so the symlink lands in `~/bin/` either way. Keeping it in `pi/` means Pi-related files are self-contained.

## Components

### 1. New `pi/` Stow Package

**Owns:** All Pi Coding Agent configuration files and the workspace launcher script.

**Does NOT own:** Neovim plugin config (that's in `nvim/init.lua`), Hyprland keybindings (in `hypr/hyprland.conf`), or shell aliases (in `zsh/.zsh/aliases.zsh`).

**Files:**

#### `.pi/agent/settings.json`
```json
{
  "theme": "tokyonight",
  "defaultModel": "anthropic:claude-sonnet-4-6",
  "scopedModels": [
    "anthropic:claude-opus-4-6",
    "anthropic:claude-sonnet-4-6",
    "anthropic:claude-haiku-4-5"
  ],
  "thinkingLevel": "medium",
  "messageDelivery": "after_tool"
}
```

#### `.pi/agent/keybindings.json`
```json
{}
```

#### `bin/pi-workspace`
Bash script that creates a tmux "agent" window in the "command-center" session with Neovim (60%) left, Pi (40%) right, and a small terminal pane at bottom-left. Accepts an optional directory argument.

#### `.pi/agent/prompts/` (9 templates)
| File | Slash Command | Purpose |
|------|--------------|---------|
| `review.md` | `/review` | Code review with `{{focus}}` variable |
| `dotnet.md` | `/dotnet` | .NET 8 / C# / Blazor context |
| `sql.md` | `/sql` | SQL Server context |
| `python.md` | `/python` | Python context |
| `obsidian.md` | `/obsidian` | Obsidian vault conventions |
| `explain.md` | `/explain` | Code explanation |
| `fix.md` | `/fix` | Debug/fix with `{{error}}` variable |
| `test.md` | `/test` | Write tests |
| `refactor.md` | `/refactor` | Clean up code |

### 2. Hyprland Config Changes (`hypr/hyprland.conf`)

**Adds:** 3 keybindings and 2 window rules.

| Keybinding | Action | Details |
|-----------|--------|---------|
| `Super+Shift+P` | Pi workspace | Full tmux layout via `pi-workspace` |
| `Super+Shift+A` | Floating scratch Pi | Opens in `~/scratch/`, class `pi-scratch` |
| `Super+Shift+N` | Floating notes Pi | Opens in vault dir, class `pi-notes` |

Window rules (block syntax per CLAUDE.md rules):
- `pi-scratch`: float, 1400x900, centered
- `pi-notes`: float, 1600x1000, centered

**Keybinding conflicts checked:** `Super+Shift+P` is free (not bound). `Super+Shift+A` is free. `Super+Shift+N` is free (`Super+N` is swaync, but `Super+Shift+N` is unbound).

### 3. Zsh Aliases (`zsh/.zsh/aliases.zsh`)

**Adds** a new "Pi Coding Agent" section after the existing Hyprland section:

```bash
alias pa="pi"          # Quick launch
alias pac="pi -c"      # Continue last session
alias par="pi -r"      # Browse sessions
alias paf="pi --fork"  # Fork session
```

### 4. Neovim Changes (`nvim/init.lua`)

Two changes:

**a) Add pi-nvim plugin** to the lazy.nvim plugins table:
```lua
{
    "carderne/pi-nvim",
    config = function()
        require("pi-nvim").setup({})
    end,
},
```

**b) Remap CodeCompanion keybindings to Pi equivalents:**
- `<leader>cc` -> `:Pi ` (chat prompt)
- `<leader>ci` -> `:PiSendSelection<CR>` (send selection)
- `<leader>ca` -> `:PiSendFile<CR>` (send file)
- Add `<leader>cb` -> `:PiSendBuffer<CR>` (send buffer, new)

**Decision:** Comment out CodeCompanion plugin and its keybindings rather than deleting, so they can be restored if Pi doesn't work out. Add pi-nvim and Pi keybindings alongside.

### 5. Install Script Changes (`install.sh`)

- Add `"pi"` to the `PACKAGES` array (after `"bin"`)
- No entry needed in `STOW_TARGETS` -- defaults to `$HOME` (same as zsh, tmux, git, bin)
- Add `"$HOME/.pi"` to `CONFLICT_ITEMS` array for backup

## Data Flow

```
User launches Pi via:
  Super+Shift+P  -->  kitty -e pi-workspace  -->  tmux "agent" window  -->  nvim + pi side-by-side
  Super+Shift+A  -->  kitty --class pi-scratch -d ~/scratch -e pi  -->  floating window
  Super+Shift+N  -->  kitty --class pi-notes -d ~/Documents/Notes/Logic -e pi  -->  floating window
  pa / pac / par -->  direct terminal launch

Pi reads config from:
  ~/.pi/agent/settings.json  (global settings)
  ~/.pi/agent/prompts/*.md   (slash command templates)
  ./CLAUDE.md or ./AGENTS.md (per-project context, auto-loaded)

Neovim communicates with Pi via:
  pi-nvim Unix socket bridge (/tmp/pi-nvim-sockets/)
  <leader>p / <leader>cc / <leader>ci / <leader>ca / <leader>cb
```

## Error Handling

- **Pi not installed:** `pi-workspace` script will fail with "command not found" -- acceptable, user runs `npm install -g @mariozechner/pi-coding-agent` first
- **Pi extensions not installed:** Pi works without extensions, just missing features. Install script in Appendix A of the notes covers this
- **Tmux session doesn't exist:** `pi-workspace` script assumes "command-center" session exists (created by `.zshrc` on terminal launch). If run outside tmux, tmux commands will fail -- expected behavior
- **`~/scratch/` doesn't exist:** Created manually per notes, not Stow-managed. Add `mkdir -p ~/scratch` to install.sh
- **CodeCompanion still loaded:** If user uncomments CodeCompanion, both plugins coexist. Keybinding conflicts would need manual resolution but this is a deliberate user action

## Open Questions

- **Extension package names:** The exact npm/git names for Pi extensions (pi-nvim, pi-side-agents, pi-web-search, etc.) may differ from what's documented. Verify against shittycodingagent.ai/packages before running the install script on the Linux machine.
- **pi-nvim socket path:** The socket auto-discovery path (`/tmp/pi-nvim-sockets/`) should be verified on EndeavourOS -- some distros use `/run/user/$UID/` instead.
- **oh-my-pi:** Deferred for now. Start with vanilla Pi, evaluate oh-my-pi later once comfortable with the base workflow.

## Approaches Considered

Only one approach was considered because the notes already resolved all design decisions through 3 rounds of AAR:

**Approach: Single Stow package + surgical config edits** -- chosen because it follows the exact pattern of every other package in dotfiles2. Pi config is self-contained in `pi/`, cross-cutting concerns (keybindings, aliases, Neovim plugin) are added to their respective existing files.

No alternative approaches were needed -- the established dotfiles architecture makes this straightforward.

## Implementation Checklist

### New files to create:
- [ ] `pi/.pi/agent/settings.json`
- [ ] `pi/.pi/agent/keybindings.json`
- [ ] `pi/.pi/agent/prompts/review.md`
- [ ] `pi/.pi/agent/prompts/dotnet.md`
- [ ] `pi/.pi/agent/prompts/sql.md`
- [ ] `pi/.pi/agent/prompts/python.md`
- [ ] `pi/.pi/agent/prompts/obsidian.md`
- [ ] `pi/.pi/agent/prompts/explain.md`
- [ ] `pi/.pi/agent/prompts/fix.md`
- [ ] `pi/.pi/agent/prompts/test.md`
- [ ] `pi/.pi/agent/prompts/refactor.md`
- [ ] `pi/bin/pi-workspace` (executable)

### Existing files to edit:
- [ ] `hypr/hyprland.conf` -- add Pi keybindings and window rules
- [ ] `zsh/.zsh/aliases.zsh` -- add Pi aliases section
- [ ] `nvim/init.lua` -- add pi-nvim plugin, comment out CodeCompanion, remap keybindings
- [ ] `install.sh` -- add pi to PACKAGES array, add ~/.pi to CONFLICT_ITEMS, add `mkdir -p ~/scratch`
- [ ] `CLAUDE.md` -- add pi package to Stow Package Targets table

## Next Steps

- [ ] Turn this design into a Forge spec (`/forge docs/plans/2026-03-24-pi-coding-agent-setup-design.md`)
- [ ] Verify Pi extension package names against shittycodingagent.ai/packages before running on Linux
- [ ] After implementation: push to remote, pull on Linux machine, run `stow -Rv -t "$HOME" pi`
- [ ] Run first-day install script (Appendix A from notes) on the Linux machine
- [ ] Authenticate Pi with Claude Max via `/login`
