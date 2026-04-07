---
date: 2026-04-07
title: Terminal PDA Environment
status: ready
design_doc: docs/plans/2026-04-07-terminal-pda-environment-design.md
---

# Terminal PDA Environment

## Meta

- **Client:** Personal
- **Project:** dotfiles2 PDA
- **Repo:** git@github.com:Caleb68864/dotfiles2.git
- **Date:** 2026-04-07
- **Author:** Caleb Bennett
- **Status:** completed
- **Executed:** 2026-04-07
- **Result:** 6/6 sub-specs passed
- **Quality Scores:**
  - Outcome clarity: 5/5
  - Scope boundaries: 5/5
  - Decision guidance: 5/5
  - Edge coverage: 4/5
  - Acceptance criteria: 4/5
  - Decomposition: 4/5
  - Purpose alignment: 5/5
  - **Total: 32/35**

## Outcome

A `pda-common` GNU Stow package in the dotfiles2 repo that, when stowed alongside the shared packages (shell-common, tmux-common, newsboat-common, nvim-common), transforms a Raspberry Pi Zero 2 W into a purpose-built terminal PDA. The PDA boots to a tmux session with today's daily note open in nvim within 10 seconds of login. Alt+N window switching provides instant access to RSS feeds, calendar, ebooks, media, and SSH.

## Intent

**Trade-off hierarchy (when valid approaches conflict):**
1. Speed and low memory over feature completeness
2. Simplicity over configurability
3. Offline-capable over cloud-connected
4. Compatibility with shared dotfiles over PDA-ideal config

**Escalation triggers (stop and ask):**
- Any change to shared config files (shell-common, tmux-common, newsboat-common, nvim-common)
- Stow conflicts between pda-common and any shared package
- nvim startup exceeding 5 seconds with PDA_MODE
- Any new system package not already in packages.txt

## Context

This spec builds on an evaluated design document: `docs/plans/2026-04-07-terminal-pda-environment-design.md`.

The dotfiles2 repo is already modularized into GNU Stow packages with:
- `*.local` override patterns in `.tmux.conf` (line 545: `source-file -q ~/.tmux.conf.local`) and `.zshrc` (line 367: `~/.zshrc.local`)
- Glob-based alias loader in `.zshrc` (`for f in ~/.zsh/aliases-*.zsh(N)`)
- `$OBSIDIAN_VAULT` env var used by 7+ scripts with fallback defaults
- `cached_eval` helper for shell startup performance
- `tmux-command-center` and `tmux-smart-window` scripts as reference patterns
- `wl-copy` hardcoded in tmux copy-mode (4 places) and newsboat clipboard macro (1 place)

**Key codebase references:**
- `zsh/.zshrc` lines 300-317: tmux auto-start block (hardcodes `tmux-command-center`)
- `bin/bin/tmux-command-center`: desktop session builder (reference pattern for PDA version)
- `bin/bin/tmux-smart-window`: smart window creator (reused by PDA)
- `bin/bin/tmux-daily-note`: daily note popup (reference for `pda-note`)
- `nvim/lua/plugins/`: lazy.nvim plugin specs (where `PDA_MODE` guards go)
- `newsboat/config` line 98: `macro c` uses `wl-copy`

## Requirements

