# Neovim as Daily Driver — Cross-Platform Design

**Date:** 2026-09-08
**Status:** Approved design, not yet implemented
**Supersedes:** `docs/neovim-windows-setup-notes.md` (now stale — every plugin it
lists as "to add on Windows" has since been added to the Linux config)

---

## Goal

Make the existing Neovim config a daily driver for text editing on **both**
Linux (EndeavourOS/Hyprland) and **Windows**, with three concrete outcomes:

1. It runs on Windows without the terminal fighting it.
2. It has a persistent scratchpad — park a command or a clipboard fragment,
   close the editor, come back and it is still there.
3. Common things are clickable with a mouse.

### Non-goals

- A Notepad++ keybinding layer. Explicitly rejected during design: the only
  thing wanted from Notepad++ was the never-save scratchpad, not `Ctrl+C/V/Z`
  semantics. Vim's normal-mode keys stay untouched.
- Syncing scratches between machines. Explicitly rejected — machine-local.
- WSL. Native Windows Neovim only.
- Any change to LSP, DAP, treesitter, completion, or testing config beyond
  what cross-platform compatibility requires.

---

## Context: what already exists

`~/dotfiles/nvim` is already a full IDE config — 55 plugins, LSP + Mason, DAP,
Telescope, nvim-tree, treesitter, conform, Tokyo Night, JetBrainsMono Nerd Font
12. `mouse = "a"` and `clipboard = "unnamedplus"` are already set. Deployed to
`~/.config/nvim` via GNU Stow symlinks.

The gaps against the goal are narrow and specific. This spec addresses only
those.

---

## Decisions taken

| Decision | Choice | Why |
|---|---|---|
| Windows runtime | **Neovide GUI + native Windows nvim** | A terminal emulator is the thing that broke this last time. Windows Terminal mangles `Ctrl+Shift+*` and `Alt+*` and cannot distinguish `Ctrl+I` from `Tab`. Removing the terminal from the loop removes the class of problem, and adds real mouse, ligatures, and smooth scroll. |
| Notepad++ keymap layer | **None** | Not wanted. See non-goals. |
| Scratchpad shape | **Hybrid** — one eternal quick pad + named scratches | Covers both stated uses (10-second parking, and keeping something that turned out to matter) without deciding up front which one is happening. |
| Scratch sync | **Machine-local** | Zero conflict risk, zero setup. |
| Scratch implementation | **Hand-rolled**, not `snacks.nvim` | Snacks keys scratches to cwd+branch, which is the opposite of one-eternal-global-pad. ~120 lines of Lua against Telescope, which is already installed. No new dependency. |
| Cross-platform structure | **Runtime detection in a shared config** | Divergence is ~40 lines. A separate Windows branch rots. A per-platform overlay directory is ceremony ahead of need — but is the clean refactor if branching ever exceeds ~100 lines. |
| Mouse affordances | **All four** — tabs, right-click, single-click tree, Neovide polish | |

---

## Section 1 — Cross-platform foundation

### New: `lua/config/platform.lua`

Required first in `init.lua`. Exposes:

```lua
M.is_windows   -- vim.fn.has("win32") == 1
M.is_wsl       -- /proc/version contains "microsoft"
M.is_neovide   -- vim.g.neovide ~= nil
M.has(exe)     -- vim.fn.executable(exe) == 1
```

`is_wsl` is included despite WSL being a non-goal: it costs one line, and it is
the flag needed to disable clipboard and GUI assumptions if the config is ever
opened under WSL incidentally. Nothing else in this spec branches on it.

### Changes driven by it

| Concern | Change |
|---|---|
| `vim-tmux-navigator` | `cond = not platform.is_windows` |
| `lazygit.nvim` | `cond = platform.has("lazygit")` |
| `yazi.nvim` | `cond = platform.has("yazi")` |
| Shell | On Windows, set `shell` to PowerShell 7 with correct `shellcmdflag`, `shellquote`, `shellxquote`. Without this, `:!` and Telescope's grep misbehave under cmd.exe. |
| Treesitter compiler | `require("nvim-treesitter.install").compilers = { "zig", "clang", "cl", "gcc" }` |
| Python provider | On Windows, pin `vim.g.python3_host_prog` so Mason and DAP resolve the right interpreter |

