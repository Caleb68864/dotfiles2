# Hyprland Tools & Keybind Refactor Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Install screenshot/annotation/color-picker/recorder tools and refactor Hyprland keybinds into a consistent mnemonic convention.

**Architecture:** All changes land in `hypr/.config/hypr/hyprland.conf` (symlinked via Stow), a new toggle-record script, and `packages.txt`. No new stow packages needed — the `hypr` package already exists.

**Tech Stack:** Hyprland, grimblast, satty, hyprpicker, wf-recorder, cliphist, wofi, swaync, yay (AUR helper)

**Design doc:** `docs/plans/2026-03-01-hyprland-tools-keybinds-design.md`

---

### Task 1: Install packages and update packages.txt

**Files:**
- Modify: `packages.txt`

**Step 1: Add packages to packages.txt**

Append to `packages.txt`:
```
grimblast
satty
hyprpicker
wf-recorder
```

**Step 2: Install packages**

```bash
yay -S --needed --noconfirm grimblast satty hyprpicker wf-recorder
```

Expected: All four packages install without error. Verify with:
```bash
which grimblast satty hyprpicker wf-recorder
```
Expected output:
```
/usr/bin/grimblast
/usr/bin/satty
/usr/bin/hyprpicker
/usr/bin/wf-recorder
```

**Step 3: Commit**

```bash
cd ~/dotfiles
git add packages.txt
git commit -m "feat: add grimblast, satty, hyprpicker, wf-recorder packages"
```

---

### Task 2: Create screen recording toggle script

**Files:**
- Create: `hypr/.config/hypr/scripts/toggle-record.sh`

**Step 1: Create scripts directory**

```bash
mkdir -p ~/dotfiles/hypr/.config/hypr/scripts
```

**Step 2: Write the toggle script**

Create `hypr/.config/hypr/scripts/toggle-record.sh`:

```bash
#!/bin/bash
# Toggle screen recording with wf-recorder
# First call: starts recording. Second call: stops recording.

PIDFILE="/tmp/wf-recorder.pid"
SAVEDIR="$HOME/Videos/recordings"

mkdir -p "$SAVEDIR"

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    # Recording is running — stop it
    kill "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
    notify-send "Screen Recording" "Recording saved to $SAVEDIR" --icon=media-record
else
    # Not running — start it
    FILENAME="$SAVEDIR/$(date +%Y-%m-%d_%H-%M-%S).mp4"
    wf-recorder -f "$FILENAME" &
    echo $! > "$PIDFILE"
    notify-send "Screen Recording" "Recording started..." --icon=media-record
fi
```

**Step 3: Make it executable**

```bash
chmod +x ~/dotfiles/hypr/.config/hypr/scripts/toggle-record.sh
```

**Step 4: Verify the symlink resolves correctly**

```bash
ls -la ~/.config/hypr/scripts/toggle-record.sh
```
Expected: symlink pointing into dotfiles.

**Step 5: Commit**

```bash
cd ~/dotfiles
git add hypr/.config/hypr/scripts/toggle-record.sh
git commit -m "feat: add wf-recorder toggle script"
```

---

### Task 3: Refactor existing keybinds

**Files:**
- Modify: `hypr/.config/hypr/hyprland.conf` (lines ~256–276, the keybindings section)

The goal is:
- Replace `Super+Shift+C` (killactive) with `Super+Q`
- Add `Super+F` for fullscreen
- Add `Super+Shift+arrows` to move window in a direction

**Step 1: Replace the kill bind**

Find this line:
```
bind = $mainMod SHIFT, C, killactive,
```
Replace with:
```
bind = $mainMod, Q, killactive,
```

**Step 2: Add fullscreen bind**

After the `bind = $mainMod, V, togglefloating,` line, add:
```
bind = $mainMod, F, fullscreen, 0
```

**Step 3: Add move-window-with-arrows binds**

After the focus arrow binds block, add:
```
# Move active window with mainMod + SHIFT + arrow keys
bind = $mainMod SHIFT, left, movewindow, l
bind = $mainMod SHIFT, right, movewindow, r
bind = $mainMod SHIFT, up, movewindow, u
bind = $mainMod SHIFT, down, movewindow, d
```

**Step 4: Reload Hyprland to verify no parse errors**

```bash
hyprctl reload
```
Expected: `ok` — if you see errors, recheck the edited lines for typos.

