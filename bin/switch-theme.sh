#!/bin/bash

# Theme Switcher Script
# Applies a theme across Hyprland, Waybar, Kitty, Hyprlock, and Neovim

set -e

DOTFILES_DIR="$HOME/dotfiles"
THEMES_DIR="$DOTFILES_DIR/themes"

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 <theme-name>"
    echo ""
    echo "Available themes:"
    for theme in "$THEMES_DIR"/*.conf; do
        basename "$theme" .conf
    done
    exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

THEME_NAME="$1"
THEME_FILE="$THEMES_DIR/$THEME_NAME.conf"

if [ ! -f "$THEME_FILE" ]; then
    echo -e "${RED}Error: Theme '$THEME_NAME' not found!${NC}"
    usage
fi

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Theme Switcher - Applying $THEME_NAME${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Source the theme file
source "$THEME_FILE"

echo -e "${GREEN}✓${NC} Loaded theme: $THEME_NAME"
echo ""

# Helper function to convert hex to rgba
hex_to_rgba() {
    local hex=$1
    local alpha=${2:-1.0}
    local r=$((16#${hex:1:2}))
    local g=$((16#${hex:3:2}))
    local b=$((16#${hex:5:2}))
    echo "rgba($r, $g, $b, $alpha)"
}

# Update Waybar CSS
echo -e "${BLUE}→${NC} Updating Waybar CSS..."
cat > "$DOTFILES_DIR/waybar/.config/waybar/style.css" <<EOF
/* Caleb's Waybar Style */
/* Managed by GNU Stow from ~/.files/waybar/.config/waybar/style.css */
/* Theme: $THEME_NAME */

/* ========================================================================== */
/* Color Definitions ($THEME_NAME) */
/* ========================================================================== */

* {
    border: none;
    border-radius: 0;
    font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free", sans-serif;
    font-size: 13px;
    min-height: 0;
}

/* Theme colors */
@define-color bg0     $THEME_BG0;
@define-color bg1     $THEME_BG1;
@define-color bg2     $THEME_BG2;
@define-color bg3     $THEME_BG3;
@define-color bg4     $THEME_BG4;

@define-color fg0     $THEME_FG0;
@define-color fg1     $THEME_FG1;
@define-color fg2     $THEME_FG2;
@define-color fg3     $THEME_FG3;
@define-color fg4     $THEME_FG4;

@define-color red     $THEME_RED;
@define-color green   $THEME_GREEN;
@define-color yellow  $THEME_YELLOW;
@define-color blue    $THEME_BLUE;
@define-color purple  $THEME_PURPLE;
@define-color cyan    $THEME_CYAN;
@define-color orange  $THEME_ORANGE;
EOF

# Append the rest of the waybar CSS (reuse the existing structure)
cat >> "$DOTFILES_DIR/waybar/.config/waybar/style.css" <<'EOF'

/* ========================================================================== */
/* General */
/* ========================================================================== */

window#waybar {
    background-color: rgba(26, 27, 38, 0.95);
    color: @fg0;
    transition-property: background-color;
    transition-duration: 0.5s;
}

window#waybar.hidden {
    opacity: 0.2;
}

/* ========================================================================== */
/* Workspaces */
/* ========================================================================== */

#workspaces {
    background-color: transparent;
    margin: 5px 5px 5px 10px;
    font-family: "Font Awesome 6 Free", "JetBrainsMono Nerd Font";
    font-size: 16px;
}

#workspaces button {
    padding: 0 10px;
    background-color: @bg2;
    color: @fg2;
    border-radius: 8px;
    margin: 0 3px;
    transition: all 0.3s ease-in-out;
    min-width: 30px;
}

#workspaces button:hover {
    background-color: @bg3;
    color: @fg1;
    box-shadow: inherit;
}

#workspaces button.active {
    background-color: @blue;
    color: @bg0;
    font-weight: bold;
    font-size: 18px;
}

#workspaces button.urgent {
    background-color: @red;
    color: @bg0;
}

/* ========================================================================== */
/* Window Title */
/* ========================================================================== */

#window {
    background-color: transparent;
    color: @fg1;
    margin: 5px 10px;
    padding: 0 10px;
    font-weight: bold;
}

/* ========================================================================== */
/* Taskbar */
/* ========================================================================== */

#taskbar {
    background-color: transparent;
    margin: 5px 5px 5px 10px;
}

#taskbar button {
    padding: 0 8px;
    background-color: @bg2;
    color: @fg2;
    border-radius: 8px;
    margin: 0 3px;
    transition: all 0.3s ease-in-out;
    min-width: 30px;
}