**Treesitter on Windows is the single most common cause of a Windows Neovim
install feeling broken** — it needs a C compiler and errors on every new
filetype without one. `zig` via scoop is the cheapest fix. This must not be
skipped.

### New: `install.ps1` (dotfiles root)

- Creates a directory symlink `%LOCALAPPDATA%\nvim` → `dotfiles\nvim`.
- Detects whether Developer Mode is enabled or the shell is elevated, and
  reports which is needed — rather than failing cryptically. Symlink creation
  on Windows requires one or the other.
- Installs externals in one shot:
  `scoop install neovim neovide zig ripgrep fd git gh lazygit yazi fzf`
- Installs JetBrainsMono Nerd Font from the existing `dotfiles/fonts/`.

### Not ported

Everything in the old porting doc's "What Doesn't Port" table (Hyprland,
Waybar, swaync, ripdrag, hypridle/hyprshot/hyprpicker, `GDK_SCALE`), plus tmux
itself.

---

## Section 2 — The scratchpad

### Layout

`~/scratch/` — machine-local. `vim.fn.expand("~")` resolves correctly on both
platforms (`%USERPROFILE%` on Windows).

```
~/scratch/quick.md              THE pad. Always exists. Never prompts.
~/scratch/2026-09-08-1432.md    named scratches
```

The directory currently holds one stray `install-davinci-resolve.sh`; it is
otherwise free to claim.

### Keymaps

`<leader>n` chosen as the namespace — verified free. `<leader>s` is already
Spectre's Search/Replace group. `<leader><leader>` is verified free.

| Key | Action |
|---|---|
| `<leader><leader>` | Toggle the quick pad in a centered float |
| `<leader>nn` | New named scratch (timestamped, opens immediately) |
| `<leader>nf` | Telescope over `~/scratch`, newest first |
| `<leader>ng` | Live-grep across `~/scratch` |
| `<leader>np` | Promote quick pad → named scratch, then clear the pad |
| `<leader>nd` | Delete the scratch currently being viewed |

### Behavior requirements

The "never save" property is the entire point of the feature. Specifically:

- The directory and `quick.md` are created on first use. Missing files are not
  an error.
- Autosave fires on `BufLeave`, `FocusLost`, and `VimLeavePre` for any buffer
  under `~/scratch`, silently, and **only when the buffer is modified**.
- `q` or `<Esc>` closes the float, saving on the way out.
- Filetype is `markdown`, so parked shell commands in fenced blocks get syntax
  highlighting.
- `swapfile` is off for these buffers — no `.swp` recovery prompt after closing
  a scratch by closing its window.
- The user is never shown a filename prompt or a save dialog, in any flow.

### Picker labelling

The Telescope picker labels each scratch by its **first non-empty line**, not
its timestamp filename, with the timestamp as secondary text for ordering. A
scratch beginning `az login --tenant ...` lists as that. Without this, named
scratches are unfindable without opening each one.

### Promote

`<leader>np` moves the quick pad's contents to a dated file and leaves an empty
pad, in one keypress, with no dialog. It exists because the decision that
something matters usually happens mid-scribble.

### Explicitly not doing

**No auto-trim, no rotation, no size cap on the quick pad.** Automatically
deleting something parked is the failure mode that would destroy trust in the
feature. Pruning is manual.

---

## Section 3 — The mouse/GUI layer

### Clickable tabs — new `lua/plugins/bufferline.lua`

- Left-click switches, middle-click closes, drag reorders, `X` per tab.
- `showtabline = 2`; `mousemoveevent = true` (required for hover highlights).
- An `offsets` entry for nvim-tree so the tab bar starts beside the tree rather
  than running underneath it.
- `diagnostics = "nvim_lsp"` so tabs show error counts.
- Tokyo Night ships bufferline highlights; no manual color work.
- **Rebind `<S-l>`/`<S-h>`** from `:bnext`/`:bprevious` to
  `:BufferLineCycleNext`/`Prev`. Otherwise keyboard cycling follows buffer-number
  order while tabs display in a different order.
- Add `<leader>bp` (pin) and `<leader>bc` (pick-close) under the existing
  `<leader>b` group.

### Right-click menu

Neovim 0.12 already defaults `mousemodel` to `popup_setpos` and ships a small
built-in `PopUp` menu. **Extend it; do not replace it.**

