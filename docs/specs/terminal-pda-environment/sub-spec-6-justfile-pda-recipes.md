---
type: phase-spec
master_spec: "docs/specs/2026-04-07-terminal-pda-environment.md"
sub_spec: 6
title: "justfile PDA recipes"
dependencies: [5]
date: 2026-04-07
---

# Sub-Spec 6: justfile PDA Recipes

## Scope

Add PDA-specific recipes to the existing `justfile`: `install-pda`, `stow-pda`, `unstow-pda`.

## Shared Context

- Follow existing justfile patterns (recipe headers, bash shebang blocks, TARGETS array)
- Use CURRENT package names and stow targets
- `pda-common` stows to `$HOME` (not in TARGETS array = defaults to $HOME)

## Interface Contracts

### Provides
- `just install-pda` recipe
- `just stow-pda` recipe
- `just unstow-pda` recipe

### Requires
- Sub-Spec 5: `install-pda.sh` exists

## Implementation Steps

### Step 1: Add PDA recipes to justfile

Append these recipes to the end of `justfile`:

```justfile
# Install PDA environment (run on a fresh Pi)
install-pda:
    cd "{{dotfiles}}" && bash install-pda.sh

# Stow only PDA-relevant packages
stow-pda:
    #!/bin/bash
    cd "{{dotfiles}}"
    declare -A TARGETS=( \
        ["nvim"]="$HOME/.config/nvim" \
        ["atuin"]="$HOME/.config/atuin" \
        ["themes"]="$HOME/.config/themes" \
        ["newsboat"]="$HOME/.config/newsboat" \
    )
    for pkg in zsh tmux nvim git atuin themes bin scripts newsboat pda-common; do
        TARGET="${TARGETS[$pkg]:-$HOME}"
        mkdir -p "$TARGET"
        stow -Rv -t "$TARGET" "$pkg"
    done

# Unstow PDA packages
unstow-pda:
    #!/bin/bash
    cd "{{dotfiles}}"
    declare -A TARGETS=( \
        ["nvim"]="$HOME/.config/nvim" \
        ["atuin"]="$HOME/.config/atuin" \
        ["themes"]="$HOME/.config/themes" \
        ["newsboat"]="$HOME/.config/newsboat" \
    )
    for pkg in pda-common zsh tmux nvim git atuin themes bin scripts newsboat; do
        TARGET="${TARGETS[$pkg]:-$HOME}"
        stow -Dv -t "$TARGET" "$pkg" 2>/dev/null
    done
```

## Verification Commands

- `just --list | grep -q 'install-pda'` (recipe listed)
- `just --list | grep -q 'stow-pda'` (recipe listed)
- `just --list | grep -q 'unstow-pda'` (recipe listed)

## Checks

| Criterion | Type | Command |
|-----------|------|---------|
| install-pda recipe exists | [MECHANICAL] | `just --list \| grep -q 'install-pda' \|\| (echo "FAIL: install-pda recipe not found" && exit 1)` |
| stow-pda recipe exists | [MECHANICAL] | `just --list \| grep -q 'stow-pda' \|\| (echo "FAIL: stow-pda recipe not found" && exit 1)` |
| unstow-pda recipe exists | [MECHANICAL] | `just --list \| grep -q 'unstow-pda' \|\| (echo "FAIL: unstow-pda recipe not found" && exit 1)` |
