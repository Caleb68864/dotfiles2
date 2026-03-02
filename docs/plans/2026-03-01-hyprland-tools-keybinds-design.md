# Hyprland Tools & Keybind Refactor Design

**Date:** 2026-03-01
**Status:** Approved

---

## Overview

Add screenshot, color picker, clipboard history, notifications, and screen recording tools to the Hyprland desktop. Refactor existing keybinds into a consistent mnemonic convention.

---

## Tools

### New packages to install
- `grimblast` — ergonomic grim wrapper (region/window/screen capture)
- `satty` — modern screenshot annotation tool (Rust-based)
- `hyprpicker` — Wayland color picker
- `wf-recorder` — lightweight screen recorder (CLI, no OBS overhead)

### Existing tools (already installed)
- `grim` + `slurp` — base screenshot primitives (used by grimblast)
- `cliphist` — clipboard history daemon (already running via exec-once)
- `hyprlauncher` — launcher used for clipboard history picker
- `swaync` — notification daemon (already running)
- `obs-studio` — full-featured recorder (stays for streaming/complex work)

### Screenshot stack
`Print` → `grimblast copysave area` → `satty` opens for annotation → save/copy from satty

### Screen recording toggle
A small shell script (`~/.config/hypr/scripts/toggle-record.sh`) starts `wf-recorder` on first call and kills it on second. Saves to `~/Videos/recordings/YYYY-MM-DD_HH-MM-SS.mp4`.

---

## Keybind Convention

**Principle:** `Super + letter` = apps (mnemonic letter), `Super + arrows` = navigation, `Super + Ctrl` = resize, `Super + Shift` = bigger/secondary version of same concept, `Super + number` = workspaces.

### App Launchers

| Keys | Action | Mnemonic |
|------|--------|----------|
| `Super + Return` | Terminal (kitty) | Standard |
| `Super + W` | Browser (Vivaldi) | **W**eb |
| `Super + E` | File manager (Dolphin) | **E**xplorer |
| `Super + Space` | App launcher (hyprlauncher) | — |

### Window Management

| Keys | Action | Note |
|------|--------|------|
| `Super + Q` | Kill active window | **Q**uit — replaces `Super+Shift+C` |
| `Super + F` | Toggle fullscreen | **F**ullscreen — new |
| `Super + V` | Toggle float | Keep |
| `Super + P` | Pseudo tile (dwindle) | Keep |
| `Super + J` | Toggle split (dwindle) | Keep |
| `Super + M` | Exit Hyprland | Keep |

### Navigation & Resize

| Keys | Action | Note |
|------|--------|------|
| `Super + arrows` | Move focus | Keep |
| `Super + Shift + arrows` | Move window in direction | New |
| `Super + Ctrl + arrows` | Resize window | Keep |
| `Super + Ctrl + H/L/K/J` | Resize (alternate) | Keep |

### Workspaces

All existing workspace binds are unchanged:
- `Super + 1-0` = switch to workspace
- `Super + Shift + 1-0` = move window silently
- `Super + Ctrl + 1-0` = move window + follow
- `Super + S` = toggle scratchpad
- `Super + Shift + S` = move to scratchpad

### Utilities (New)

| Keys | Action |
|------|--------|
| `Print` | Region screenshot → satty annotate → clipboard |
| `Super + Print` | Full screen → clipboard |
| `Super + Shift + Print` | Full screen → save to file |
| `Super + C` | Color picker → clipboard |
| `Super + N` | Toggle swaync notification panel |
| `Super + Shift + V` | Clipboard history picker (cliphist + hyprlauncher) |
| `Super + R` | Toggle screen recording (wf-recorder script) |

### Removed

| Old Keys | Old Action | Replaced by |
|----------|-----------|-------------|
| `Super + Shift + C` | Kill window | `Super + Q` |

---

## Files to Change

1. `hypr/hyprland.conf` — add new binds, replace kill bind
2. `hypr/scripts/toggle-record.sh` — new recording toggle script
3. `packages.txt` — add grimblast, satty, hyprpicker, wf-recorder

---

## Out of Scope

- Submap/vim-leader system (Option 3 — deferred, can revisit later)
- Neovim changes (already set up correctly, `vim` aliased to `nvim`)
- Hypridle/hyprlock config changes
