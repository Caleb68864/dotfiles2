#!/bin/bash
current=$(hyprctl getoption general:layout -j | grep -oP '(?<="str": ")[^"]+')

case $current in
    "dwindle")
        hyprctl keyword general:layout master
        ;;
    "master")
        hyprctl keyword general:layout scroller
        ;;
    "scroller")
        hyprctl keyword general:layout hy3
        ;;
    "hy3")
        hyprctl keyword general:layout dwindle
        ;;
    *)
        hyprctl keyword general:layout dwindle
        ;;
esac
