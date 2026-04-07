---
type: phase-spec
master_spec: "docs/specs/2026-04-07-terminal-pda-environment.md"
sub_spec: 1
title: "Shared config prerequisites"
dependencies: []
date: 2026-04-07
---

# Sub-Spec 1: Shared Config Prerequisites

## Scope

Modify shared config files to support PDA mode without breaking desktop behavior. Two changes: (1) make `.zshrc` tmux auto-start use a configurable session builder, (2) add `PDA_MODE` guards to heavy nvim plugins.

## Shared Context

- Trade-off: Compatibility with shared dotfiles over PDA-ideal config
- MUST NOT modify shared config behavior when PDA env vars are not set
- Comments must match the repo's heavily-commented documentation style

## Interface Contracts

### Provides
- `TMUX_SESSION_BUILDER` variable support in `.zshrc` (consumed by Sub-Spec 2's aliases-pda.zsh)
- `PDA_MODE` env var gating in nvim plugin specs (consumed by Sub-Spec 2's aliases-pda.zsh)

### Requires
- Nothing (this is the first sub-spec)

## Implementation Steps

### Step 1: Modify .zshrc tmux auto-start

**File:** `zsh/.zshrc` (lines 300-317)

**Current code (line 310):**
```bash
        if [ -x "$HOME/bin/tmux-command-center" ]; then
            exec "$HOME/bin/tmux-command-center"
```

**Change to:**
```bash
        # Use TMUX_SESSION_BUILDER if set (e.g., by PDA aliases), otherwise
        # fall back to the desktop command-center script.
        local _builder="${TMUX_SESSION_BUILDER:-$HOME/bin/tmux-command-center}"
        if [ -x "$_builder" ]; then
            exec "$_builder"
```

This preserves desktop behavior (TMUX_SESSION_BUILDER is unset -> uses tmux-command-center) while allowing PDA to override it.

**Verify:** `grep -q 'TMUX_SESSION_BUILDER' zsh/.zshrc`

### Step 2: Add PDA_MODE guard to dap.lua

**File:** `nvim/lua/plugins/dap.lua`

The file returns a table of plugin specs. Wrap the entire return with a PDA_MODE check. Find the `return {` line and add the guard:

```lua
-- Skip debug adapters on PDA (saves ~50MB RAM)
if vim.env.PDA_MODE then return {} end

return {
  -- existing content unchanged
```

**Verify:** `grep -q 'PDA_MODE' nvim/lua/plugins/dap.lua`

### Step 3: Add PDA_MODE guard to ai.lua

**File:** `nvim/lua/plugins/ai.lua`

Same pattern as dap.lua:

```lua
-- Skip AI plugins on PDA (saves memory and avoids API dependency)
if vim.env.PDA_MODE then return {} end

return {
  -- existing content unchanged
```

**Verify:** `grep -q 'PDA_MODE' nvim/lua/plugins/ai.lua`

### Step 4: Add PDA_MODE guard to treesitter.lua

**File:** `nvim/lua/plugins/treesitter.lua`

Same pattern:

```lua
-- Skip Treesitter on PDA (biggest RAM consumer, ~100MB with parsers)
if vim.env.PDA_MODE then return {} end

return {
  -- existing content unchanged
```

**Verify:** `grep -q 'PDA_MODE' nvim/lua/plugins/treesitter.lua`

### Step 5: Add PDA_MODE guard to telescope in editor.lua

**File:** `nvim/lua/plugins/editor.lua`

This file returns multiple plugins. Only guard the telescope entry, not the whole file. Find the telescope plugin spec (starts with `"nvim-telescope/telescope.nvim"`) and add `enabled`:

```lua
  {
    "nvim-telescope/telescope.nvim",
    enabled = not vim.env.PDA_MODE,  -- Use fzf directly on PDA
    branch = "0.1.x",
    -- rest unchanged
```

**Verify:** `grep -q 'PDA_MODE' nvim/lua/plugins/editor.lua`

### Step 6: Verify desktop behavior unchanged

Run nvim without PDA_MODE to confirm all plugins still load:
```bash
nvim --headless "+Lazy! sync" +qa 2>/dev/null
```

## Verification Commands

- `grep -q 'TMUX_SESSION_BUILDER' zsh/.zshrc` (exits 0 = pass)
- `grep -q 'PDA_MODE' nvim/lua/plugins/dap.lua` (exits 0 = pass)
- `grep -q 'PDA_MODE' nvim/lua/plugins/ai.lua` (exits 0 = pass)
- `grep -q 'PDA_MODE' nvim/lua/plugins/treesitter.lua` (exits 0 = pass)
- `grep -q 'PDA_MODE' nvim/lua/plugins/editor.lua` (exits 0 = pass)

## Checks

| Criterion | Type | Command |
|-----------|------|---------|
| TMUX_SESSION_BUILDER in .zshrc | [MECHANICAL] | `grep -q 'TMUX_SESSION_BUILDER' zsh/.zshrc \|\| (echo "FAIL: TMUX_SESSION_BUILDER not found in .zshrc" && exit 1)` |
| PDA_MODE in dap.lua | [MECHANICAL] | `grep -q 'PDA_MODE' nvim/lua/plugins/dap.lua \|\| (echo "FAIL: PDA_MODE not found in dap.lua" && exit 1)` |
| PDA_MODE in ai.lua | [MECHANICAL] | `grep -q 'PDA_MODE' nvim/lua/plugins/ai.lua \|\| (echo "FAIL: PDA_MODE not found in ai.lua" && exit 1)` |
| PDA_MODE in treesitter.lua | [MECHANICAL] | `grep -q 'PDA_MODE' nvim/lua/plugins/treesitter.lua \|\| (echo "FAIL: PDA_MODE not found in treesitter.lua" && exit 1)` |
| PDA_MODE in editor.lua | [MECHANICAL] | `grep -q 'PDA_MODE' nvim/lua/plugins/editor.lua \|\| (echo "FAIL: PDA_MODE not found in editor.lua" && exit 1)` |
