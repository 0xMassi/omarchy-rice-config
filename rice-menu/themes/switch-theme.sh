#!/bin/bash
# Switch Theme - Standalone script with looping

THEME_DIR="$HOME/.config/omarchy/themes"

while true; do
    THEMES=$(ls -1 "$THEME_DIR")
    SELECTED=$(echo "$THEMES" | fuzzel --dmenu --prompt="Select Theme: ")

    if [ -z "$SELECTED" ]; then
        # User cancelled, go back to main menu
        exit 0
    fi

    ~/.config/rice-menu/themes/theme-actions.sh "$SELECTED" "true" "$0"

    # If we're here, theme-actions didn't exec back (user selected Back or Apply)
    # Loop will show theme selection again
done
