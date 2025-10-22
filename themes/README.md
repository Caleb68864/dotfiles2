# Theme Management System

This directory contains centralized theme definitions for your dotfiles. All color schemes are defined here and can be applied across Hyprland, Waybar, Kitty, Hyprlock, and Neovim.

## Available Themes

- **tokyo-night** - Cool blues and purples inspired by Tokyo at night (current)
- **gruvbox** - Warm retro color scheme

## Quick Start

Switch themes using the theme switcher script:

```bash
# Switch to Tokyo Night
~/dotfiles/bin/switch-theme.sh tokyo-night

# Switch to Gruvbox
~/dotfiles/bin/switch-theme.sh gruvbox
```

After switching, restart waybar to see changes:
```bash
killall waybar && waybar &
```

## Creating a New Theme

1. Create a new theme file in this directory (e.g., `nord.conf`)
2. Define all required color variables (see tokyo-night.conf for template)
3. Run the theme switcher to apply it

## Theme File Format

Each theme file must define these variables:

```bash
# Background shades (darkest to lightest)
THEME_BG0="#hex"
THEME_BG1="#hex"
THEME_BG2="#hex"
THEME_BG3="#hex"
THEME_BG4="#hex"

# Foreground shades (darkest to lightest)
THEME_FG0="#hex"
THEME_FG1="#hex"
THEME_FG2="#hex"
THEME_FG3="#hex"
THEME_FG4="#hex"

# Accent colors
THEME_RED="#hex"
THEME_GREEN="#hex"
THEME_YELLOW="#hex"
THEME_BLUE="#hex"
THEME_PURPLE="#hex"
THEME_CYAN="#hex"
THEME_ORANGE="#hex"

# Terminal ANSI colors
THEME_BLACK="#hex"
THEME_WHITE="#hex"
THEME_BRIGHT_BLACK="#hex"
THEME_BRIGHT_WHITE="#hex"

# Special
THEME_SELECTION="#hex"

# Theme metadata
THEME_NAME="Display Name"
THEME_NVIM_PLUGIN="plugin/path"
THEME_NVIM_COLORSCHEME="colorscheme-name"
```

## What Gets Updated

Currently, the theme switcher automatically updates:
- ✅ Waybar CSS colors

Manual updates needed for:
- ⚠️ Hyprland borders (edit hypr/.config/hypr/hyprland.conf)
- ⚠️ Kitty terminal colors (edit kitty/.config/kitty/kitty.conf)
- ⚠️ Hyprlock colors (edit hyprlock/.config/hypr/hyprlock.conf)
- ⚠️ Neovim colorscheme (edit nvim/.config/nvim/init.lua)

These will be automated in future updates!

## Popular Theme Ideas

Want to add more themes? Here are some popular options:

- **Nord** - Arctic-inspired, minimal
- **Catppuccin** - Pastel colors, cozy
- **Dracula** - Purple/pink, bold
- **One Dark** - Atom's default dark theme
- **Solarized Dark** - Classic, well-balanced
- **Kanagawa** - Inspired by "The Great Wave"
