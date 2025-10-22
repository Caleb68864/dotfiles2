#!/bin/bash
# Get current Hyprland layout

LAYOUT=$(hyprctl getoption general:layout -j | grep -oP '(?<="str": ")[^"]+')

if [ "$LAYOUT" = "master" ]; then
    echo '{"text": " Master", "class": "master", "tooltip": "Master Layout"}'
else
    echo '{"text": " Dwindle", "class": "dwindle", "tooltip": "Dwindle Layout"}'
fi
