# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **dotfiles repository** for Arch Linux (EndeavourOS) managed with **GNU Stow**. It provides a complete desktop environment using Hyprland (Wayland compositor) with Waybar, along with development tools including Neovim, Zsh, Tmux, and support for Python and C# development.

**Key Architecture Pattern:** Each top-level directory (e.g., `hypr/`, `waybar/`, `nvim/`) is a GNU Stow "package" that mirrors the target directory structure from `$HOME`. For example, `waybar/.config/waybar/config.jsonc` stows to `~/.config/waybar/config.jsonc`.

## Common Commands

### Installation and Deployment

```bash
# Initial setup (installs packages, Oh-My-Zsh, and stows all configs)
bash install.sh

# Deploy all packages manually
stow -vRt "$HOME" zsh tmux nvim hypr waybar wofi hyprpaper hyprlock hypridle swaync git fonts

# Deploy a single package
stow -vRt "$HOME" waybar

# Remove a package (unstow)
stow -DvRt "$HOME" waybar

# Preview changes (dry run)
stow -nvt "$HOME" waybar

# Re-stow after making changes (restow = unstow + stow)
stow -Rv -t "$HOME" waybar
```

### Package Management

```bash
# Update all packages (uses yay AUR helper)
yay -Syu

# Install packages from packages.txt
grep -v '^#' packages.txt | grep -v '^$' | xargs yay -S --needed --noconfirm

# Add new package to the system
echo "package-name" >> packages.txt
yay -S package-name
```

### Hyprland Commands

```bash
# Reload Hyprland config (while in Hyprland)
# Press: Super + Shift + R (if configured)
# Or kill and restart waybar
killall waybar && waybar &

# Test Hyprland config for errors
hyprctl reload

# Check Hyprland logs
cat /tmp/hypr/$(ls -t /tmp/hypr | head -n 1)/hyprland.log

# Test waybar config
waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css
```

### Waybar Development

```bash
# Test waybar for errors
waybar 2>&1 | head -20

# Kill and restart waybar
killall waybar && waybar &

# Validate JSON config (waybar uses JSONC with comments)
# Note: config.jsonc allows comments unlike standard JSON
```

### Neovim Commands

```vim
" Inside Neovim - Plugin management
:Lazy                  " Open plugin manager
:Lazy sync             " Update all plugins
:Lazy clean            " Remove unused plugins
:Mason                 " Open LSP/DAP installer
:checkhealth           " Check Neovim health

" LSP/DAP verification
:LspInfo               " Check LSP status
:DapInstall            " Install debugger adapters
```

### Git Workflow

```bash
# After making changes to dotfiles
cd ~/.files
git add .
git commit -m "Update: describe changes"
git push

# Pull updates from remote
cd ~/.files
git pull
stow -Rv -t "$HOME" <changed-package>
```

## Architecture Details

### GNU Stow Package Structure

Each subdirectory follows the pattern:
```
package-name/
  └── .config/               # Maps to ~/.config/
      └── app-name/          # Maps to ~/.config/app-name/
          └── config-file    # Maps to ~/.config/app-name/config-file
```

**Important:** Stow creates symlinks. When editing configs via `~/.config/waybar/config.jsonc`, you're actually editing `~/.files/waybar/.config/waybar/config.jsonc`. Changes must be committed to the git repo.

### Configuration File Locations

**Live configs (symlinked to dotfiles repo):**
- `~/.zshrc` → `~/dotfiles/zsh/.zshrc`
- `~/.config/hypr/hyprland.conf` → `~/dotfiles/hypr/.config/hypr/hyprland.conf`
- `~/.config/waybar/config.jsonc` → `~/dotfiles/waybar/.config/waybar/config.jsonc`
- `~/.config/waybar/style.css` → `~/dotfiles/waybar/.config/waybar/style.css`
- `~/.config/nvim/init.lua` → `~/dotfiles/nvim/.config/nvim/init.lua`

**Additional working directory:**
- `/home/caleb/.config/waybar` is specified as an additional working directory

### Theme System

**Tokyo Night** is the primary color scheme used across all configs:
- Waybar: CSS variables in `style.css`
- Hyprland: Border colors in `hyprland.conf` (`#7aa2f7` blue / `#bb9af7` purple)
- Kitty: Full Tokyo Night palette in `kitty.conf`
- Yazi: `theme.toml` using Tokyo Night palette
- Neovim: Tokyo Night theme plugin

### Waybar Architecture

Waybar config is split into two files:
1. **config.jsonc** - Module configuration, layout, and behavior
2. **style.css** - Visual styling with Tokyo Night colors

**Key modules in use:**
- `hyprland/workspaces` - Workspace switcher with icons
- `wlr/taskbar` - Window list with click-to-switch
- `bluetooth` - Bluetooth status and management
- `keyboard-state` - Caps Lock and Num Lock indicators
- `clock`, `cpu`, `memory`, `temperature`, `battery` - System info
- `pulseaudio`, `network` - Audio and network controls
- `tray` - System tray

**Styling classes pattern:**
- `#module-name` - Targets the module
- `#module-name.state` - Targets module in specific state (e.g., `#bluetooth.connected`)
- `button.active` - Active state styling (bold font, highlighted background)

### Hyprland Window Rules

