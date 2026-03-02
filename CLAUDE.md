# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **dotfiles repository** for Arch Linux (EndeavourOS) managed with **GNU Stow**. It provides a complete desktop environment using Hyprland (Wayland compositor) with Waybar, along with development tools including Neovim, Zsh, Tmux, and support for Python and C# development.

**Key Architecture Pattern:** Each top-level directory is a GNU Stow "package" stowed directly to its specific target directory — **not** to `$HOME`. Config files sit directly in the package root with no hidden directory nesting. For example, `waybar/config.jsonc` stows to `~/.config/waybar/config.jsonc` because the stow target for `waybar` is `~/.config/waybar`.

**Git remote:** `git@github.com:Caleb68864/dotfiles2.git`

## Stow Package Targets

Each package has a specific stow target. Never use a blanket `stow -t "$HOME"` for config packages.

| Package | Stow Target | Key Files |
|---------|-------------|-----------|
| `hypr` | `~/.config/hypr` | hyprland.conf, hyprpaper.conf, hypridle.conf, hyprlock.conf, scripts/ |
| `waybar` | `~/.config/waybar` | config.jsonc, style.css, scripts/ |
| `nvim` | `~/.config/nvim` | init.lua, lazy-lock.json |
| `kitty` | `~/.config/kitty` | kitty.conf |
| `swaync` | `~/.config/swaync` | config.json, style.css |
| `yazi` | `~/.config/yazi` | yazi.toml, keymap.toml, theme.toml |
| `fonts` | `~/.local/share/fonts` | JetBrainsMono Nerd Font *.ttf |
| `zsh` | `$HOME` | .zshrc, .zsh/, .config/starship.toml |
| `tmux` | `$HOME` | .tmux.conf |
| `git` | `$HOME` | .gitconfig |
| `scripts` | `$HOME` | setup-github-ssh.sh |
| `bin` | `$HOME` | get-fonts.sh, switch-theme.sh, deploy-all, undeploy |
| `themes` | `$HOME` | gruvbox.conf, tokyo-night.conf |

## Common Commands

### Installation and Deployment

```bash
# Initial setup (installs packages, Oh-My-Zsh, and stows all configs)
bash install.sh

# Install all packages from packages.txt
grep -v '^#' packages.txt | grep -v '^$' | xargs yay -S --needed

# Deploy a single package (use the correct target for that package)
stow -Rv -t "$HOME/.config/hypr"   hypr
stow -Rv -t "$HOME/.config/waybar" waybar
stow -Rv -t "$HOME/.config/nvim"   nvim
stow -Rv -t "$HOME/.config/kitty"  kitty
stow -Rv -t "$HOME/.config/yazi"   yazi
stow -Rv -t "$HOME"                zsh tmux git

# Remove a package
stow -Dv -t "$HOME/.config/waybar" waybar

# Preview changes (dry run)
stow -nv -t "$HOME/.config/waybar" waybar
```

### Package Management

```bash
# Update all packages (uses yay AUR helper)
yay -Syu

# Install packages from packages.txt
grep -v '^#' packages.txt | grep -v '^$' | xargs yay -S --needed

# Add new package
echo "package-name" >> packages.txt
yay -S package-name
```

### Hyprland Commands

```bash
# Reload Hyprland config
hyprctl reload

# Check Hyprland logs
cat /tmp/hypr/$(ls -t /tmp/hypr | head -n 1)/hyprland.log

# Kill and restart waybar
killall waybar && waybar &
```

### Git Workflow

```bash
# After making changes to dotfiles
cd ~/dotfiles
git add .
git commit -m "scope: describe changes"
git push

# Pull updates from remote
cd ~/dotfiles
git pull
stow -Rv -t "$HOME/.config/hypr" hypr   # re-stow updated package
```

## Architecture Details

### GNU Stow Package Structure

Packages are **flat** — config files live directly in the package directory:

```
hypr/
├── hyprland.conf      → ~/.config/hypr/hyprland.conf
├── hyprpaper.conf     → ~/.config/hypr/hyprpaper.conf
├── hypridle.conf      → ~/.config/hypr/hypridle.conf
├── hyprlock.conf      → ~/.config/hypr/hyprlock.conf
└── scripts/           → ~/.config/hypr/scripts/
    └── random-wallpaper.sh

waybar/
├── config.jsonc       → ~/.config/waybar/config.jsonc
├── style.css          → ~/.config/waybar/style.css
└── scripts/           → ~/.config/waybar/scripts/

nvim/
└── init.lua           → ~/.config/nvim/init.lua
```

There is **no** `.config/app/` nesting inside package directories. The stow target handles the path mapping.

### Configuration File Locations

**Live configs (symlinked from dotfiles repo):**
- `~/.zshrc` → `~/dotfiles/zsh/.zshrc`
- `~/.config/hypr/hyprland.conf` → `~/dotfiles/hypr/hyprland.conf`
- `~/.config/waybar/config.jsonc` → `~/dotfiles/waybar/config.jsonc`
- `~/.config/waybar/style.css` → `~/dotfiles/waybar/style.css`
- `~/.config/nvim/init.lua` → `~/dotfiles/nvim/init.lua`
- `~/.config/yazi/yazi.toml` → `~/dotfiles/yazi/yazi.toml`

Always edit files in `~/dotfiles/` — never edit `~/.config/` directly (those are symlinks).

### Theme System

**Tokyo Night** is the primary color scheme used across all configs:
- Waybar: CSS variables in `waybar/style.css`
- Hyprland: Border colors `#7aa2f7` (blue) / `#bb9af7` (purple) in `hypr/hyprland.conf`
- Kitty: Full Tokyo Night palette in `kitty/kitty.conf`
- Yazi: `yazi/theme.toml` using Tokyo Night palette
- Neovim: Tokyo Night theme plugin

**Key Tokyo Night colors:**
- bg: `#1a1b26`, bg1: `#1f2335`, bg2: `#24283b`, bg3: `#414868`
- fg: `#c0caf5`, fg1: `#a9b1d6`
- blue: `#7aa2f7`, purple: `#bb9af7`, cyan: `#7dcfff`
- green: `#9ece6a`, yellow: `#e0af68`, red: `#f7768e`, orange: `#ff9e64`

### Hyprland Window Rules

**NEVER use `windowrulev2`** — deprecated in Hyprland 0.54+.

Use **block syntax** for rules with float/center/size/move:
```
windowrule {
    name = descriptive-name
    match:class = ^(app-class)$

    float = yes
    size = 1200 800
    center = yes
    workspace = 3 silent
}
```

Use **inline syntax** only for simple workspace assignments:
```
windowrule = workspace 4 silent, match:class ^(discord)$
```

**Do NOT use `match:class` inline for boolean rules** (float, center, size) — they require block syntax.

**Current workspace assignments:**
- Workspace 1: Web browsers (vivaldi-stable, firefox, chromium)
- Workspace 2: Terminals (kitty)
- Workspace 3: File managers (thunar, yazi-files)
- Workspace 4: Communication (discord, vesktop, Element, element)
- Workspace 5: Entertainment (spotify)
- Workspace 7: Steam
- Workspace 8: Games (heroic)

### Hyprland Notes

- Config reloads cleanly with `hyprctl reload` — always verify after edits
- **hyprscroller plugin is permanently removed** — incompatible with Hyprland 0.54+ layout rewrite, repo archived April 2025. Do not attempt to re-add.
- `hyprpm reload -n 2>/dev/null` in exec-once suppresses errors when no plugins are installed
- Steam launched with `env GDK_SCALE=1 steam -silent` to prevent restart-on-boot dialog caused by global `GDK_SCALE=2`
- Wallpaper: `hypr/scripts/random-wallpaper.sh` picks a random image from `~/Pictures/Wallpapers/` at boot; falls back to EndeavourOS system wallpaper if empty

### Waybar Architecture

Waybar config is split into two files:
1. **config.jsonc** - Module configuration, layout, and behavior
2. **style.css** - Visual styling with Tokyo Night colors

**Key modules in use:**
- `hyprland/workspaces` - Workspace switcher with icons
- `custom/hyprland-layout` - Layout indicator (dwindle/master)
- `hyprland/window` - Active window title
- `bluetooth`, `keyboard-state`, `idle_inhibitor`
- `clock`, `cpu`, `memory`, `temperature`, `battery`
- `pulseaudio`, `network`, `tray`