- Buffer menu gains Go to Definition, Find References, Rename Symbol, Format —
  above a separator, with existing Cut/Copy/Paste below.
- LSP entries are rebuilt on a `MenuPopup` autocmd so they appear only when a
  language server is attached to that buffer. A menu offering "Go to Definition"
  in a plain text file and silently doing nothing is worse than omitting it.
- nvim-tree gets its own menu: New File, New Folder, Rename, Delete, Copy Path.

### Single-click file tree

A custom `on_attach` that **extends** nvim-tree's defaults rather than replacing
them, so all existing bindings survive.

- `<LeftRelease>` opens a file / toggles a folder. Guarded to fire only when the
  release lands on an actual node — otherwise drag-selecting in the tree opens
  random files.
- `<RightMouse>` moves the cursor to the node under the pointer *before* opening
  the menu, so the menu acts on what was clicked.

### Neovide — new `lua/config/neovide.lua`

Fully guarded by `if vim.g.neovide then`, so it is inert under terminal Neovim
on Linux.

- `guifont = "JetBrainsMono Nerd Font:h12"` — matches the existing Kitty config.
- `Ctrl+=` / `Ctrl+-` / `Ctrl+0` zoom in/out/reset, plus `Ctrl+ScrollWheel`.
- Smooth scroll, cursor animation with particle trail, `remember_window_size`,
  `hide_mouse_when_typing`, refresh rate, window padding.
- **All animation settings live in one labelled block behind a single
  `local animations = true` switch.** Cursor particle effects and smooth scroll
  feel good locally and bad over RDP; killing them must be a one-line edit.

---

## Section 4 — Testing and rollout

### Staging

Build and prove on Linux first, then port. Debugging a new scratch module and a
new platform simultaneously is how this stalls.

All work on a `nvim-crossplatform` branch in `~/dotfiles`.

1. **Linux, features only** — scratchpad, bufferline, right-click, nvim-tree
   clicks. Daily-drive it. If it is not better than the current setup, that is
   discovered cheaply and no Windows work was wasted.
2. **Linux, platform layer** — add `platform.lua` and the `cond =` guards.
   Verify no regression: on Linux every guard evaluates true and behavior is
   identical.
3. **Windows** — `install.ps1`, scoop deps, Neovide. The platform is then the
   only new variable.

### Automated verification

- **`tests/scratch_spec.lua`** under `PlenaryBustedDirectory` (plenary is already
  a dependency). Covers path resolution, file creation, promote, first-line
  title extraction, and autosave-only-when-modified. This module holds text the
  user cares about; "promote silently ate my pad" is the worst available bug.
- **Clean load** — `nvim --headless "+Lazy! sync" +qa` against a scrubbed
  `stdpath("data")`, asserting exit code 0 and no errors. This is the check that
  catches a Windows-only load failure.
- **`:checkhealth`** output parsed for `ERROR` lines.

### Manual checklist (once per platform)

Mouse clicks, Neovide rendering, and right-click menus cannot be automated.

- [ ] Left-click a tab switches buffer; middle-click closes it; drag reorders
- [ ] `<S-l>`/`<S-h>` cycle in the same order the tabs are displayed
- [ ] Single-click in nvim-tree opens a file and toggles a folder
- [ ] Right-click in a code buffer shows LSP entries; in a plain text buffer it does not
- [ ] Right-click in nvim-tree acts on the node under the pointer, not the cursor
- [ ] `<leader><leader>` opens the pad; type; close Neovim entirely; reopen; text is still there
- [ ] `<leader>np` produces a dated file and leaves the pad empty
- [ ] `Ctrl+ScrollWheel` zooms; window size is remembered across restarts

### Risk and rollback

The one real risk is breaking a config currently depended on.

- All work on a branch.
- `lazy-lock.json` is committed, so a bad plugin update is revertible.
- Stage 1 modifies exactly three existing things: the `<S-l>`/`<S-h>` rebinds in
  `lua/config/keymaps.lua`, an `on_attach` added to nvim-tree in
  `lua/plugins/editor.lua`, and the built-in `PopUp` menu. Everything else in
  stage 1 is new files, so reverting it is a small, well-bounded diff.

### Documentation

`docs/neovim-windows-setup-notes.md` is deleted on completion. Its content is
either stale (plugins since added to Linux) or absorbed into this spec.