1. `pda-common` stow package exists and stows to `$HOME` without conflicts alongside shared packages
2. `aliases-pda.zsh` exports `PDA_MODE=1`, `TMUX_SESSION_BUILDER=$HOME/bin/tmux-pda-session`, `BROWSER=w3m`, and overrides `OBSIDIAN_VAULT` for PDA vault path
3. `.zshrc` tmux auto-start uses `$TMUX_SESSION_BUILDER` variable instead of hardcoded `tmux-command-center`
4. `tmux-pda-session` creates a "command-center" session with windows: notes (daily note in nvim), inbox, feeds (newsboat), calendar (khal), books, media, ssh, scratch
5. Window 1 (notes) opens today's daily note in nvim immediately -- this is the boot-to-writing experience
6. `pda-note` script creates timestamped Markdown files in `$OBSIDIAN_VAULT/Inbox/` with frontmatter
7. `.tmux.conf.local` rebinds copy-mode to use `tmux load-buffer -` instead of `wl-copy`
8. `.tmux.conf.local` optimizes status bar for small screens (session name + window number only)
9. Heavy nvim plugins (DAP, AI, Treesitter, telescope) are disabled when `PDA_MODE=1` via `enabled = not vim.env.PDA_MODE` in their spec files
10. `install-pda.sh` stows only shared + PDA packages, creates PDA directory structure, installs PDA system packages
11. All scripts use `command -v` guards for optional tools and `${VAR:-default}` for paths

## Sub-Specs

### Sub-Spec 1: Shared config prerequisites

**Scope:** Modify shared config files to support PDA mode without breaking desktop behavior.

**Files:**
- `zsh/.zshrc` (modify tmux auto-start block)
- `nvim/lua/plugins/dap.lua` (add PDA_MODE guard)
- `nvim/lua/plugins/ai.lua` (add PDA_MODE guard)
- `nvim/lua/plugins/treesitter.lua` (add PDA_MODE guard)
- `nvim/lua/plugins/editor.lua` (add PDA_MODE guard for telescope)

**Changes:**
1. In `.zshrc` tmux auto-start (lines 300-317), replace hardcoded `$HOME/bin/tmux-command-center` with `${TMUX_SESSION_BUILDER:-$HOME/bin/tmux-command-center}`. Keep the fallback so desktop behavior is unchanged.
2. In each listed nvim plugin spec, wrap the return table or the plugin entry with `enabled = not vim.env.PDA_MODE`. For plugins with multiple entries, only guard the heavy ones.

**Acceptance Criteria:**
- `[MECHANICAL]` grep for `TMUX_SESSION_BUILDER` in `.zshrc` returns a match
- `[MECHANICAL]` grep for `PDA_MODE` in each listed nvim plugin file returns a match
- `[BEHAVIORAL]` On desktop (no PDA_MODE set), nvim loads all plugins normally; tmux auto-start calls `tmux-command-center`
- `[BEHAVIORAL]` With `PDA_MODE=1`, nvim skips DAP, AI, Treesitter, and telescope plugins

**Dependencies:** none (must be done first -- all other sub-specs depend on this)

### Sub-Spec 2: pda-common package structure

**Scope:** Create the `pda-common/` stow package directory with aliases and env var exports.

**Files (all new):**
- `pda-common/.zsh/aliases-pda.zsh`
- `pda-common/.tmux.conf.local`

**aliases-pda.zsh must export:**
- `PDA_MODE=1`
- `TMUX_SESSION_BUILDER="$HOME/bin/tmux-pda-session"`
- `BROWSER=w3m`
- `OBSIDIAN_VAULT="$HOME/Notes"` (PDA vault path)

**aliases-pda.zsh must define aliases:**
- `note` -> `pda-note`
- `today` -> `nvim "$OBSIDIAN_VAULT/Calendar Notes/Daily Notes/$(date +%Y-%m-%d).md"`
- `inbox` -> `nvim "$OBSIDIAN_VAULT/Inbox/"`
- `feeds` -> `newsboat`
- `agenda` -> `khal list today 7d`
- `books` -> bookokrat or epy (whichever is installed, `command -v` guard)
- `ssh-home` -> placeholder (user will configure)
- `ssh-server` -> placeholder (user will configure)

**.tmux.conf.local must:**
- Rebind copy-mode-vi y, Enter, MouseDragEnd1Pane to `tmux load-buffer -`
- Override prefix Y to use `tmux load-buffer -`
- Set minimal status bar (session + window number only, no clock/hostname)
- Reduce status-right to just `%H:%M`

