#!/bin/bash
# Export Theme - Package theme for sharing

THEME_DIR="$1"

if [ -z "$THEME_DIR" ] || [ ! -d "$THEME_DIR" ]; then
    notify-send "Error" "Invalid theme directory"
    exit 1
fi

THEME_NAME=$(basename "$THEME_DIR")
EXPORT_DIR="$HOME/.local/share/omarchy/theme-exports"
mkdir -p "$EXPORT_DIR"

# Ensure all configs are generated
if [ -f "$THEME_DIR/colors.conf" ]; then
    ~/.config/rice-menu/themes/editor/generate-configs.sh "$THEME_DIR"
fi

# Ask if user wants to include wallpaper
INCLUDE_WALLPAPER="no"
if [ -d "$THEME_DIR/backgrounds" ] && [ "$(ls -A "$THEME_DIR/backgrounds" 2>/dev/null)" ]; then
    WALLPAPER_OPTIONS="Yes, include wallpaper
No, theme only"

    wallpaper_choice=$(echo "$WALLPAPER_OPTIONS" | fuzzel --dmenu --prompt="Include wallpaper in export? " --lines=2)

    if [[ "$wallpaper_choice" =~ "Yes" ]]; then
        INCLUDE_WALLPAPER="yes"
    fi
fi

# Create export package
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
EXPORT_FILE="$EXPORT_DIR/${THEME_NAME}_${TIMESTAMP}.omarchy-theme"

notify-send "Exporting Theme" "Packaging $THEME_NAME..."

# Create tar.gz archive with all theme files
cd "$(dirname "$THEME_DIR")"

if [ "$INCLUDE_WALLPAPER" = "yes" ]; then
    # Include everything including backgrounds
    tar -czf "$EXPORT_FILE" \
        --exclude='*.log' \
        --exclude='.git' \
        "$(basename "$THEME_DIR")"
else
    # Exclude backgrounds folder
    tar -czf "$EXPORT_FILE" \
        --exclude='*.log' \
        --exclude='.git' \
        --exclude='backgrounds' \
        "$(basename "$THEME_DIR")"
fi

if [ $? -eq 0 ]; then
    FILE_SIZE=$(du -h "$EXPORT_FILE" | cut -f1)

    OPTIONS="Copy Path to Clipboard
Open Export Folder
Upload to transfer.sh
Share via URL
Done"

    selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt="Theme Exported ($FILE_SIZE): " --lines=5)

    case "$selected" in
        *"Copy Path"*)
            echo -n "$EXPORT_FILE" | wl-copy
            notify-send "✓ Copied" "Path copied to clipboard"
            ;;
        *"Open Export"*)
            xdg-open "$EXPORT_DIR"
            ;;
        *"Upload"*)
            ~/.config/rice-menu/themes/sharing/upload.sh "$EXPORT_FILE"
            ;;
        *"Share via URL"*)
            ~/.config/rice-menu/themes/sharing/upload.sh "$EXPORT_FILE"
            ;;
    esac

    echo "$EXPORT_FILE"
else
    notify-send "Export Failed" "Could not create theme package"
    exit 1
fi
