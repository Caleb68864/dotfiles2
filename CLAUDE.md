# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **dotfiles repository** for Arch Linux (EndeavourOS) managed with **GNU Stow**. It provides a complete desktop environment using Hyprland (Wayland compositor) with Waybar, along with development tools including Neovim, Zsh, Tmux, and support for Python and C# development.

**Key Architecture Pattern:** Each top-level directory is a GNU Stow "package" stowed directly to its specific target directory — **not** to `$HOME`. Config files sit directly in the package root with no hidden directory nesting. For example, `waybar/config.jsonc` stows to `~/.config/waybar/config.jsonc` because the stow target for `waybar` is `~/.config/waybar`.

**Git remote:** `git@github.com:Caleb68864/dotfiles2.git`

**Cross-platform workflow:** Dotfiles are edited on Windows (this machine) and deployed on Linux (EndeavourOS) via `git pull` + `stow`. The repo is cloned as `~/dotfiles` on Linux (not `~/dotfiles2`). Symlinks point to `../dotfiles/`.

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
| `atuin` | `~/.config/atuin` | config.toml |
| `themes` | `~/.config/themes` | tokyo-night.conf, gruvbox.conf |
| `fonts` | `~/.local/share/fonts` | JetBrainsMono Nerd Font *.ttf |
| `zsh` | `$HOME` | .zshrc, .zsh/, .config/starship.toml |
| `tmux` | `$HOME` | .tmux.conf |
| `git` | `$HOME` | .gitconfig |
| `scripts` | `$HOME` | setup-github-ssh.sh |
| `bin` | `$HOME` | get-fonts.sh, switch-theme.sh, deploy-all, undeploy |
| `pi` | `$HOME` | .pi/agent/settings.json, bin/pi-workspace, prompts/ |
| `basalt` | `~/.config/basalt` | config.toml (Obsidian vault TUI browser) |
| `aerc` | `~/.config/aerc` | aerc.conf, accounts.conf, binds.conf, scripts/ |
| `newsboat` | `~/.config/newsboat` | config (RSS reader with Tokyo Night theme) |

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
stow -Rv -t "$HOME/.config/yazi"     yazi
stow -Rv -t "$HOME/.config/atuin"   atuin
stow -Rv -t "$HOME/.config/themes"  themes
stow -Rv -t "$HOME"                 zsh tmux git pi

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
├── theme.conf         → ~/.config/hypr/theme.conf  (Hyprland color vars, sourced by hyprland.conf)
└── scripts/           → ~/.config/hypr/scripts/
    └── random-wallpaper.sh

waybar/
├── config.jsonc       → ~/.config/waybar/config.jsonc
├── style.css          → ~/.config/waybar/style.css
└── scripts/           → ~/.config/waybar/scripts/

nvim/
├── init.lua           → ~/.config/nvim/init.lua (bootstrap + requires)
└── lua/               → ~/.config/nvim/lua/ (config modules + plugin specs)
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
- `~/.config/atuin/config.toml` → `~/dotfiles/atuin/config.toml`
- `~/.config/themes/tokyo-night.conf` → `~/dotfiles/themes/tokyo-night.conf`
- `~/.config/hypr/theme.conf` → `~/dotfiles/hypr/theme.conf`

Always edit files in `~/dotfiles/` — never edit `~/.config/` directly (those are symlinks).

### Theme System

**Tokyo Night** is the primary color scheme. Colors are centralized where each tool allows it:

| File | Format | Used by |
|------|--------|---------|
| `themes/tokyo-night.conf` | Shell vars (`THEME_BLUE=#7aa2f7`) | `.zshrc` sources it for fzf colors |
| `hypr/theme.conf` | Hyprland vars (`$th_blue = rgba(...)`) | `hyprland.conf` sources it for borders/shadows |
| `waybar/style.css` | CSS `@define-color` | All waybar CSS styling |
| `yazi/theme.toml` | Hardcoded hex | Yazi colors (TOML has no variable support) |
| `waybar/config.jsonc` | Hardcoded hex | Calendar Pango markup (JSONC has no variable support) |

