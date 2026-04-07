---
type: phase-spec
master_spec: "docs/specs/2026-04-07-terminal-pda-environment.md"
sub_spec: 2
title: "pda-common package structure"
dependencies: [1]
date: 2026-04-07
---

# Sub-Spec 2: pda-common Package Structure

## Scope

Create the `pda-common/` stow package directory with two files: `aliases-pda.zsh` (env vars + aliases) and `.tmux.conf.local` (clipboard + status bar overrides).

## Shared Context

- Stow target: `$HOME` (same as zsh, tmux, git, bin packages)
- `.zsh/aliases-*.zsh` files are auto-loaded by the glob loader in `.zshrc`
- `.tmux.conf.local` is sourced by `.tmux.conf` line 545: `source-file -q ~/.tmux.conf.local`
- Follow the repo's heavily-commented documentation style

## Interface Contracts

### Provides
- `PDA_MODE=1` env var (consumed by nvim plugin guards from Sub-Spec 1)
- `TMUX_SESSION_BUILDER` pointing to `~/bin/tmux-pda-session` (consumed by `.zshrc` from Sub-Spec 1)
- `BROWSER=w3m` (consumed by newsboat's `xdg-open` browser setting)
- `OBSIDIAN_VAULT` override for PDA vault path
- Tmux clipboard rebindings (replaces `wl-copy` with `tmux load-buffer -`)

### Requires
- Sub-Spec 1: `TMUX_SESSION_BUILDER` variable support in `.zshrc`
- Sub-Spec 1: `PDA_MODE` guards in nvim plugin specs

## Implementation Steps

### Step 1: Create pda-common directory structure

```bash
mkdir -p pda-common/.zsh
mkdir -p pda-common/bin
```

### Step 2: Create aliases-pda.zsh

**File:** `pda-common/.zsh/aliases-pda.zsh`

Follow the style of existing alias files (e.g., `zsh/.zsh/aliases-desktop.zsh`). Include:
- Header comment block with `=====` separators explaining PDA purpose
- Environment variable exports (PDA_MODE, TMUX_SESSION_BUILDER, BROWSER, OBSIDIAN_VAULT)
- Alias definitions with comments explaining each

**Required exports:**
```bash
export PDA_MODE=1
export TMUX_SESSION_BUILDER="$HOME/bin/tmux-pda-session"
export BROWSER=w3m
export OBSIDIAN_VAULT="$HOME/Notes"
```

**Required aliases:**
```bash
alias note='pda-note'
alias today='nvim "$OBSIDIAN_VAULT/Calendar Notes/Daily Notes/$(date +%Y-%m-%d).md"'
alias inbox='nvim "$OBSIDIAN_VAULT/Inbox/"'
alias feeds='newsboat'
alias agenda='khal list today 7d'
# books: detect which reader is installed
if command -v bookratt &> /dev/null; then
    alias books='bookratt'
elif command -v epy &> /dev/null; then
    alias books='epy'
fi
# SSH shortcuts (user configures actual hosts)
alias ssh-home='echo "Configure ssh-home in aliases-pda.zsh"'
alias ssh-server='echo "Configure ssh-server in aliases-pda.zsh"'
```

**Verify:** `test -f pda-common/.zsh/aliases-pda.zsh`

### Step 3: Create .tmux.conf.local

**File:** `pda-common/.tmux.conf.local`

Follow tmux config comment style from `.tmux.conf`. Include:
- Header comment block explaining PDA tmux overrides
- Copy-mode rebindings (replace `wl-copy` with `tmux load-buffer -`)
- Status bar minimization for small screens
- Prefix Y override

**Required content:**
```tmux
# =============================================================================
# PDA Tmux Overrides
# =============================================================================
# Sourced by .tmux.conf via: source-file -q ~/.tmux.conf.local
# These overrides optimize tmux for a small-screen PDA without Wayland.

# --- CLIPBOARD: Use tmux buffer instead of wl-copy ---
# The shared .tmux.conf uses wl-copy (Wayland) which doesn't exist on PDA.
# Rebind to tmux's internal paste buffer instead.
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "tmux load-buffer -"
bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "tmux load-buffer -"
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "tmux load-buffer -"
bind Y run-shell "tmux capture-pane -p | tmux load-buffer - && tmux display 'Pane copied to buffer!'"

# --- STATUS BAR: Minimal for small screens ---
# Only show session name (left) and time (right). No hostname, no help hint.
set -g status-left "#[fg=#1a1b26,bg=#7aa2f7,bold] #S #[fg=#c0caf5,bg=#1a1b26]"
set -g status-right "#[fg=#c0caf5,bg=#24283b] %H:%M "
set -g status-right-length 10

# --- WINDOW TABS: Shorter names for small screens ---
setw -g window-status-format "#[fg=#a9b1d6,bg=#1a1b26] #I:#W "
setw -g window-status-current-format "#[fg=#7aa2f7,bg=#24283b,bold] #I:#W "
```

**Verify:** `test -f pda-common/.tmux.conf.local`

### Step 4: Verify stow dry-run

```bash
stow -nv -t "$HOME" pda-common
```

Should report no conflicts. If conflicts appear, the package structure overlaps with another stowed package — escalate.

## Verification Commands

- `test -f pda-common/.zsh/aliases-pda.zsh` (file exists)
- `test -f pda-common/.tmux.conf.local` (file exists)
- `grep -q 'PDA_MODE=1' pda-common/.zsh/aliases-pda.zsh` (exports PDA_MODE)
- `grep -q 'TMUX_SESSION_BUILDER' pda-common/.zsh/aliases-pda.zsh` (exports builder)
- `grep -q 'tmux load-buffer' pda-common/.tmux.conf.local` (clipboard override)

## Checks

| Criterion | Type | Command |
|-----------|------|---------|
| aliases-pda.zsh exists | [STRUCTURAL] | `test -f pda-common/.zsh/aliases-pda.zsh \|\| (echo "FAIL: aliases-pda.zsh not found" && exit 1)` |
| .tmux.conf.local exists | [STRUCTURAL] | `test -f pda-common/.tmux.conf.local \|\| (echo "FAIL: .tmux.conf.local not found" && exit 1)` |
| PDA_MODE exported | [MECHANICAL] | `grep -q 'export PDA_MODE=1' pda-common/.zsh/aliases-pda.zsh \|\| (echo "FAIL: PDA_MODE not exported" && exit 1)` |
| TMUX_SESSION_BUILDER exported | [MECHANICAL] | `grep -q 'TMUX_SESSION_BUILDER' pda-common/.zsh/aliases-pda.zsh \|\| (echo "FAIL: TMUX_SESSION_BUILDER not exported" && exit 1)` |
| Copy-mode uses tmux buffer | [MECHANICAL] | `grep -q 'tmux load-buffer' pda-common/.tmux.conf.local \|\| (echo "FAIL: clipboard not overridden" && exit 1)` |
