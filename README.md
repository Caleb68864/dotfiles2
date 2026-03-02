# Caleb's Dotfiles

A dotfiles configuration for **EndeavourOS/Arch Linux** featuring **Hyprland**, **Neovim**, **Zsh** with **Starship** prompt, and a complete development environment for **Python** and **C#**.

## Features

### Desktop Environment
- **Hyprland** - Wayland compositor with smooth animations and tiling
- **Waybar** - Status bar with system metrics, workspaces, and tray
- **hyprlauncher** - Application launcher
- **Hyprpaper** - Wallpaper manager with random-on-boot support
- **Hyprlock** - Screen locker
- **Hypridle** - Idle management (dims at 5min, locks at 10min)
- **SwayNC** - Notification daemon with notification center
- **Kitty** - GPU-accelerated terminal emulator

### Development
- **Neovim** - Full IDE setup with LSP, DAP, and AI assistants
  - LSP servers: Pyright (Python), OmniSharp (C#), Lua, TypeScript
  - Debuggers: debugpy (Python), netcoredbg (C#)
  - AI: CodeCompanion (primary, requires ANTHROPIC_API_KEY)
  - Treesitter, Completion, File explorer, Fuzzy finder
- **Python** - Full development stack
- **C# / .NET** - Complete toolchain with debugging support

### Shell & Terminal
- **Zsh** - Powerful shell with Oh-My-Zsh
- **Tmux** - Terminal multiplexer with auto-attach to "battlestation" session
- **Starship** - Fast, minimal prompt
- **fzf** - Fuzzy finder with custom keybindings
- **bat** - Cat clone with syntax highlighting
- **eza** - Modern ls replacement

### Tools & Utilities
- **Git** - Version control with custom configuration
- **ripgrep** - Fast search tool
- **hyprshot** - Screenshot utility
- **hyprpicker** - Color picker
- **Gruvbox Dark Hard** - Color scheme throughout

## Quick Start

### Installation

```bash
# Clone the repository
git clone git@github.com:Caleb68864/dotfiles2.git ~/dotfiles

# Navigate to the directory
cd ~/dotfiles

# Run the installation script
bash install.sh
```

The installation script will:
1. Install `yay` AUR helper (if not present)
2. Install all packages from `packages.txt`
3. Install Oh-My-Zsh and plugins (zsh-autosuggestions, zsh-syntax-highlighting, fzf-tab)
4. **Backup existing configurations** to `~/dotfiles-backup-[timestamp]/`
5. Deploy dotfiles using GNU Stow
6. Install lazy.nvim for Neovim
7. Refresh font cache
8. Offer to change your default shell to Zsh

### Post-Installation

1. **Restart your terminal** or run:
   ```bash
   exec zsh
   ```

2. **Configure Neovim**:
   ```bash
   nvim
   # Run these commands inside Neovim:
   :Lazy
   :Mason
   :checkhealth
   ```

3. **Update Git config** with your information:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

4. **Add wallpapers** (optional):
   - Drop `.jpg`, `.png`, or `.webp` images into `~/Pictures/Wallpapers/`
   - A random one is set on each login automatically
   - If the folder is empty, the EndeavourOS default wallpaper is used

5. **Configure monitors** (if needed):
   - Edit `~/dotfiles/hypr/hyprland.conf`
   - Update the monitor configuration section

## GNU Stow Usage

This repository uses **GNU Stow** for managing symlinks. Each subdirectory is a "package" stowed to a specific target directory. Packages with config files going to `~/.config/<app>/` are stowed directly to that target — no hidden directories in the dotfiles repo.

### Deploy All Packages

```bash
cd ~/dotfiles
bash install.sh
```

### Deploy a Single Package

```bash
cd ~/dotfiles

# Packages that stow to ~/.config/<app>
stow -Rv -t "$HOME/.config/hypr"    hypr
stow -Rv -t "$HOME/.config/waybar"  waybar
stow -Rv -t "$HOME/.config/nvim"    nvim
stow -Rv -t "$HOME/.config/kitty"   kitty
stow -Rv -t "$HOME/.config/swaync"  swaync
stow -Rv -t "$HOME/.local/share/fonts" fonts

# Packages that stow to $HOME
stow -Rv -t "$HOME" zsh tmux git scripts bin themes
```

### Remove a Package

```bash
stow -Dv -t "$HOME/.config/hypr" hypr
```

### Dry Run (Preview Changes)

```bash
stow -nv -t "$HOME/.config/nvim" nvim
```

### Available Packages

| Package | Stow Target | Contents |
|---------|-------------|----------|
| `hypr` | `~/.config/hypr` | hyprland.conf, hyprpaper.conf, hypridle.conf, hyprlock.conf, scripts/ |
| `waybar` | `~/.config/waybar` | config.jsonc, style.css, scripts/ |
| `nvim` | `~/.config/nvim` | init.lua, lazy-lock.json |
| `kitty` | `~/.config/kitty` | kitty.conf |
| `swaync` | `~/.config/swaync` | config.json, style.css |
| `fonts` | `~/.local/share/fonts` | JetBrainsMono Nerd Font variants |
| `zsh` | `$HOME` | .zshrc, .zsh/, .config/starship.toml |
| `tmux` | `$HOME` | .tmux.conf |
| `git` | `$HOME` | .gitconfig |
| `scripts` | `$HOME` | setup-github-ssh.sh |
| `bin` | `$HOME` | get-fonts.sh, switch-theme.sh, deploy-all, undeploy |
| `themes` | `$HOME` | gruvbox.conf, tokyo-night.conf |

## Key Bindings

### Hyprland

#### Apps & System

| Key Combo | Action |
|-----------|--------|
| `Super + Return` | Open terminal (Kitty) |
| `Super + Space` | Open application launcher (hyprlauncher) |
| `Super + W` | Open web browser (Vivaldi) |
| `Super + E` | Open file manager (Dolphin) |
| `Super + L` | Lock screen (Hyprlock) |
| `Super + M` | Exit Hyprland |

#### Windows

| Key Combo | Action |
|-----------|--------|
| `Super + Q` | Close active window |
| `Super + F` | Toggle fullscreen |
| `Super + V` | Toggle floating |
| `Super + P` | Pseudo tile (dwindle) |
| `Super + J` | Toggle split (dwindle) |
| `Super + Arrow Keys` | Move focus |
| `Super + Shift + Arrows` | Move window in direction |
| `Super + Ctrl + Arrows` | Resize window |

#### Utilities

| Key Combo | Action |
|-----------|--------|
| `Super + N` | Toggle notification center (SwayNC) |
| `Super + C` | Color picker → clipboard |
| `Super + R` | Toggle screen recording |
| `Super + Shift + V` | Clipboard history picker |
| `Super + Shift + W` | Reload Waybar |
| `Print` | Screenshot region → annotate (satty) |
| `Super + Print` | Screenshot full screen → clipboard |
| `Super + Shift + Print` | Screenshot full screen → save to file |

#### Workspaces

| Key Combo | Action |
|-----------|--------|
| `Super + 1-0` | Switch to workspace 1-10 |
| `Super + Shift + 1-0` | Move window to workspace silently |
| `Super + Ctrl + 1-0` | Move window to workspace + follow |
| `Super + S` | Toggle scratchpad |
| `Super + Shift + S` | Move window to scratchpad |

### Workspaces

Workspaces are organized by purpose with icons in Waybar:

| Workspace | Purpose | Auto-assigned Applications |
|-----------|---------|---------------------------|
| 1 | Web Browsers | Firefox, Vivaldi, Chromium |
| 2 | Terminals | Kitty |
| 3 | File Managers | Dolphin, Thunar |
| 4 | Communication | Discord, Vesktop, Element |
| 5 | Entertainment | Spotify, Steam |
| 6 | Development | VS Code |
| 8 | Games | Heroic Games Launcher |

Only shows workspaces with open windows. Click workspace icon in Waybar to switch.

### Zsh

| Key Combo | Action |
|-----------|--------|
| `Ctrl + R` | Fuzzy history search |
| `Ctrl + T` | Fuzzy file search |
| `Alt + C` | Fuzzy directory change |
| `Ctrl + P` | Previous command |
| `Ctrl + N` | Next command |

### Tmux

**Auto-Start:** Zsh automatically starts or attaches to a tmux session called **"battlestation"** when you open a terminal.

#### Prefix Key
The prefix key is `Ctrl + a` (instead of default `Ctrl + b`)

#### Session Management
| Key Combo | Action |
|-----------|--------|
| `Ctrl + a` then `d` | Detach from session |
| `tmux attach -t battlestation` | Manually attach to session |
| `tmux ls` | List all sessions |

#### Window Management
| Key Combo | Action |
|-----------|--------|
| `Ctrl + a` then `c` | Create new window |
| `Ctrl + a` then `n` | Next window |
| `Ctrl + a` then `p` | Previous window |
| `Ctrl + a` then `0-9` | Switch to window number |

#### Pane Management
| Key Combo | Action |
|-----------|--------|
| `Ctrl + a` then `\|` | Split pane vertically |
| `Ctrl + a` then `-` | Split pane horizontally |
| `Ctrl + a` then `h/j/k/l` | Navigate panes (vim-style) |
| `Alt + Arrow Keys` | Navigate panes (no prefix needed) |
| `Ctrl + a` then `H/J/K/L` | Resize pane |
| `Ctrl + a` then `x` | Close pane |

#### Copy Mode (Vi-style)
| Key Combo | Action |
|-----------|--------|
| `Ctrl + a` then `[` | Enter copy mode |
| `v` | Begin selection (in copy mode) |
| `y` | Copy selection to clipboard |
| `q` | Exit copy mode |

#### Misc
| Key Combo | Action |
|-----------|--------|
| `Ctrl + a` then `r` | Reload tmux config |
| `Ctrl + a` then `?` | Show all keybindings |

**Disable Auto-Start:** Comment out the "Tmux Auto-Start" section in `~/dotfiles/zsh/.zshrc`

### Neovim

#### General
| Key | Action |
|-----|--------|
| `Space` | Leader key |
| `<leader>e` | Toggle file explorer |
| `<Esc>` | Clear search highlight |

#### LSP
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Show references |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions |
| `<leader>f` | Format file |

#### Telescope (Fuzzy Finder)
| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>fh` | Find help |
| `<leader>fr` | Find recent files |

#### DAP (Debugger)
| Key | Action |
|-----|--------|
| `F5` | Start/Continue debugging |
| `F10` | Step over |
| `F11` | Step into |
| `F12` | Step out |
| `<leader>b` | Toggle breakpoint |
| `<leader>B` | Conditional breakpoint |

#### AI (CodeCompanion)
| Key | Action |
|-----|--------|
| `<leader>cc` | Open CodeCompanion chat |
| `<leader>ci` | CodeCompanion inline |
| `<leader>ca` | CodeCompanion actions |

## Configuration

### Neovim

#### LSP Servers

Configured LSP servers (auto-installed via Mason):
- **pyright** - Python
- **omnisharp** - C#
- **lua_ls** - Lua
- **ts_ls** - TypeScript/JavaScript
- **bashls** - Bash
- **jsonls** - JSON

#### AI Assistant

**CodeCompanion** requires an Anthropic API key:
```bash
export ANTHROPIC_API_KEY="your-key-here"
```
Add this to `~/dotfiles/zsh/.zshrc` or `~/.zshenv`.

### Wallpapers

Drop images into `~/Pictures/Wallpapers/`. A random one is selected each login via `~/.config/hypr/scripts/random-wallpaper.sh`. Supported formats: jpg, jpeg, png, webp.

The EndeavourOS default wallpaper is used as a fallback when the folder is empty.

### Hyprland

#### Animations

Smooth animations based on custom bezier curves:
- `easeOutQuint` - Smooth ease-out
- `easeInOutCubic` - Balanced ease in/out
- `almostLinear` - Nearly linear for workspaces
- `quick` - Fast animations for fades

Edit in `~/dotfiles/hypr/hyprland.conf` under the `animations` section.

#### Screen Recording

`Super + R` toggles recording via `~/.config/hypr/scripts/toggle-record.sh`.
Recordings are saved to `~/Videos/recordings/YYYY-MM-DD_HH-MM-SS.mp4`.

### Zsh & Starship

Edit `~/dotfiles/zsh/.config/starship.toml` to customize the prompt. See [Starship docs](https://starship.rs/config/).

## Directory Structure

```
~/dotfiles/
├── install.sh                  # Bootstrap installation script
├── packages.txt                # AUR packages to install
├── README.md
├── bin/                        # Helper scripts → $HOME
│   ├── get-fonts.sh
│   ├── switch-theme.sh
│   ├── deploy-all
│   └── undeploy
├── fonts/                      # Fonts → ~/.local/share/fonts
│   └── JetBrainsMonoNerdFont-*.ttf
├── git/                        # Git config → $HOME
│   └── .gitconfig
├── hypr/                       # All Hyprland configs → ~/.config/hypr
│   ├── hyprland.conf
│   ├── hyprpaper.conf
│   ├── hypridle.conf
│   ├── hyprlock.conf
│   └── scripts/
│       ├── random-wallpaper.sh
│       └── toggle-record.sh    # (planned)
├── kitty/                      # Kitty terminal → ~/.config/kitty
│   └── kitty.conf
├── nvim/                       # Neovim → ~/.config/nvim
│   ├── init.lua
│   └── lazy-lock.json
├── scripts/                    # Utility scripts → $HOME
│   └── setup-github-ssh.sh
├── swaync/                     # Notification daemon → ~/.config/swaync
│   ├── config.json
│   └── style.css
├── themes/                     # Theme files → $HOME
│   ├── gruvbox.conf
│   └── tokyo-night.conf
├── tmux/                       # Tmux → $HOME
│   └── .tmux.conf
├── waybar/                     # Waybar → ~/.config/waybar
│   ├── config.jsonc
│   ├── style.css
│   └── scripts/
└── zsh/                        # Zsh → $HOME
    ├── .zshrc
    ├── .zsh/
    │   ├── aliases.zsh
    │   ├── functions.zsh
    │   └── keybindings.zsh
    └── .config/
        └── starship.toml
```

## Troubleshooting

### Stow Conflicts

The install script automatically backs up conflicting files to `~/dotfiles-backup-[timestamp]/`.

**Manual fix:**
```bash
# Remove the conflicting file/dir, then stow
rm ~/.config/hypr/hyprland.conf
stow -Rv -t "$HOME/.config/hypr" hypr
```

**Restore from backup:**
```bash
ls ~/dotfiles-backup-*
cp -r ~/dotfiles-backup-20260301_120000/.config/hypr ~/.config/
```

### Neovim Issues

**LSP not working:**
```vim
:checkhealth
:Mason
```

**Plugin errors:**
```vim
:Lazy sync
:Lazy clean
```

### Hyprland

**Waybar not showing:**
```bash
killall waybar && waybar &
```

**Check Hyprland logs:**
```bash
cat /tmp/hypr/$(ls -t /tmp/hypr | head -n 1)/hyprland.log
```

**Reload config:**
```bash
hyprctl reload
```

### Keyboard State Module (Waybar)

The `keyboard-state` module requires the user to be in the `input` group:
```bash
sudo usermod -aG input $USER
# Log out and back in
```

## Updating

### Update System Packages

```bash
yay -Syu
```

### Update Oh-My-Zsh

```bash
omz update
```

### Update Neovim Plugins

```vim
:Lazy sync
```

### Pull Dotfiles Updates

```bash
cd ~/dotfiles
git pull
# Re-stow any updated packages (example for hypr)
stow -Rv -t "$HOME/.config/hypr" hypr
```

## Resources

- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Neovim Documentation](https://neovim.io/doc/)
- [Starship Configuration](https://starship.rs/config/)
- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html)
- [Arch Wiki](https://wiki.archlinux.org/)

## License

MIT License - Feel free to use and modify as you wish.

## Credits

- Color scheme: [Gruvbox](https://github.com/morhetz/gruvbox)
- Prompt: [Starship](https://starship.rs/)
- Window Manager: [Hyprland](https://hyprland.org/)
- Editor: [Neovim](https://neovim.io/)