**To change a color:** edit `themes/tokyo-night.conf` (shell/fzf), `hypr/theme.conf` (Hyprland), and `waybar/style.css` (waybar) — then reload each tool.

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
- Workspace 5: (unassigned)
- Workspace 7: Steam
- Workspace 8: Games (heroic)

### Hyprland Keybinding Summary

| Key | Action |
|-----|--------|
| `SUPER+H/J/K/L` | Move focus (vim-style) |
| `SUPER+SHIFT+H/J/K/L` | Move window |
| `SUPER+R` then `H/J/K/L` | Resize mode (submap, Escape to exit) |
| `SUPER+F` | Toggle fullscreen |
| `SUPER+BackSpace` | Lock screen (hyprlock) |
| `SUPER+T` | Toggle split (dwindle) |
| `SUPER+A` | Toggle AI scratchpad workspace |
| `SUPER+SHIFT+P` | Pi workspace (tmux layout) |
| `SUPER+SHIFT+N` | Floating Pi in Obsidian vault |
| `SUPER+N` | Notification center |

### Tmux Window Layout

Windows use "smart" bindings — if closed, Alt+number recreates the app automatically via `bin/bin/tmux-smart-window`. Monocle windows (5, 7) stack multiple full-screen apps; cycle with `prefix+o`, zoom toggle with `prefix+z`.

| Key | Window | Apps |
|-----|--------|------|
| Alt+1-3 | working | tactical, agent, pi-workspace |
| Alt+4 | (open) | user-created |
| Alt+5 | comms | weechat + gomuks + scli (monocle) |
| Alt+6 | notes | basalt (Obsidian vault) |
| Alt+7 | info | aerc + khal + newsboat (monocle) |
| Alt+8 | music | ncmpcpp + cava (split) |
| Alt+0 | scratch | empty shell |

### Tmux Keybinding Summary

| Key | Action |
|-----|--------|
| `C-a, C-c` | Claude Code popup (persistent session) |
| `C-a, C-p` | Pi popup (persistent session) |
| `C-a, C-f` | Project sessionizer (fzf project picker) |
| `C-a, p` | Split pane + Pi (side by side) |
| `C-a, C` | Split pane + Claude Code (side by side) |
| `C-a, /` | Cheat sheet popup |
| `Alt+0-9` | Smart window access (auto-creates if missing) |
| `C-a, \|` | Split horizontal |
| `C-a, -` | Split vertical |
| `C-h/j/k/l` | Pane navigation (vim-tmux-navigator) |

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
  - `Alt+D` in Yazi → drag hovered/selected files with ripdrag
  - Launched with `kitty --class yazi -e yazi` (bypasses tmux auto-start)
  - Image preview via Kitty native protocol (auto-detected)
  - PDF preview via pdftoppm (poppler)

### Yazi Keymap (v26.x)

Critical syntax rules — old syntax is **silently ignored**:
- Section: `[[mgr.prepend_keymap]]` (NOT `[[manager.prepend_keymap]]`)
- Single key: `on = "<A-d>"` string (NOT an array `["<A-d>"]`)
- Multi-key sequence: `on = ["g", "d"]` array
- File variables: `%h` = hovered file, `%s` = selected files (NOT `$@`)
- Shell command: `run = "shell -- command %h"` (use `--` then `%h`/`%s`)

### ripdrag (Drag-and-Drop from Yazi)

- Window class: `it.catboy.ripdrag` (use this in Hyprland window rules)
- Must launch with `env GDK_SCALE=1` — global `GDK_SCALE=2` breaks GTK layout
- Use `-x` flag (`--and-exit`) so window closes after drop
- Full command in keymap: `shell -- env GDK_SCALE=1 ripdrag -x %s`
- Supplementary PUA-A icons (U+F0000+) may not render in GTK — use BMP PUA icons only

### Atuin (Shell History)

