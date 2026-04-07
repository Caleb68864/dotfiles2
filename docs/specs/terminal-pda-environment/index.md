---
type: phase-spec-index
master_spec: "docs/specs/2026-04-07-terminal-pda-environment.md"
date: 2026-04-07
sub_specs: 6
---

# Terminal PDA Environment -- Phase Specs

Refined from [2026-04-07-terminal-pda-environment.md](../2026-04-07-terminal-pda-environment.md).

| Sub-Spec | Title | Dependencies | Phase Spec |
|----------|-------|--------------|------------|
| 1 | Shared config prerequisites | none | [sub-spec-1-shared-config-prerequisites.md](sub-spec-1-shared-config-prerequisites.md) |
| 2 | pda-common package structure | 1 | [sub-spec-2-pda-common-package-structure.md](sub-spec-2-pda-common-package-structure.md) |
| 3 | tmux-pda-session script | 1, 2 | [sub-spec-3-tmux-pda-session.md](sub-spec-3-tmux-pda-session.md) |
| 4 | pda-note instant capture | none | [sub-spec-4-pda-note-instant-capture.md](sub-spec-4-pda-note-instant-capture.md) |
| 5 | install-pda.sh installer | 1, 2, 3, 4 | [sub-spec-5-install-pda.md](sub-spec-5-install-pda.md) |
| 6 | justfile PDA recipes | 5 | [sub-spec-6-justfile-pda-recipes.md](sub-spec-6-justfile-pda-recipes.md) |

## Dependency Graph

```
Sub-spec 1 (shared config) ──┬──> Sub-spec 2 (pda-common) ──> Sub-spec 3 (tmux-pda-session) ──┐
                              │                                                                  │
Sub-spec 4 (pda-note) ───────┼──────────────────────────────────────────────────────────────────>│
                              │                                                                  v
                              └─────────────────────────────────────────────> Sub-spec 5 (install-pda.sh) ──> Sub-spec 6 (justfile)
```

## Execution

Run `/forge-run docs/specs/terminal-pda-environment/` to execute all phase specs.
Run `/forge-run docs/specs/terminal-pda-environment/ --sub N` to execute a single sub-spec.
