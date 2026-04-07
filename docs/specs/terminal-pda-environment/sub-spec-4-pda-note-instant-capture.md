---
type: phase-spec
master_spec: "docs/specs/2026-04-07-terminal-pda-environment.md"
sub_spec: 4
title: "pda-note instant capture"
dependencies: []
date: 2026-04-07
---

# Sub-Spec 4: pda-note Instant Capture Script

## Scope

Create a quick-note capture script at `pda-common/bin/pda-note`. Generates a timestamped Markdown file with YAML frontmatter in the vault Inbox and opens it in nvim.

## Shared Context

- Follow patterns from `bin/bin/tmux-daily-note` (file creation, frontmatter, vault path handling)
- Use `${OBSIDIAN_VAULT:-$HOME/Notes}` for vault path
- Accept `--vault PATH` argument for multi-vault support
- Use `mkdir -p` to create Inbox if missing
- Use `$EDITOR` (defaults to nvim)

## Interface Contracts

### Provides
- `pda-note` command available via `~/bin/pda-note` (after stow)
- Creates Obsidian-compatible Markdown files with frontmatter

### Requires
- Nothing (standalone script, no dependencies on other sub-specs)

## Implementation Steps

### Step 1: Create the script file

**File:** `pda-common/bin/pda-note`

**Header:** Follow `tmux-daily-note` pattern:
```bash
#!/bin/bash
# =============================================================================
# pda-note -- Instant note capture for PDA
# =============================================================================
# Creates a timestamped Markdown file in the Obsidian vault Inbox and opens
# it in the editor. Designed for zero-friction capture on the PDA.
#
# USAGE:
#   pda-note                          # Create note in default vault
#   pda-note --vault ~/Notes/Personal # Create note in specific vault
#
# ENVIRONMENT:
#   OBSIDIAN_VAULT  -- Default vault path (fallback: ~/Notes)
#   EDITOR          -- Editor to open the note (fallback: nvim)
# =============================================================================

set -e
```

### Step 2: Argument parsing

```bash
VAULT="${OBSIDIAN_VAULT:-$HOME/Notes}"

while [ $# -gt 0 ]; do
    case "$1" in
        --vault) VAULT="$2"; shift 2 ;;
        *) echo "Usage: pda-note [--vault PATH]"; exit 1 ;;
    esac
done
```

### Step 3: Generate filename and create file

```bash
INBOX="$VAULT/Inbox"
TIMESTAMP="$(date +%Y-%m-%d-%H%M%S)"
DATE_ISO="$(date +%Y-%m-%dT%H:%M:%S)"
NOTE="$INBOX/$TIMESTAMP.md"

mkdir -p "$INBOX"

cat > "$NOTE" << EOF
---
title: ""
date: $DATE_ISO
type: note
tags:
  - inbox
---

EOF
```

### Step 4: Open in editor with cursor after frontmatter

```bash
${EDITOR:-nvim} "+normal Go" "$NOTE"
```

The `+normal Go` positions the cursor at the end of the file on a new line, ready to type.

## Verification Commands

- `bash -n pda-common/bin/pda-note` (syntax check)
- `OBSIDIAN_VAULT=/tmp/test-vault pda-common/bin/pda-note` (creates file -- would need interactive test)
- `grep -q 'OBSIDIAN_VAULT' pda-common/bin/pda-note` (uses env var)

## Checks

| Criterion | Type | Command |
|-----------|------|---------|
| Script exists | [STRUCTURAL] | `test -f pda-common/bin/pda-note \|\| (echo "FAIL: pda-note not found" && exit 1)` |
| Script is valid bash | [MECHANICAL] | `bash -n pda-common/bin/pda-note \|\| (echo "FAIL: pda-note has syntax errors" && exit 1)` |
| Uses OBSIDIAN_VAULT | [MECHANICAL] | `grep -q 'OBSIDIAN_VAULT' pda-common/bin/pda-note \|\| (echo "FAIL: no OBSIDIAN_VAULT reference" && exit 1)` |
| Writes frontmatter with type: note | [MECHANICAL] | `grep -q 'type: note' pda-common/bin/pda-note \|\| (echo "FAIL: frontmatter missing type: note" && exit 1)` |