Window rules auto-assign applications to workspaces:
- Workspace 1: Web browsers (firefox, vivaldi, chromium)
- Workspace 2: Terminals (kitty, alacritty)
- Workspace 3: File managers (dolphin, thunar)
- Workspace 4: Communication (discord, vesktop)
- Workspace 5: Entertainment (spotify, steam)
- Workspace 6: Development (VS Code)

Opacity rules set transparency per-application (e.g., kitty at 90% opacity).

### Neovim Configuration

Single-file config: `nvim/.config/nvim/init.lua`
- Uses lazy.nvim for plugin management
- LSP servers auto-installed via Mason
- Configured for Python (pyright, debugpy) and C# (omnisharp, netcoredbg)
- CodeCompanion as primary AI assistant (requires ANTHROPIC_API_KEY env var)

### Zsh Configuration

Features Oh-My-Zsh with plugins:
- zsh-autosuggestions, zsh-syntax-highlighting, fzf-tab
- Starship prompt (alternative to Powerlevel10k)
- Tmux auto-starts "battlestation" session on terminal launch
- History config: 100k entries, shared across sessions

## File Editing Best Practices

### When Editing Waybar

1. **Edit the source files in the dotfiles repo:**
   ```bash
   cd ~/dotfiles/waybar/.config/waybar
   nvim config.jsonc    # or style.css
   ```

2. **Test for errors:**
   ```bash
   waybar 2>&1 | head -20
   ```

3. **Apply changes:**
   ```bash
   killall waybar && waybar &
   ```

4. **Commit changes:**
   ```bash
   cd ~/dotfiles
   git add waybar/
   git commit -m "waybar: describe changes"
   ```

**Common Waybar issues:**
- CSS pseudo-elements (`::before`, `::after`) are NOT supported (GTK CSS parser limitation)
- JSONC allows comments, but be careful with trailing commas
- Module names must match exactly (case-sensitive)

### When Editing Hyprland Config

1. **Edit the source:**
   ```bash
   nvim ~/dotfiles/hypr/.config/hypr/hyprland.conf
   ```

2. **Reload config:**
   - In Hyprland: `Super + Shift + R` (if bound)
   - Or: `hyprctl reload`

3. **Check for errors:**
   ```bash
   hyprctl reload    # Will show errors if config is invalid
   ```

**Important Hyprland notes:**
- Animations use bezier curves defined in the `animations` section
- Window rules use `windowrulev2` syntax (v2 is preferred)
- Gaps: `gaps_in` (between windows), `gaps_out` (from screen edges)
- Current config has 0 gaps for a tiled look

### When Adding New Packages

1. **Add to packages.txt:**
   ```bash
   echo "new-package" >> ~/dotfiles/packages.txt
   ```

2. **Install:**
   ```bash
   yay -S new-package
   ```

3. **Commit changes:**
   ```bash
   cd ~/dotfiles
   git add packages.txt
   git commit -m "Add new-package to dependencies"
   ```

## Troubleshooting Commands

```bash
# Check if user is in input group (required for keyboard-state module)
groups | grep input
# If not present:
sudo usermod -aG input $USER
# Then logout and login

# Verify stow symlinks
ls -la ~/.config/waybar    # Should show -> /home/caleb/dotfiles/waybar/.config/waybar

# Check for conflicting files (not symlinks)
find ~ -maxdepth 1 -type f -name ".*rc"
find ~/.config -maxdepth 2 -type d ! -type l

# Font cache issues
fc-cache -rv ~/.local/share/fonts
fc-list | grep JetBrains    # Verify fonts are installed

# Hyprland not starting
cat ~/.local/share/wayland-sessions/hyprland.desktop
which Hyprland

# Neovim LSP not working
nvim -c "checkhealth" -c "sleep 3" -c "qa!"    # Check health from terminal
```

## Important Context for File Operations

### Always Edit Source Files, Not Symlinks

When modifying configs, you must edit files within the `~/dotfiles/` directory tree. These are the source files that git tracks. The files in `~/.config/` are symlinks created by Stow.

**Correct workflow:**
```bash
# Edit source
nvim ~/dotfiles/waybar/.config/waybar/config.jsonc

# Verify changes (symlink automatically reflects changes)
cat ~/.config/waybar/config.jsonc

# Commit from dotfiles repo
cd ~/dotfiles
git add waybar/
git commit -m "Update waybar config"
```

### Backup System

The `install.sh` script automatically backs up existing configs to `~/dotfiles-backup-[timestamp]/` before stowing. This prevents data loss and allows restoration:

```bash
# List backups
ls -la ~ | grep dotfiles-backup

# Restore a backup
cp -r ~/dotfiles-backup-20251021_123456/.config/waybar ~/.config/
```

## Integration Points

### Environment Variables

Set in `.zshrc` or `.zshenv`:
- `ANTHROPIC_API_KEY` - Required for Neovim CodeCompanion
- `EDITOR=nvim` - Default editor
- WSL detection and clipboard integration (if running on WSL)

### Auto-start Applications

Configured in `hypr/.config/hypr/hyprland.conf` under `exec-once`:
- waybar & hyprpaper
- swaync (notification daemon)
- hypridle (idle management)
- polkit-gnome (authentication agent)
- clipboard managers (cliphist)
- User applications: steam, discord (start minimized)

### Keyboard State Module Requirements

The `keyboard-state` waybar module requires:
1. User in `input` group
2. Access to `/dev/input/event*` devices
3. Proper udev rules (usually automatic on Arch)

If not working, verify with:
```bash
ls -la /dev/input/
groups $USER
```
