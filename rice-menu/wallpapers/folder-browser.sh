#!/bin/bash
# Folder Browser for Wallpapers

CURRENT_DIR="${1:-$HOME}"

while true; do
    # List directories first, then image files
    DIRS=$(find "$CURRENT_DIR" -maxdepth 1 -type d -not -path "$CURRENT_DIR" 2>/dev/null | sort | sed 's|.*/|📁 |')
    IMAGES=$(find "$CURRENT_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null | sort | sed 's|.*/|🖼️ |')

    # Add parent directory option
    if [ "$CURRENT_DIR" != "/" ]; then
        PARENT="⬆️ .. (Parent Directory)"
    else
        PARENT=""
    fi

    # Combine all options
    OPTIONS="$PARENT
$DIRS
$IMAGES"

    SELECTED=$(echo "$OPTIONS" | grep -v '^$' | fuzzel --dmenu --prompt=" 📂 $CURRENT_DIR: " --lines=15)

    if [ -z "$SELECTED" ]; then
        # User cancelled
        exit 0
    elif [[ "$SELECTED" == "⬆️"* ]]; then
        # Go to parent directory
        CURRENT_DIR=$(dirname "$CURRENT_DIR")
    elif [[ "$SELECTED" == "📁"* ]]; then
        # Enter directory
        DIR_NAME=$(echo "$SELECTED" | sed 's/📁 //')
        CURRENT_DIR="$CURRENT_DIR/$DIR_NAME"
    elif [[ "$SELECTED" == "🖼️"* ]]; then
        # Image selected
        IMG_NAME=$(echo "$SELECTED" | sed 's/🖼️ //')
        echo "$CURRENT_DIR/$IMG_NAME"
        exit 0
    fi
done