**Acceptance Criteria:**
- `[STRUCTURAL]` `pda-common/.zsh/aliases-pda.zsh` exists and contains all listed exports and aliases
- `[STRUCTURAL]` `pda-common/.tmux.conf.local` exists and rebinds copy-mode keys
- `[MECHANICAL]` `stow -nv -t "$HOME" pda-common` (dry run) reports no conflicts with other stowed packages
- `[BEHAVIORAL]` After stowing, `source ~/.zsh/aliases-pda.zsh && echo $PDA_MODE` prints `1`

**Dependencies:** Sub-Spec 1

### Sub-Spec 3: tmux-pda-session script

**Scope:** Create the PDA tmux session builder script.

**Files (new):**
- `pda-common/bin/tmux-pda-session`

**Behavior:**
- Creates a tmux session named "command-center" (same as desktop for keybinding compatibility)
- If session already exists, attaches to it (same guard as `tmux-command-center`)
- Window layout:
  - Window 1 "note": opens today's daily note in nvim (creates file if missing, with frontmatter template)
  - Window 2 "inbox": `nvim $OBSIDIAN_VAULT/Inbox/`
  - Window 3 "feed": newsboat (guarded with `command -v`)
  - Window 4 "cal": `khal interactive` (guarded)
  - Window 5 "book": bookokrat or epy (guarded)
  - Window 6 "media": empty shell (mpv launched on demand)
  - Window 7 "ssh": empty shell (user connects manually)
  - Window 0 "scratch": empty shell
- Selects window 1 before attaching
- Uses `exec tmux attach` to replace shell process

**Follow the patterns from `tmux-command-center`:** same comment style, same `command -v` guards, same `FIRST=true` pattern for conditional window creation.

**Acceptance Criteria:**
- `[STRUCTURAL]` `pda-common/bin/tmux-pda-session` exists and is a bash script with `#!/bin/bash` and `set -e`
- `[MECHANICAL]` Script is syntactically valid: `bash -n pda-common/bin/tmux-pda-session` exits 0
- `[BEHAVIORAL]` Running the script creates a tmux session "command-center" with windows at positions 0-7
- `[BEHAVIORAL]` Window 1 contains nvim editing today's daily note file

**Dependencies:** Sub-Spec 1, Sub-Spec 2

### Sub-Spec 4: pda-note instant capture script

**Scope:** Create a quick-note capture script.

**Files (new):**
- `pda-common/bin/pda-note`

**Behavior:**
- Generates filename: `$OBSIDIAN_VAULT/Inbox/YYYY-MM-DD-HHMMSS.md`
- Creates parent directory with `mkdir -p`
- Writes frontmatter template:
  ```
  ---
  title: ""
  date: YYYY-MM-DDTHH:MM:SS
  type: note
  tags:
    - inbox
  ---

  ```
- Opens the file in `$EDITOR` (nvim) with cursor positioned after frontmatter
- Accepts optional `--vault PATH` argument to override `$OBSIDIAN_VAULT`

**Acceptance Criteria:**
- `[STRUCTURAL]` `pda-common/bin/pda-note` exists with `#!/bin/bash`
- `[MECHANICAL]` `bash -n pda-common/bin/pda-note` exits 0
- `[BEHAVIORAL]` Running `OBSIDIAN_VAULT=/tmp/test-vault pda-note` creates a file at `/tmp/test-vault/Inbox/YYYY-MM-DD-HHMMSS.md` with YAML frontmatter
- `[MECHANICAL]` Created file contains `type: note` in frontmatter

**Dependencies:** none

### Sub-Spec 5: install-pda.sh installer

**Scope:** Create a PDA-specific installation script.

**Files (new):**
- `install-pda.sh` (repo root)
- `packages-pda.txt` (repo root)

