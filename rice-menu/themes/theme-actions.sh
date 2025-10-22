#!/bin/bash
# Theme Actions Helper - Reusable action menu for themes

THEME_NAME="$1"
IS_INSTALLED="$2"
RETURN_SCRIPT="$3"  # Script to return to after preview

if [ -z "$THEME_NAME" ]; then
    exit 1
fi

# Show action menu
ACTION_OPTIONS="Apply Theme
Preview Colors
Back"

action=$(echo "$ACTION_OPTIONS" | fuzzel --dmenu --prompt="$THEME_NAME: " --lines=3)

case "$action" in
    *"Apply"*)
        if [ "$IS_INSTALLED" = "true" ] || [ -d "$HOME/.config/omarchy/themes/$THEME_NAME" ]; then
            notify-send "Switching Theme" "Changing to $THEME_NAME..."
            omarchy-theme-set "$THEME_NAME"
            notify-send "Theme Changed" "✓ Switched to $THEME_NAME"
        else
            notify-send "Converting Theme" "Converting $THEME_NAME from color scheme..."
            ~/.config/rice-menu/themes/generate-from-scheme.sh "$THEME_NAME"
            sleep 1
            omarchy-theme-set "$THEME_NAME"
            notify-send "Theme Applied" "✓ $THEME_NAME installed and applied"
        fi
        ;;
    *"Preview"*)
        ~/.config/rice-menu/themes/preview-colors.sh "$THEME_NAME"
        # After preview closes, return to the calling menu
        if [ -n "$RETURN_SCRIPT" ] && [ -f "$RETURN_SCRIPT" ]; then
            exec "$RETURN_SCRIPT"
        fi
        ;;
esac
