# Hyprland Plugins Installation Guide

> **Note:** `hyprscroller` was removed. It is incompatible with Hyprland 0.54+ due to a layout API rewrite and the upstream repo was archived in April 2025. All hyprscroller keybindings and plugin references have been removed from `hyprland.conf`.


## Installation

When you're logged into Hyprland, run:

```bash
cd ~/dotfiles
./install-hyprland-plugins.sh
```

This will install two plugins:
1. **hy3** - i3-style manual tiling
2. **hyprtags** - DWM-style tag system

## Plugin 1: hy3 (i3-Style Tiling)

**Repository:** https://github.com/outfoxxed/hy3

### What it does:
- Provides i3/sway-style manual tiling
- Allows you to create containers and manually control window layouts
- More precise control over window positioning than dwindle/master

### Basic Usage:
Once installed, you'll need to add keybindings to use hy3. Example keybinds:

```
# hy3 layout controls
bind = $mainMod, H, hy3:movefocus, l
bind = $mainMod, L, hy3:movefocus, r
bind = $mainMod, K, hy3:movefocus, u
bind = $mainMod, J, hy3:movefocus, d

bind = $mainMod SHIFT, H, hy3:movewindow, l
bind = $mainMod SHIFT, L, hy3:movewindow, r
bind = $mainMod SHIFT, K, hy3:movewindow, u
bind = $mainMod SHIFT, J, hy3:movewindow, d
```

## Plugin 2: hyprtags (DWM-Style Tags)

**Repository:** https://github.com/JoaoCostaIFG/hyprtags

### What it does:
Hyprtags emulates aspects of DWM's tag system with some key differences:
- **Windows belong to ONE tag at a time** (not multiple like pure DWM)
- You **can view multiple tags simultaneously** by toggling them
- This is a **workspace management system**, not a layout
- Works with any tiling layout (dwindle, master, hy3)

### Example Workflow:
1. Move terminal to tag 2: `Super + Shift + 2`
2. Move Vivaldi to tag 1: `Super + Shift + 1`
3. Switch to tag 1: `Super + 1` (shows only Vivaldi)
4. Toggle tag 2 visibility: `Super + Ctrl + 2` (now shows both Vivaldi and terminal)
5. Switch to tag 2: `Super + 2` (shows only terminal)

### Keybindings (Already Configured!):

Your hyprland.conf already has these keybindings set up:

```
# Switch to tag (replaces standard workspace switching)
Super + [1-9, 0] = Switch to tag

# Move window to tag (window follows you)
Super + Shift + [1-9, 0] = Move window to tag (silent)

# Toggle tag visibility (view multiple tags at once)
Super + Ctrl + [1-9, 0] = Toggle tag visibility
```

### How It Works:

The plugin generates custom dispatchers that replace Hyprland's standard workspace commands:
- `tags-workspace` - Switch to a tag
- `tags-movetoworkspacesilent` - Move window to tag
- `tags-toggleworkspace` - Toggle viewing a tag

These are already configured in your hyprland.conf and will work once you install the plugin.

## Understanding Layouts vs Workspace Management

### Tiling Layouts (How windows are arranged):
1. **dwindle** (default) - Dynamic tiling, default Hyprland layout
2. **master** - Master-stack layout (toggle with Super+T)
3. **hy3** - i3-style manual tiling

### Workspace Management (How you organize windows):
- **hyprtags** - DWM-style tag system (replaces standard workspaces)

**These work together!** For example:
- Use hyprtags for workspace management (tags 1-9)
- Use master layout for window tiling
- Press Super+T to switch between dwindle/master while using hyprtags

To switch the tiling layout:
- Press **Super + T** to toggle between dwindle and master
- You can manually switch with: `hyprctl keyword general:layout [dwindle|master]`

## Verifying Installation

After running the install script, verify plugins are loaded:

```bash
hyprpm list
```

You should see both hy3 and hyprtags listed as enabled.

## Troubleshooting

If plugins don't load:
1. Make sure you ran the installation script from within Hyprland
2. Check that `exec-once = hyprpm reload -n` is in your hyprland.conf (already added)
3. Reload Hyprland: `hyprctl reload`
4. Check plugin status: `hyprpm list`

## Next Steps

After installation:
1. **Hyprtags keybindings are already configured!** Just start using them:
   - `Super + [1-9]` to switch tags
   - `Super + Shift + [1-9]` to move windows to tags
   - `Super + Ctrl + [1-9]` to toggle viewing multiple tags
2. Experiment with tiling layouts:
   - Press `Super + T` to toggle between dwindle and master
   - Hyprtags works with any layout!
3. Read the full documentation for hy3 if you want i3-style manual tiling
4. Your Waybar layout indicator shows which tiling layout you're using (dwindle/master)
