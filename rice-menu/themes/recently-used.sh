#!/bin/bash
# Recently Used Themes

RECENT_FILE="$HOME/.config/omarchy/recent-themes.log"
THEME_DIR="$HOME/.config/omarchy/themes"

while true; do
    # Ensure recent file exists
    touch "$RECENT_FILE"

    # Get recent themes (last 15, excluding duplicates)
    recent_themes=$(tac "$RECENT_FILE" | awk '!seen[$0]++' | head -15)

    if [ -z "$recent_themes" ]; then
        notify-send "No Recent Themes" "No recently used themes found"
        exit 0
    fi

    # Show recent themes with most recent first
    SELECTED=$(echo "$recent_themes" | fuzzel --dmenu --prompt="Recently Used Themes: " --lines=15)

    if [ -z "$SELECTED" ]; then
        # User cancelled, exit
        exit 0
    fi

    # Check if theme still exists
    if [ ! -d "$THEME_DIR/$SELECTED" ]; then
        notify-send "Theme Not Found" "$SELECTED is no longer installed"
        continue  # Show menu again
    fi

    ~/.config/rice-menu/themes/theme-actions.sh "$SELECTED" "true"

    # Loop back to show recently used again
done