**Step 5: Test the binds manually**
- Press `Super+Q` on a window — it should close
- Press `Super+F` on a window — it should go fullscreen
- Press `Super+F` again — it should exit fullscreen
- Press `Super+Shift+right` — focused window should move right

**Step 6: Commit**

```bash
cd ~/dotfiles
git add hypr/.config/hypr/hyprland.conf
git commit -m "refactor: reorganize keybinds - Super+Q kill, Super+F fullscreen, Shift+arrows move window"
```

---

### Task 4: Add screenshot keybinds

**Files:**
- Modify: `hypr/.config/hypr/hyprland.conf` — add to the keybindings section

**Step 1: Add screenshot binds**

At the end of the keybindings section (before `### WINDOWS AND WORKSPACES ###`), add:

```
# Screenshots
# Print: region select → annotate with satty → copy to clipboard on save
bind = , Print, exec, grimblast --notify copysave area - | satty --filename -
# Super+Print: full screen → clipboard
bind = $mainMod, Print, exec, grimblast --notify copy screen
# Super+Shift+Print: full screen → save to ~/Pictures/screenshots/
bind = $mainMod SHIFT, Print, exec, mkdir -p ~/Pictures/screenshots && grimblast --notify save screen ~/Pictures/screenshots/$(date +%Y-%m-%d_%H-%M-%S).png
```

**Step 2: Reload Hyprland**

```bash
hyprctl reload
```
Expected: `ok`

**Step 3: Test screenshot**
- Press `Print` — a crosshair should appear to select a region, then satty opens for annotation
- In satty, press `Ctrl+C` or click copy — screenshot goes to clipboard
- Press `Super+Print` — full screen captured to clipboard immediately

**Step 4: Commit**

```bash
cd ~/dotfiles
git add hypr/.config/hypr/hyprland.conf
git commit -m "feat: add screenshot keybinds (Print, Super+Print, Super+Shift+Print)"
```

---

### Task 5: Add utility keybinds

**Files:**
- Modify: `hypr/.config/hypr/hyprland.conf` — add after screenshot section

**Step 1: Add utility binds**

```
# Utilities
# Super+C: color picker → hex value to clipboard
bind = $mainMod, C, exec, hyprpicker -a
# Super+N: toggle swaync notification panel
bind = $mainMod, N, exec, swaync-client -t
# Super+Shift+V: clipboard history picker
bind = $mainMod SHIFT, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy
# Super+R: toggle screen recording
bind = $mainMod, R, exec, ~/.config/hypr/scripts/toggle-record.sh
```

**Step 2: Reload Hyprland**

```bash
hyprctl reload
```
Expected: `ok`

**Step 3: Test each utility bind**
- `Super+C` — cursor should turn into a picker; click a color and the hex value should be in clipboard (`wl-paste` to verify)
- `Super+N` — swaync notification panel should slide open/close
- `Super+Shift+V` — wofi should appear with clipboard history
- `Super+R` — a notification should appear saying "Recording started..."; press again to stop

**Step 4: Commit**

```bash
cd ~/dotfiles
git add hypr/.config/hypr/hyprland.conf
git commit -m "feat: add utility keybinds (color picker, notifications, clipboard history, screen recording)"
```

---

### Task 6: Final verification

**Step 1: Check all symlinks are intact**

```bash
ls -la ~/.config/hypr/
```
Expected: all `.conf` files and `scripts/` are symlinks pointing into `~/dotfiles/`.

**Step 2: Full keybind audit**

```bash
grep "^bind" ~/.config/hypr/hyprland.conf
```

Verify the output contains:
- `$mainMod, Q, killactive` (not the old `SHIFT, C`)
- `$mainMod, F, fullscreen`
- `$mainMod SHIFT, left, movewindow` (and right/up/down)
- `, Print, exec, grimblast`
- `$mainMod, C, exec, hyprpicker`
- `$mainMod, N, exec, swaync-client`
- `$mainMod SHIFT, V, exec, cliphist`
- `$mainMod, R, exec, .*toggle-record`

**Step 3: Verify no duplicate or conflicting binds**

```bash
grep "^bind" ~/.config/hypr/hyprland.conf | awk '{print $3, $4}' | sort | uniq -d
```
Expected: no output (no duplicates).

**Step 4: Final commit if anything was missed**

```bash
cd ~/dotfiles
git status
# Stage and commit any remaining unstaged changes
git add -p
git commit -m "chore: finalize hyprland keybind refactor"
```
