#!/bin/bash
# random-wallpaper.sh - Set a random wallpaper from ~/Pictures/Wallpapers/
# Called by Hyprland on startup via exec-once after hyprpaper starts.
# If ~/Pictures/Wallpapers/ is empty, the fallback in hyprpaper.conf is used.

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Find all image files in the wallpaper directory
mapfile -t wallpapers < <(find "$WALLPAPER_DIR" -type f \( \
    -iname "*.jpg" -o -iname "*.jpeg" -o \
    -iname "*.png" -o -iname "*.webp" \
\) 2>/dev/null)

# Nothing to do if the directory is empty
if [ "${#wallpapers[@]}" -eq 0 ]; then
    exit 0
fi

# Pick a random wallpaper
chosen="${wallpapers[RANDOM % ${#wallpapers[@]}]}"

# Wait for hyprpaper IPC to become available (up to 10 seconds)
for i in $(seq 1 10); do
    if hyprctl hyprpaper listloaded >/dev/null 2>&1; then
        break
    fi
    sleep 1
done

# Preload then apply the chosen wallpaper
hyprctl hyprpaper preload "$chosen"
hyprctl hyprpaper wallpaper ",$chosen"
