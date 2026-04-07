---
type: phase-spec
master_spec: "docs/specs/2026-04-07-terminal-pda-environment.md"
sub_spec: 5
title: "install-pda.sh installer"
dependencies: [1, 2, 3, 4]
date: 2026-04-07
---

# Sub-Spec 5: install-pda.sh Installer

## Scope

Create `install-pda.sh` and `packages-pda.txt` at the repo root. The installer stows only PDA-relevant packages, creates the PDA directory structure, and installs PDA system packages.

## Shared Context

- Follow patterns from `install.sh` (color functions, status/success/warning/error helpers, PACKAGES/STOW_TARGETS arrays)
- Use CURRENT package names (`zsh`, `tmux`, `nvim`, `newsboat`, `git`, `atuin`, `themes`, `bin`, `scripts`) NOT the proposed future names (`shell-common`, `tmux-common`)
- Use CURRENT stow targets from `install.sh` STOW_TARGETS map
- Add `pda-common` with stow target `$HOME`
- Must work on Arch Linux (Pi runs EndeavourOS ARM or similar)

## Interface Contracts

### Provides
- Fully installed PDA environment from a fresh Pi
- PDA directory structure (`~/Notes/`, `~/Media/`, `~/Books/`)
- All PDA packages stowed with correct targets

### Requires
- Sub-Specs 1-4: All PDA files must exist in the repo

## Implementation Steps

### Step 1: Create packages-pda.txt

**File:** `packages-pda.txt` (repo root)

```
# =============================================================================
# PDA System Packages
# =============================================================================
# Install with: grep -v '^#' packages-pda.txt | grep -v '^$' | xargs yay -S --needed

# Core terminal tools
neovim
tmux
zsh
starship
atuin
zoxide
fzf
ripgrep
eza
bat
git

# RSS and media
newsboat
mpv
yt-dlp

# Terminal browser (for newsboat xdg-open fallback)
w3m

# Calendar
khal
vdirsyncer

# Bluetooth audio
pipewire
wireplumber
bluez
bluez-utils

# TUI Bluetooth manager
bluetuith
```

### Step 2: Create install-pda.sh

**File:** `install-pda.sh` (repo root)

Follow `install.sh` structure:
1. Header banner (PDA-specific)
2. Color helper functions (copy from install.sh)
3. Detect dotfiles directory
4. Check for Arch-based system
5. Install yay if needed (same as install.sh)
6. Install packages from `packages-pda.txt`
7. Install Oh-My-Zsh and plugins (same as install.sh)
8. Create PDA directories
9. Stow PDA packages with correct targets
10. Set executable permissions
11. Print PDA usage summary

**PDA-specific PACKAGES and STOW_TARGETS:**
```bash
PACKAGES=(
    "zsh"
    "tmux"
    "nvim"
    "git"
    "atuin"
    "themes"
    "bin"
    "scripts"
    "newsboat"
    "pda-common"
)

declare -A STOW_TARGETS=(
    ["nvim"]="$HOME/.config/nvim"
    ["atuin"]="$HOME/.config/atuin"
    ["themes"]="$HOME/.config/themes"
    ["newsboat"]="$HOME/.config/newsboat"
)
# All others default to $HOME
```

**PDA directories:**
```bash
mkdir -p "$HOME/Notes/Inbox"
mkdir -p "$HOME/Notes/Calendar Notes/Daily Notes"
mkdir -p "$HOME/Media/Podcasts"
mkdir -p "$HOME/Media/Audiobooks"
mkdir -p "$HOME/Books"
mkdir -p "$HOME/.config/hypr"
touch "$HOME/.config/hypr/hyprland.local.conf"
```

**Executable permissions:**
```bash
EXECUTABLE_SCRIPTS=(
    "$HOME/bin/tmux-pda-session"
    "$HOME/bin/pda-note"
    "$HOME/bin/tmux-command-center"
    "$HOME/bin/tmux-smart-window"
    "$HOME/bin/tmux-daily-note"
)
```

### Step 3: Add completion message with PDA usage

Print keybinding reference and alias list similar to `install.sh` but PDA-specific.

## Verification Commands

- `bash -n install-pda.sh` (syntax check)
- `test -f packages-pda.txt` (file exists)
- `grep -q 'pda-common' install-pda.sh` (includes PDA package)

## Checks

| Criterion | Type | Command |
|-----------|------|---------|
| install-pda.sh exists | [STRUCTURAL] | `test -f install-pda.sh \|\| (echo "FAIL: install-pda.sh not found" && exit 1)` |
| packages-pda.txt exists | [STRUCTURAL] | `test -f packages-pda.txt \|\| (echo "FAIL: packages-pda.txt not found" && exit 1)` |
| install-pda.sh is valid bash | [MECHANICAL] | `bash -n install-pda.sh \|\| (echo "FAIL: install-pda.sh has syntax errors" && exit 1)` |
| Includes pda-common package | [MECHANICAL] | `grep -q 'pda-common' install-pda.sh \|\| (echo "FAIL: pda-common not in install script" && exit 1)` |
