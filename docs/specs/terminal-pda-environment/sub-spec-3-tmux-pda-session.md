---
type: phase-spec
master_spec: "docs/specs/2026-04-07-terminal-pda-environment.md"
sub_spec: 3
title: "tmux-pda-session script"
dependencies: [1, 2]
date: 2026-04-07
---

# Sub-Spec 3: tmux-pda-session Script

## Scope

Create the PDA tmux session builder script at `pda-common/bin/tmux-pda-session`. This is the PDA equivalent of `bin/bin/tmux-command-center`. It creates 8 windows optimized for PDA use, with window 1 opening today's daily note in nvim.

## Shared Context

- Follow patterns from `bin/bin/tmux-command-center` (comment style, `command -v` guards, session check)
- Follow patterns from `bin/bin/tmux-daily-note` (daily note file creation with frontmatter)
- Session name MUST be "command-center" (shared tmux keybindings reference this name)
- Use `exec tmux attach` at end to replace shell process
- Use `set -e` for error handling
- Scripts must use `${VAR:-default}` for all paths

## Interface Contracts

### Provides
- A tmux session named "command-center" with windows at positions 0-7
- Window 1 contains nvim editing today's daily note

### Requires
- Sub-Spec 1: `TMUX_SESSION_BUILDER` in `.zshrc` points to this script
- Sub-Spec 2: `$OBSIDIAN_VAULT` set in `aliases-pda.zsh`

## Implementation Steps

### Step 1: Create the script file

**File:** `pda-common/bin/tmux-pda-session`

**Header:** Follow `tmux-command-center` pattern with extensive documentation:
- Script purpose
- WINDOW LAYOUT table
- USAGE section
- Difference from desktop (boots into daily note)

### Step 2: Session existence check

Same pattern as `tmux-command-center` lines 56-58:
```bash
SESSION="command-center"

if tmux has-session -t "$SESSION" 2>/dev/null; then
    exec tmux attach -t "$SESSION"
fi
```

### Step 3: Daily note file creation

Before creating the tmux session, ensure today's daily note exists. Follow `tmux-daily-note` pattern:
```bash
VAULT="${OBSIDIAN_VAULT:-$HOME/Notes}"
TODAY="$(date +%Y-%m-%d)"
DAILY_DIR="$VAULT/Calendar Notes/Daily Notes"
DAILY_NOTE="$DAILY_DIR/$TODAY.md"

mkdir -p "$DAILY_DIR"

if [ ! -f "$DAILY_NOTE" ]; then
    cat > "$DAILY_NOTE" << EOF
---
title: "$TODAY"
date: $TODAY
type: daily
tags:
  - daily
---

# $TODAY

EOF
fi
```

### Step 4: Create session with window 1 (notes)

```bash
tmux new-session -d -s "$SESSION" -n note -c "$VAULT"
tmux send-keys -t "$SESSION:1" "nvim '$DAILY_NOTE'" Enter
```

### Step 5: Create window 2 (inbox)

```bash
tmux new-window -t "$SESSION:2" -n inbox -c "$VAULT"
tmux send-keys -t "$SESSION:2" "nvim '$VAULT/Inbox/'" Enter
```

### Step 6: Create windows 3-7 (feeds, calendar, books, media, ssh)

Use `command -v` guards for each:
```bash
if command -v newsboat &> /dev/null; then
    tmux new-window -t "$SESSION:3" -n feed
    tmux send-keys -t "$SESSION:3" "newsboat" Enter
fi

if command -v khal &> /dev/null; then
    tmux new-window -t "$SESSION:4" -n cal
    tmux send-keys -t "$SESSION:4" "khal interactive" Enter
fi

# Window 5: books (detect reader)
if command -v bookratt &> /dev/null; then
    tmux new-window -t "$SESSION:5" -n book
    tmux send-keys -t "$SESSION:5" "bookratt" Enter
elif command -v epy &> /dev/null; then
    tmux new-window -t "$SESSION:5" -n book
    tmux send-keys -t "$SESSION:5" "epy" Enter
fi

# Window 6: media (empty, mpv launched on demand)
tmux new-window -t "$SESSION:6" -n media

# Window 7: ssh (empty, user connects manually)
tmux new-window -t "$SESSION:7" -n ssh
```

### Step 7: Create window 0 (scratch) and attach

```bash
tmux new-window -t "$SESSION:0" -n scratch
tmux select-window -t "$SESSION:1"
exec tmux attach -t "$SESSION"
```

## Verification Commands

- `bash -n pda-common/bin/tmux-pda-session` (syntax check)
- `test -x pda-common/bin/tmux-pda-session || chmod +x pda-common/bin/tmux-pda-session` (executable)
- `grep -q 'command-center' pda-common/bin/tmux-pda-session` (correct session name)
- `grep -q 'OBSIDIAN_VAULT' pda-common/bin/tmux-pda-session` (uses vault env var)

## Checks

| Criterion | Type | Command |
|-----------|------|---------|
| Script exists | [STRUCTURAL] | `test -f pda-common/bin/tmux-pda-session \|\| (echo "FAIL: tmux-pda-session not found" && exit 1)` |
| Script is valid bash | [MECHANICAL] | `bash -n pda-common/bin/tmux-pda-session \|\| (echo "FAIL: tmux-pda-session has syntax errors" && exit 1)` |
| Uses command-center session name | [MECHANICAL] | `grep -q 'command-center' pda-common/bin/tmux-pda-session \|\| (echo "FAIL: wrong session name" && exit 1)` |
| References OBSIDIAN_VAULT | [MECHANICAL] | `grep -q 'OBSIDIAN_VAULT' pda-common/bin/tmux-pda-session \|\| (echo "FAIL: no OBSIDIAN_VAULT reference" && exit 1)` |
