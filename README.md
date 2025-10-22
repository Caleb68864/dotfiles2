# Caleb's Dotfiles

A comprehensive dotfiles configuration for **EndeavourOS/Arch Linux** featuring **Hyprland**, **Neovim**, **Zsh** with **Starship** prompt, and a complete development environment for **Python** and **C#**.

## Features

### Desktop Environment
- **Hyprland** - Modern Wayland compositor with beautiful animations
- **Waybar** - Highly customizable status bar with system metrics
- **Wofi** - Fast and customizable application launcher
- **Hyprpaper** - Wallpaper manager for Hyprland
- **Hyprlock** - Screen locker for Hyprland
- **Hypridle** - Idle management daemon (dims at 5min, locks at 10min)
- **SwayNC** - Notification daemon with notification center

### Development
- **Neovim** - Full IDE setup with LSP, DAP, and AI assistants
  - LSP servers: Pyright (Python), OmniSharp (C#), Lua, TypeScript
  - Debuggers: debugpy (Python), netcoredbg (C#)
  - AI: CodeCompanion (primary), Claude Code & Avante (optional)
  - Treesitter, Completion, File explorer, Fuzzy finder
- **Python** - Full development stack
- **C# / .NET** - Complete toolchain with debugging support

### Shell & Terminal
- **Zsh** - Powerful shell with Oh-My-Zsh
- **Tmux** - Terminal multiplexer with auto-attach to "battlestation" session
- **Starship** - Fast, minimal prompt (default)
- **Kitty** - GPU-accelerated terminal emulator
- **fzf** - Fuzzy finder with custom keybindings
- **bat** - Cat clone with syntax highlighting
- **eza** - Modern ls replacement

### Tools & Utilities
- **Git** - Version control with custom configuration
- **ripgrep** - Fast search tool
- **htop** - System monitor
- **hyprshot** - Screenshot utility for Hyprland
- **Gruvbox** - Color scheme throughout

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles.git ~/.files

# Navigate to the directory
cd ~/.files

# Run the installation script
bash install.sh
```

The installation script will:
1. Install `yay` AUR helper (if not present)
2. Install all packages from `packages.txt`
3. Install Oh-My-Zsh and plugins (zsh-autosuggestions, zsh-syntax-highlighting, fzf-tab)
4. **Backup existing configurations** to `~/dotfiles-backup-[timestamp]/`
   - All existing dotfiles and config directories
   - Preserves directory structure for easy restoration
   - Only backs up non-symlink files (skips if already stowed)
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

4. **Set your wallpaper**:
   - Place your wallpaper at `~/Pictures/wallpaper.jpg`
   - Or edit `~/.config/hypr/hyprpaper.conf` to point to your image

5. **Configure monitors** (if needed):
   - Edit `~/.config/hypr/hyprland.conf`
   - Update the monitor configuration section

## GNU Stow Usage

This repository uses **GNU Stow** for managing symlinks. Each subdirectory is a "package" that can be independently linked or unlinked.

### Deploy All Packages

```bash
cd ~/.files
stow -vRt "$HOME" zsh tmux nvim hypr waybar wofi hyprpaper hyprlock hypridle swaync git fonts
```

### Deploy a Single Package

```bash
stow -vRt "$HOME" nvim
```

### Remove a Package

```bash
stow -DvRt "$HOME" nvim
```

### Dry Run (Preview Changes)

```bash
stow -nvt "$HOME" nvim
```

### Available Packages

- `zsh` - Zsh configuration and Starship config
- `tmux` - Tmux terminal multiplexer configuration
- `nvim` - Neovim configuration
- `hypr` - Hyprland window manager config
- `waybar` - Status bar configuration
- `wofi` - Application launcher configuration
- `hyprpaper` - Wallpaper manager configuration
- `hyprlock` - Screen locker configuration
- `hypridle` - Idle management daemon configuration
- `swaync` - Notification daemon with control center
- `git` - Git configuration
- `fonts` - Custom fonts

## Key Bindings

### Hyprland

| Key Combo | Action |
|-----------|--------|
| `Super + Return` | Open terminal (Kitty) |
| `Super + Space` | Open application launcher (Wofi) |
| `Super + W` | Open web browser (Vivaldi) |
| `Super + E` | Open file manager (Dolphin) |
| `Super + N` | Toggle notification center (SwayNC) |
| `Super + Shift + Q` | Close active window |
| `Super + M` | Exit Hyprland |
| `Super + F` | Toggle fullscreen |
| `Super + V` | Toggle floating |
| `Super + L` | Lock screen (Hyprlock) |
| `Super + 1-0` | Switch to workspace 1-10 |
| `Super + Shift + 1-0` | Move window to workspace 1-10 |
| `Super + Arrow Keys` | Move focus |
| `Super + Shift + Arrows` | Move window |
| `Super + Ctrl + Arrows` | Resize window |
| `Super + S` | Toggle scratchpad |
| `Print` | Screenshot region to clipboard |
| `Shift + Print` | Screenshot window to clipboard |
| `Super + Print` | Screenshot region to file |
| `Super + Shift + Print` | Screenshot window to file |
| `Ctrl + Print` | Screenshot monitor to clipboard |

### Workspaces

Workspaces are organized by purpose with FontAwesome icons in Waybar:

| Workspace | Icon | Purpose | Applications |
|-----------|------|---------|--------------|
| 1 |  | Web Browsers | Firefox, Vivaldi, Chromium |
| 2 |  | Terminals | Kitty, Alacritty |
| 3 |  | File Managers | Dolphin, Thunar |
| 4 |  | Communication | Discord, Vesktop |
| 5 |  | Entertainment | Spotify, Steam |
| 6 |  | Development | VS Code |

**Features:**
- Only shows workspaces with open windows
- Active workspace has a **●** dot indicator
- Click workspace icon in Waybar to switch
- Applications auto-assign to their designated workspace

**To always show certain workspaces** (even when empty), edit `~/.config/waybar/config.jsonc` and uncomment:
```jsonc
"persistent-workspaces": { "*": [1, 2, 3, 4, 5, 6] },
```

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

**Disable Auto-Start:** To disable automatic tmux start, comment out the "Tmux Auto-Start" section in `~/.zshrc`

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

#### Debuggers

- **Python**: debugpy (auto-configured via nvim-dap-python)
- **C#**: netcoredbg (configured for .NET debugging)

#### AI Assistants

**Primary: CodeCompanion**
- Set your API key:
  ```bash
  export ANTHROPIC_API_KEY="your-key-here"
  ```

**Optional: Claude Code & Avante**
- Disabled by default in the config
- Uncomment their plugin blocks in `nvim/.config/nvim/init.lua` to enable

### Zsh & Starship

#### Switching to Powerlevel10k

If you prefer Powerlevel10k over Starship:

1. Edit `~/.zshrc`:
   ```bash
   # Comment out Starship
   # eval "$(starship init zsh)"

   # Uncomment Powerlevel10k
   ZSH_THEME="powerlevel10k/powerlevel10k"
   [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
   ```

2. Install Powerlevel10k (uncomment in `install.sh` and re-run)

#### Customizing Starship

Edit `~/.config/starship.toml` to customize your prompt. See [Starship documentation](https://starship.rs/config/) for all options.

### Hyprland

#### Animations

The configuration includes smooth animations based on custom bezier curves:
- `easeOutQuint` - Smooth ease-out
- `easeInOutCubic` - Balanced ease in/out
- `almostLinear` - Nearly linear for workspaces
- `quick` - Fast animations for fades

Edit these in `~/.config/hypr/hyprland.conf` under the `animations` section.

#### Blur & Transparency

- Blur is enabled with `ignore_opacity = true` for better performance
- Opacity set to 1.0 for focused/unfocused windows
- Waybar has blur via layer rules

### Fonts

#### Installing Fonts

Fonts are managed via the `fonts` Stow package.

**Option 1: Use the helper script**
```bash
bash ~/dotfiles/bin/get-fonts.sh
```

**Option 2: Manual installation**
1. Download Nerd Fonts from [nerdfonts.com](https://www.nerdfonts.com/)
2. Extract to `~/.files/fonts/.local/share/fonts/`
3. Deploy:
   ```bash
   stow -vRt "$HOME" fonts
   fc-cache -rv
   ```

**Recommended fonts:**
- JetBrainsMono Nerd Font (default for terminal/editor)
- FiraCode Nerd Font
- Hack Nerd Font

## Troubleshooting

### Stow Conflicts

The install script automatically backs up conflicting files to `~/dotfiles-backup-[timestamp]/`.

**Manual backup (if needed):**
```bash
# Backup a specific config
mkdir ~/manual-backup
mv ~/.config/hypr ~/manual-backup/

# Then stow
stow -vRt "$HOME" hypr
```

**Restore from backup:**
```bash
# Find your backup
ls ~/dotfiles-backup-*

# Restore specific files
cp -r ~/dotfiles-backup-20251021_210530/.config/hypr ~/.config/

# Or unstow and restore everything
stow -Dt "$HOME" hypr
mv ~/dotfiles-backup-20251021_210530/.config/hypr ~/.config/
```

**Dry-run (preview changes):**
```bash
stow -nvt "$HOME" zsh
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

**Python/C# LSP issues:**
```bash
# Verify installations
which pyright
which omnisharp
which netcoredbg
```

### Hyprland

**Blur performance issues:**
- Edit `~/.config/hypr/hyprland.conf`
- Reduce `blur.passes` from 1 to 0 or disable blur entirely

**Waybar not showing:**
```bash
killall waybar
waybar &
```

**Check Hyprland logs:**
```bash
cat /tmp/hypr/$(ls -t /tmp/hypr | head -n 1)/hyprland.log
```

### WSL-Specific

The `.zshrc` includes WSL detection and clipboard integration:

- Uses `clip.exe` for clipboard if available
- Sets DISPLAY variable
- Provides `explorer.exe` and `code.exe` aliases

**Hyprland won't work on WSL** - This setup is designed for native Linux with Wayland support.

## Updating

### Update Packages

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
cd ~/.files
git pull
# Re-stow updated packages
stow -Rv -t "$HOME" <package>
```

## Maintenance

### Plugin Maintenance

**Oh-My-Zsh plugins** are located in:
- `~/.oh-my-zsh/custom/plugins/`

**Neovim plugins** are managed by lazy.nvim:
- Check status: `:Lazy`
- Update all: `:Lazy sync`
- Clean unused: `:Lazy clean`

### Backup

To backup your current configuration:

```bash
cd ~/.files
git add .
git commit -m "Update configurations"
git push
```

## Directory Structure

```
~/.files/
├── packages.txt              # List of packages to install
├── install.sh                # Bootstrap installation script
├── README.md                 # This file
├── bin/                      # Helper scripts
│   └── get-fonts.sh          # Font installer
├── zsh/                      # Zsh package
│   ├── .zshrc
│   └── .config/
│       └── starship.toml
├── nvim/                     # Neovim package
│   └── .config/
│       └── nvim/
│           └── init.lua
├── hypr/                     # Hyprland package
│   └── .config/
│       └── hypr/
│           └── hyprland.conf
├── waybar/                   # Waybar package
│   └── .config/
│       └── waybar/
│           ├── config.jsonc
│           └── style.css
├── wofi/                     # Wofi package
│   └── .config/
│       └── wofi/
│           ├── config
│           └── style.css
├── hyprpaper/                # Hyprpaper package
│   └── .config/
│       └── hypr/
│           └── hyprpaper.conf
├── hyprlock/                 # Hyprlock package
│   └── .config/
│       └── hypr/
│           └── hyprlock.conf
├── dunst/                    # Dunst package
│   └── .config/
│       └── dunst/
│           └── dunstrc
├── git/                      # Git package
│   └── .gitconfig
└── fonts/                    # Fonts package
    └── .local/
        └── share/
            └── fonts/
                └── README.md
```

## Customization

Feel free to customize any configuration:

1. **Colors**: Most configs use Gruvbox colors - search for color definitions
2. **Keybindings**: Edit the respective config files
3. **Applications**: Update the `$terminal`, `$fileManager`, `$webbrowser` variables
4. **Plugins**: Add/remove plugins in Neovim's `init.lua` or Zsh's `.zshrc`

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