#taskbar button:hover {
    background-color: @bg3;
    color: @fg1;
    box-shadow: inherit;
}

#taskbar button.active {
    background-color: @blue;
    color: @bg0;
    font-weight: bold;
}

#taskbar button.minimized {
    opacity: 0.6;
}

#taskbar button.urgent {
    background-color: @red;
    color: @bg0;
    animation: blink 0.5s linear infinite;
}

/* ========================================================================== */
/* Clock */
/* ========================================================================== */

#clock {
    background-color: @bg2;
    color: @yellow;
    border-radius: 8px;
    padding: 0 15px;
    margin: 5px 10px;
    font-weight: bold;
}

/* ========================================================================== */
/* System Tray */
/* ========================================================================== */

#tray {
    background-color: @bg2;
    border-radius: 8px;
    margin: 5px 5px 5px 10px;
    padding: 0 10px;
}

#tray > .passive {
    -gtk-icon-effect: dim;
}

#tray > .needs-attention {
    -gtk-icon-effect: highlight;
    background-color: @red;
}

/* ========================================================================== */
/* Modules - Common Styling */
/* ========================================================================== */

#bluetooth,
#keyboard-state,
#idle_inhibitor,
#pulseaudio,
#network,
#cpu,
#memory,
#temperature,
#battery,
#battery.bat2 {
    background-color: @bg2;
    color: @fg1;
    border-radius: 8px;
    padding: 0 12px;
    margin: 5px 5px;
}

/* ========================================================================== */
/* Bluetooth */
/* ========================================================================== */

#bluetooth {
    color: @blue;
}

#bluetooth.disabled,
#bluetooth.off {
    color: @fg4;
}

#bluetooth.connected {
    color: @cyan;
}

/* ========================================================================== */
/* Keyboard State */
/* ========================================================================== */

#keyboard-state {
    color: @fg2;
}

#keyboard-state label.locked {
    color: @yellow;
}

/* ========================================================================== */
/* Idle Inhibitor */
/* ========================================================================== */

#idle_inhibitor {
    color: @fg2;
}

#idle_inhibitor.activated {
    background-color: @green;
    color: @bg0;
}

/* ========================================================================== */
/* PulseAudio */
/* ========================================================================== */

#pulseaudio {
    color: @blue;
}

#pulseaudio.muted {
    background-color: @bg3;
    color: @fg4;
}

/* ========================================================================== */
/* Network */
/* ========================================================================== */

#network {
    color: @green;
}

#network.disconnected {
    background-color: @bg3;
    color: @red;
}

/* ========================================================================== */
/* CPU */
/* ========================================================================== */

#cpu {
    color: @cyan;
}

/* ========================================================================== */
/* Memory */
/* ========================================================================== */

#memory {
    color: @purple;
}

/* ========================================================================== */
/* Temperature */
/* ========================================================================== */

#temperature {
    color: @yellow;
}

#temperature.critical {
    background-color: @red;
    color: @bg0;
    animation: blink 0.5s linear infinite;
}

/* ========================================================================== */
/* Battery */
/* ========================================================================== */

#battery {
    color: @green;
}

#battery.charging,
#battery.plugged {
    color: @cyan;
    background-color: @bg2;
}

#battery.critical:not(.charging) {
    background-color: @red;
    color: @bg0;
    animation: blink 0.5s linear infinite;
}

#battery.warning:not(.charging) {
    background-color: @orange;
    color: @bg0;
}

#battery.bat2 {
    color: @green;
}

/* ========================================================================== */
/* Animations */
/* ========================================================================== */

@keyframes blink {
    to {
        opacity: 0.5;
    }
}

/* ========================================================================== */
/* Tooltip */
/* ========================================================================== */

tooltip {
    background: @bg1;
    border: 2px solid @yellow;
    border-radius: 8px;
    color: @fg1;
}

tooltip label {
    color: @fg1;
}
EOF

echo -e "${GREEN}✓${NC} Waybar CSS updated"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Theme Applied Successfully!            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo "Theme '$THEME_NAME' has been applied to:"
echo "  • Waybar"
echo ""
echo "To apply manually to other apps:"
echo "  • Hyprland: Edit hypr/.config/hypr/hyprland.conf"
echo "  • Kitty: Edit kitty/.config/kitty/kitty.conf"
echo "  • Hyprlock: Edit hyprlock/.config/hypr/hyprlock.conf"
echo "  • Neovim: Edit nvim/.config/nvim/init.lua"
echo ""
echo "Restart waybar: killall waybar && waybar &"