**install-pda.sh behavior:**
1. Detect dotfiles directory from script location
2. Install PDA system packages from `packages-pda.txt` (if on Arch: `yay -S --needed`)
3. Create PDA directories: `~/Notes/`, `~/Notes/Inbox/`, `~/Notes/Calendar Notes/Daily Notes/`, `~/Media/Podcasts/`, `~/Media/Audiobooks/`, `~/Books/`
4. Create empty `~/.config/hypr/hyprland.local.conf` (shared config sources it)
5. Stow packages: shell-common (currently `zsh`, `git`, `atuin`, `themes`, `scripts`), tmux-common (currently `tmux`), newsboat, nvim, pda-common -- using correct stow targets from `install.sh`
6. Set executable permissions on PDA scripts
7. Print PDA usage summary

**packages-pda.txt should include:**
- `khal`, `vdirsyncer` (calendar)
- `mpv`, `yt-dlp` (media)
- `w3m` (terminal browser)
- `pipewire`, `wireplumber`, `bluez`, `bluez-utils` (Bluetooth audio)
- `resilio-sync` or `rslsync` (vault sync)
- `neovim`, `tmux`, `zsh`, `starship`, `atuin`, `zoxide`, `fzf`, `eza`, `bat`, `newsboat` (core tools)

**Note:** The current repo hasn't been reorganized yet -- packages are still named `zsh`, `tmux`, `nvim`, etc. (not `shell-common`, `tmux-common`). The installer must use the CURRENT package names and stow targets from `install.sh`.

**Acceptance Criteria:**
- `[STRUCTURAL]` `install-pda.sh` exists at repo root with `#!/bin/bash` and `set -e`
- `[STRUCTURAL]` `packages-pda.txt` exists at repo root with package names
- `[MECHANICAL]` `bash -n install-pda.sh` exits 0
- `[BEHAVIORAL]` Running `install-pda.sh` on a fresh Pi stows all required packages and creates the directory structure

**Dependencies:** Sub-Spec 1, Sub-Spec 2, Sub-Spec 3, Sub-Spec 4

### Sub-Spec 6: justfile PDA recipes

**Scope:** Add PDA-specific recipes to the existing justfile.

**Files:**
- `justfile` (modify existing)

**Add recipes:**
- `just install-pda` -- runs `install-pda.sh`
- `just stow-pda` -- stows only the PDA-relevant packages (using current package names)
- `just unstow-pda` -- unstows PDA packages

**Acceptance Criteria:**
- `[MECHANICAL]` `just --list` includes `install-pda`, `stow-pda`, `unstow-pda`
- `[STRUCTURAL]` justfile contains PDA recipe definitions

**Dependencies:** Sub-Spec 5

## Edge Cases

1. **Vault not present on boot:** `tmux-pda-session` checks `$OBSIDIAN_VAULT` exists. If missing, window 1 opens a shell displaying setup instructions instead of nvim. `pda-note` creates `Inbox/` with `mkdir -p` -- notes are never lost.
2. **Offline usage:** PDA must be fully useful offline. newsboat shows cached articles, khal shows cached calendar, notes are local files, books/podcasts are local. Resilio Sync queues changes.
3. **Small screen (40-50 cols):** `.tmux.conf.local` sets minimal status bar. tmux window names are 3-4 chars. nvim runs with wrap + linebreak.
4. **No Wayland clipboard:** `.tmux.conf.local` rebinds copy-mode to tmux buffer. newsboat clipboard macro fails but other macros (mpv, obsidian clip, download) work.
5. **Pi Zero 2 W RAM limits:** PDA_MODE disables heavy nvim plugins. tmux windows lazy-load. mpv uses small cache.
6. **Daily note file doesn't exist yet:** `tmux-pda-session` creates the file with frontmatter before opening nvim.

## Out of Scope