- Config: `atuin/config.toml` → `~/.config/atuin/config.toml`
- Already initialized in `.zshrc`: `eval "$(atuin init zsh)"`
- `Ctrl+R` opens Atuin fuzzy search; `Enter` runs, `Tab` edits, `Esc` cancels

### Neovim Configuration

Modular config split across `nvim/lua/`:
- `init.lua` — Bootstrap lazy.nvim, load config modules
- `lua/config/options.lua` — Editor settings
- `lua/config/keymaps.lua` — General keymaps (non-plugin)
- `lua/config/autocommands.lua` — Autocommands
- `lua/plugins/*.lua` — Plugin specs (auto-discovered by lazy.nvim):
  - `colorscheme.lua` — Tokyo Night
  - `treesitter.lua` — Syntax highlighting
  - `lsp.lua` — Mason + LSP servers + on-attach keymaps
  - `completion.lua` — nvim-cmp + LuaSnip
  - `dap.lua` — Debug adapters (Python, C#)
  - `ai.lua` — Pi (primary), claudecode.nvim, CodeCompanion (commented)
  - `editor.lua` — nvim-tree, telescope, harpoon, yazi, surround, ufo, vim-tmux-navigator
  - `git.lua` — gitsigns, diffview, lazygit
  - `ui.lua` — lualine, which-key, indent-blankline, colorizer
  - `tools.lua` — neotest, conform, trouble, aerial, refactoring, spectre, todo-comments

**AI assistant keymaps:** Pi uses `<leader>p` namespace (pp/ps/pf/pb). LSP code_action is `<leader>ca`. claudecode.nvim connects to Claude Code CLI via WebSocket MCP.

**Path yanking:** `<leader>yr` (relative), `<leader>yp` (absolute) — copies to system clipboard.

### aerc (Email Client)

Replaced neomutt. Config at `aerc/` stow package. Custom keybindings:
- `E` = export email to Obsidian vault as Markdown (scripts/mail-to-obsidian)
- `V` = open HTML in qutebrowser (scripts/open-mail-html)
- `W` = save raw .eml source (scripts/save-raw-email)
- O365 auth via oauth2ms, Gmail via GPG-encrypted app password
- accounts.conf has placeholder values (YOUR_*) that must be edited

### Obsidian Integration

Vault: `~/Documents/Notes/Logic` (configurable via `OBSIDIAN_VAULT` env var).
SlingMD (C# Outlook add-in) sets the frontmatter standard — terminal scripts must match:
`title`, `from` (wikilink), `to` (wikilink), `date`, `type`, `tags`

### Zsh Configuration

Features Oh-My-Zsh with plugins:
- zsh-autosuggestions, zsh-syntax-highlighting, fzf-tab
- Starship prompt
- Atuin for shell history (`Ctrl+R`)
- zoxide for smart directory jumping (`z`)
- fzf with Tokyo Night colors (sourced from `~/.config/themes/tokyo-night.conf`)
- Tmux auto-starts "command-center" session on terminal launch
- `chpwd()` hook auto-lists directory contents on any cd/z
- History config: 100k entries, shared across sessions
- Pi aliases: `pa`, `pac`, `par`, `paf`

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

## Gotchas

- **`bin/` package has double nesting:** `bin/bin/script` stows to `~/bin/script`. The outer `bin/` is the stow package name, inner `bin/` is the target directory. Don't flatten it.
- **tmux-resurrect saves at `~/.local/share/tmux/resurrect/`** — NOT `~/.tmux/resurrect/`. Clear these to force fresh session layout.
- **tmux `renumber-windows` is OFF** — TUI apps are pinned to fixed window numbers (4-9). Enabling renumber would collapse the gaps.
- **Never `pip install` on Arch** — use `yay -S python-packagename` or `pipx install packagename`.
- **Tokyo Night theme must be applied to every new tool** — check themes/, hypr/theme.conf, waybar/style.css, and per-tool color configs.
- **weechat:** Ruby plugin must be disabled (`plugin.autoload = "*,!ruby"`) or libruby error occurs.
- **git-delta** is configured as the git pager — `git diff` output looks different from raw diff.
