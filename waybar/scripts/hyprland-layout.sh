#!/bin/bash
LAYOUT=$(hyprctl getoption general:layout -j | grep -oP '(?<="str": ")[^"]+')
case $LAYOUT in
    "master")
        echo '{"text": " Master", "class": "master", "tooltip": "Master Layout"}'
        ;;
    "dwindle")
        echo '{"text": " Dwindle", "class": "dwindle", "tooltip": "Dwindle Layout"}'
        ;;
    "scroller")
        echo '{"text": "󰡎 Scroller", "class": "scroller", "tooltip": "Scroller Layout"}'
        ;;
    "hy3")
        echo '{"text": " hy3", "class": "hy3", "tooltip": "hy3 Layout"}'
        ;;
    *)
        echo '{"text": " Unknown", "class": "unknown", "tooltip": "Unknown Layout"}'
        ;;
esac
