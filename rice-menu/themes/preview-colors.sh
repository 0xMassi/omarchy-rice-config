#!/bin/bash
# Color Palette Viewer - Preview theme in a live terminal

THEME_DIR="$HOME/.config/omarchy/themes"
SCHEME_DIR="$HOME/.config/rice-menu/color-schemes/alacritty"

# Get theme name
THEME_NAME="$1"

if [ -z "$THEME_NAME" ]; then
    notify-send "Error" "No theme specified"
    exit 1
fi

# Check if theme exists and get the theme file
if [ -d "$THEME_DIR/$THEME_NAME" ]; then
    THEME_FILE="$THEME_DIR/$THEME_NAME/alacritty.toml"
elif [ -f "$SCHEME_DIR/$THEME_NAME.toml" ]; then
    THEME_FILE="$SCHEME_DIR/$THEME_NAME.toml"
else
    notify-send "Error" "Theme not found: $THEME_NAME"
    exit 1
fi

# Create temporary Alacritty config with the preview theme
TEMP_CONFIG="/tmp/alacritty-preview-$$.toml"
cat > "$TEMP_CONFIG" << 'ALACRITTY_END'
[window]
padding = { x = 10, y = 10 }
decorations = "full"
opacity = 1.0

[font]
size = 11
ALACRITTY_END

# Append the theme colors
cat "$THEME_FILE" >> "$TEMP_CONFIG"

# Create a preview script that shows example content
PREVIEW_SCRIPT="/tmp/theme-preview-content-$$.sh"
cat > "$PREVIEW_SCRIPT" << 'PREVIEW_END'
#!/bin/bash

clear
echo "╔════════════════════════════════════════════════════════════╗"
echo "║          THEME PREVIEW: THEME_NAME_REPLACE                 ║"
echo "║  This terminal shows how the theme looks in real use       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Regular text looks like this"
echo -e "\033[1mBold text\033[0m and \033[3mitalic text\033[0m"
echo ""
echo "Colors:"
echo -e "\033[30m■ Black text\033[0m"
echo -e "\033[31m■ Red text\033[0m"
echo -e "\033[32m■ Green text\033[0m"
echo -e "\033[33m■ Yellow text\033[0m"
echo -e "\033[34m■ Blue text\033[0m"
echo -e "\033[35m■ Magenta text\033[0m"
echo -e "\033[36m■ Cyan text\033[0m"
echo -e "\033[37m■ White text\033[0m"
echo ""
echo "Bright colors:"
echo -e "\033[90m■ Bright Black\033[0m"
echo -e "\033[91m■ Bright Red\033[0m"
echo -e "\033[92m■ Bright Green\033[0m"
echo -e "\033[93m■ Bright Yellow\033[0m"
echo -e "\033[94m■ Bright Blue\033[0m"
echo -e "\033[95m■ Bright Magenta\033[0m"
echo -e "\033[96m■ Bright Cyan\033[0m"
echo -e "\033[97m■ Bright White\033[0m"
echo ""
echo "Example code:"
echo -e "\033[34mfunction\033[0m \033[33mgreet\033[0m() {"
echo -e "  \033[32mecho\033[0m \033[36m\"Hello, World!\"\033[0m"
echo "}"
echo ""
echo -e "\033[90m# Press Enter to close this preview and return to menu\033[0m"
read
PREVIEW_END

# Replace theme name
sed -i "s/THEME_NAME_REPLACE/$THEME_NAME/g" "$PREVIEW_SCRIPT"
chmod +x "$PREVIEW_SCRIPT"

# Launch Alacritty with the preview theme (blocking - wait for it to close)
alacritty --config-file "$TEMP_CONFIG" -e "$PREVIEW_SCRIPT"

# Cleanup after terminal closes
rm -f "$TEMP_CONFIG" "$PREVIEW_SCRIPT"