**Common Waybar issues:**
- CSS pseudo-elements (`::before`, `::after`) are NOT supported (GTK limitation)
- JSONC allows comments, but watch for trailing commas
- Module names are case-sensitive

### File Managers

Two file managers are configured:
- **Thunar** (GUI): `Super+E` → opens on workspace 3
- **Yazi** (TUI in Kitty):
  - `Super+Y` → floating 1200×800, stays on current workspace
  - `Super+Shift+Y` → opens on workspace 3
  - `Shift+D` in Yazi → drag selected files with ripdrag
  - Launched with `kitty --class yazi -e yazi` (bypasses tmux auto-start)
  - Image preview via Kitty native protocol (auto-detected)
  - PDF preview via pdftoppm (poppler)

### Neovim Configuration

Single-file config: `nvim/init.lua`
- Uses lazy.nvim for plugin management
- LSP servers auto-installed via Mason
- Configured for Python (pyright, debugpy) and C# (omnisharp, netcoredbg)
- CodeCompanion as primary AI assistant (requires ANTHROPIC_API_KEY env var)

### Zsh Configuration

Features Oh-My-Zsh with plugins:
- zsh-autosuggestions, zsh-syntax-highlighting, fzf-tab
- Starship prompt
- Tmux auto-starts "battlestation" session on terminal launch
- History config: 100k entries, shared across sessions

### Auto-start Applications (exec-once)

```
waybar
hyprpaper
~/.config/hypr/scripts/random-wallpaper.sh
swaync
wl-paste --type text --watch cliphist store
wl-paste --type image --watch cliphist store
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
hypridle
env GDK_SCALE=1 steam -silent
element-desktop
/usr/lib/pam_kwallet_init
hyprpm reload -n 2>/dev/null; sleep 1; hyprctl reload
```

## File Editing Best Practices

### When Editing Hyprland Config

```bash
nvim ~/dotfiles/hypr/hyprland.conf
hyprctl reload    # verify no errors
```

### When Editing Waybar

```bash
nvim ~/dotfiles/waybar/config.jsonc   # or style.css
killall waybar && waybar &
```

### When Editing Yazi

```bash
nvim ~/dotfiles/yazi/yazi.toml      # main config
nvim ~/dotfiles/yazi/theme.toml     # colors
nvim ~/dotfiles/yazi/keymap.toml    # keybindings
# Changes apply on next yazi launch
```

### When Adding New Stow Packages

1. Create the package directory directly under `~/dotfiles/`
2. Put config files directly in it (no hidden dir nesting)
3. Add to `PACKAGES` array in `install.sh`
4. Add to `STOW_TARGETS` map in `install.sh` with correct target
5. Run `stow -Rv -t "$TARGET" packagename`

## Troubleshooting Commands

```bash
# Verify stow symlinks are correct
ls -la ~/.config/hypr/
ls -la ~/.config/waybar/

# Check if user is in input group (required for keyboard-state module)
groups | grep input
sudo usermod -aG input $USER   # if missing, then logout/login

# Font cache issues
fc-cache -rv ~/.local/share/fonts
fc-list | grep JetBrains

# Hyprland logs
cat /tmp/hypr/$(ls -t /tmp/hypr | head -n 1)/hyprland.log

# Neovim LSP not working
nvim -c "checkhealth" -c "sleep 3" -c "qa!"
```

## Integration Points

### Environment Variables

Set in `zsh/.zshrc` or `~/.zshenv`:
- `ANTHROPIC_API_KEY` - Required for Neovim CodeCompanion
- `EDITOR=nvim` - Default editor
- `GDK_SCALE=2` - Global HiDPI scaling (overridden to 1 for Steam)

### Keyboard State Module Requirements

The `keyboard-state` waybar module requires:
1. User in `input` group
2. Access to `/dev/input/event*` devices

```bash
groups $USER   # verify 'input' is listed
```

### Wallpapers

Drop images into `~/Pictures/Wallpapers/` (jpg, jpeg, png, webp).
`random-wallpaper.sh` picks one randomly at each login via hyprpaper IPC.
Fallback: `/usr/share/wallpapers/EndeavourOS/contents/screenshot.png`
