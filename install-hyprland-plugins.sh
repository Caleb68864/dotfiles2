#!/bin/bash
# Installation script for Hyprland plugins
# Run this when logged into Hyprland

set -e

echo "Installing Hyprland Plugins..."
echo "==============================="

# Check if Hyprland is running
if ! pgrep -x "Hyprland" > /dev/null; then
    echo "ERROR: Hyprland is not running. Please run this script from within Hyprland."
    exit 1
fi

# Install hy3 (i3-style tiling)
echo ""
echo "Installing hy3 plugin..."
hyprpm add https://github.com/outfoxxed/hy3
hyprpm enable hy3

# Install hyprtags (DWM-style tag system)
echo ""
echo "Installing hyprtags plugin..."
hyprpm add https://github.com/JoaoCostaIFG/hyprtags
hyprpm enable hyprtags

echo ""
echo "==============================="
echo "Plugins installed successfully!"
echo ""
echo "IMPORTANT: To activate hyprtags, you need to uncomment the bindings:"
echo ""
echo "Edit ~/.config/hypr/hyprland.conf and:"
echo "  1. Uncomment: source = /tmp/hyprtags.conf (line ~8)"
echo "  2. Comment out standard workspace bindings (Super + [1-9])"
echo "  3. Uncomment hyprtags bindings:"
echo "     - tags-workspace (Super + [1-9])"
echo "     - tags-movetoworkspacesilent (Super + Shift + [1-9])"
echo "     - tags-toggleworkspace (Super + Ctrl + [1-9])"
echo ""
echo "Next steps:"
echo "  1. Edit hyprland.conf to uncomment hyprtags bindings"
echo "  2. Reload Hyprland: hyprctl reload"
echo "  3. Verify plugins loaded: hyprpm list"
echo ""
echo "Plugin descriptions:"
echo "  - hy3: i3-style manual tiling layout"
echo "  - hyprtags: DWM-style tag system"
echo "    * Windows belong to ONE tag at a time"
echo "    * Can VIEW multiple tags simultaneously"
echo ""