- Reorganizing the repo into shell-common/tmux-common/etc packages (separate task from the migration plan)
- Hyprland, Waybar, SwayNC, Kitty, aerc, yazi configuration
- Pi coding agent (pi package) integration
- Resilio Sync installation and folder pairing (manual setup)
- vdirsyncer CalDAV configuration (credentials are user-specific)
- Physical hardware selection (keyboard, screen, case)
- Speaker audio output (deferred to v2)
- Multi-vault switching UI (v1 uses single vault with optional --vault flag)

## Constraints

**Musts:**
- All new files must be in the `pda-common/` stow package (except `install-pda.sh`, `packages-pda.txt`, and justfile changes)
- Scripts must use `#!/bin/bash` and `set -e`
- Scripts must use `command -v` guards for optional tools
- Scripts must use `${VAR:-default}` for all paths
- Comments must match the repo's heavily-commented documentation style
- `.zshrc` change must preserve desktop behavior when `TMUX_SESSION_BUILDER` is unset

**Must-Nots:**
- MUST NOT modify shared config behavior when PDA env vars are not set
- MUST NOT add desktop-environment dependencies (no Wayland, X11, GTK)
- MUST NOT hardcode vault paths (use `$OBSIDIAN_VAULT`)
- MUST NOT install packages globally during stow (only `install-pda.sh` installs packages)

**Preferences:**
- Prefer reusing existing script patterns from `tmux-command-center` and `tmux-daily-note`
- Prefer `tmux load-buffer -` over complex clipboard detection logic
- Prefer env var gating (`PDA_MODE`) over separate config file forks
- Prefer short window names (3-4 chars) for small screens

**Escalation Triggers:**
- Stow conflict between `pda-common` and any existing package
- Any shared config change that breaks desktop `PDA_MODE` unset behavior
- nvim startup >5 seconds with `PDA_MODE=1`
- Any new pattern not already used in the codebase

## Verification

**End-to-end verification (on Pi or simulated environment):**

1. `[MECHANICAL]` `stow -nv -t "$HOME" pda-common` completes with no conflicts
2. `[STRUCTURAL]` All expected files exist in `pda-common/`: `.zsh/aliases-pda.zsh`, `.tmux.conf.local`, `bin/tmux-pda-session`, `bin/pda-note`
3. `[BEHAVIORAL]` Source aliases-pda.zsh, then `echo $PDA_MODE` prints `1`, `echo $TMUX_SESSION_BUILDER` prints path to `tmux-pda-session`
4. `[BEHAVIORAL]` `PDA_MODE=1 nvim --headless "+lua print(vim.env.PDA_MODE)" +qa` prints `1`; DAP/AI/treesitter plugins are not loaded
5. `[BEHAVIORAL]` `tmux-pda-session` creates session with 8 windows; window 1 contains nvim
6. `[BEHAVIORAL]` `pda-note` creates a timestamped file with YAML frontmatter in the vault Inbox
7. `[INTEGRATION]` Full boot simulation: set PDA env vars -> tmux auto-start runs `tmux-pda-session` -> window 1 opens daily note -> Alt+3 switches to newsboat window -> `,o` clips article to vault

## Phase Specs

Refined by `/forge-prep` on 2026-04-07.

| Sub-Spec | Phase Spec |
|----------|------------|
| 1. Shared config prerequisites | `docs/specs/terminal-pda-environment/sub-spec-1-shared-config-prerequisites.md` |
| 2. pda-common package structure | `docs/specs/terminal-pda-environment/sub-spec-2-pda-common-package-structure.md` |
| 3. tmux-pda-session script | `docs/specs/terminal-pda-environment/sub-spec-3-tmux-pda-session.md` |
| 4. pda-note instant capture | `docs/specs/terminal-pda-environment/sub-spec-4-pda-note-instant-capture.md` |
| 5. install-pda.sh installer | `docs/specs/terminal-pda-environment/sub-spec-5-install-pda.md` |
| 6. justfile PDA recipes | `docs/specs/terminal-pda-environment/sub-spec-6-justfile-pda-recipes.md` |

Index: `docs/specs/terminal-pda-environment/index.md`
