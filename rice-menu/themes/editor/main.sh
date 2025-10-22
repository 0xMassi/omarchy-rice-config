#!/bin/bash
# Theme Editor - Main interface for creating and editing themes

EDITOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="$1"

# If no theme provided, ask to create new or edit existing
if [ -z "$THEME_DIR" ]; then
    OPTIONS="Create New Theme
Edit Existing Theme
Clone Existing Theme
Back"

    selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt=" Theme Editor: " --lines=4)

    case "$selected" in
        *"Create New"*)
            THEME_NAME=$(echo "" | fuzzel --dmenu --prompt="Enter new theme name: ")
            if [ -z "$THEME_NAME" ]; then
                exit 0
            fi

            THEME_SLUG=$(echo "$THEME_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
            THEME_DIR="$HOME/.local/share/omarchy/themes/$THEME_SLUG"

            if [ -d "$THEME_DIR" ]; then
                notify-send "Error" "Theme already exists: $THEME_SLUG"
                exit 1
            fi

            mkdir -p "$THEME_DIR/backgrounds"

            # Initialize with default colors (dark theme)
            cat > "$THEME_DIR/colors.conf" << 'EOF'
# Theme Colors
background="#1a1b26"
foreground="#c0caf5"
color0="#15161e"
color1="#f7768e"
color2="#9ece6a"
color3="#e0af68"
color4="#7aa2f7"
color5="#bb9af7"
color6="#7dcfff"
color7="#a9b1d6"
color8="#414868"
color9="#f7768e"
color10="#9ece6a"
color11="#e0af68"
color12="#7aa2f7"
color13="#bb9af7"
color14="#7dcfff"
color15="#c0caf5"
EOF

            notify-send "Theme Created" "New theme: $THEME_NAME"
            ;;

        *"Edit Existing"*)
            THEMES=$(ls -1 "$HOME/.local/share/omarchy/themes" 2>/dev/null)
            if [ -z "$THEMES" ]; then
                notify-send "No Themes" "No themes found to edit"
                exit 0
            fi

            THEME=$(echo "$THEMES" | fuzzel --dmenu --prompt="Select theme to edit: " --lines=15)
            if [ -z "$THEME" ]; then
                exit 0
            fi

            THEME_DIR="$HOME/.local/share/omarchy/themes/$THEME"
            ;;

        *"Clone"*)
            THEMES=$(ls -1 "$HOME/.config/omarchy/themes" 2>/dev/null)
            if [ -z "$THEMES" ]; then
                notify-send "No Themes" "No themes found to clone"
                exit 0
            fi

            SOURCE_THEME=$(echo "$THEMES" | fuzzel --dmenu --prompt="Select theme to clone: " --lines=15)
            if [ -z "$SOURCE_THEME" ]; then
                exit 0
            fi

            NEW_NAME=$(echo "$SOURCE_THEME-copy" | fuzzel --dmenu --prompt="Enter new theme name: ")
            if [ -z "$NEW_NAME" ]; then
                exit 0
            fi

            NEW_SLUG=$(echo "$NEW_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
            THEME_DIR="$HOME/.local/share/omarchy/themes/$NEW_SLUG"

            # Copy theme
            cp -r "$HOME/.config/omarchy/themes/$SOURCE_THEME" "$THEME_DIR"

            # Update metadata
            if [ -f "$THEME_DIR/theme.json" ]; then
                jq --arg name "$NEW_NAME" --arg slug "$NEW_SLUG" \
                   '.name = $name | .slug = $slug | .created = now | .version = "1.0.0"' \
                   "$THEME_DIR/theme.json" > "$THEME_DIR/theme.json.tmp" && \
                   mv "$THEME_DIR/theme.json.tmp" "$THEME_DIR/theme.json"
            fi

            notify-send "Theme Cloned" "$SOURCE_THEME → $NEW_NAME"
            ;;

        *)
            exit 0
            ;;
    esac
fi

# Ensure theme directory exists
if [ ! -d "$THEME_DIR" ]; then
    notify-send "Error" "Theme directory not found: $THEME_DIR"
    exit 1
fi

# Ensure colors.conf exists
if [ ! -f "$THEME_DIR/colors.conf" ]; then
    cat > "$THEME_DIR/colors.conf" << 'EOF'
background="#1a1b26"
foreground="#c0caf5"
color0="#15161e"
color1="#f7768e"
color2="#9ece6a"
color3="#e0af68"
color4="#7aa2f7"
color5="#bb9af7"
color6="#7dcfff"
color7="#a9b1d6"
color8="#414868"
color9="#f7768e"
color10="#9ece6a"
color11="#e0af68"
color12="#7aa2f7"
color13="#bb9af7"
color14="#7dcfff"
color15="#c0caf5"
EOF
fi

# Main editor loop
while true; do
    # Load current colors
    source "$THEME_DIR/colors.conf"

    THEME_NAME=$(basename "$THEME_DIR")

    OPTIONS="Edit Colors
Edit Metadata
Preview Theme
Generate Configs
Save & Apply Theme
Export Theme
Back"

    selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt=" Editing: $THEME_NAME " --lines=7)

    case "$selected" in
        *"Edit Colors"*)
            # Show color editing menu
            COLOR_OPTIONS="Background: $background
Foreground: $foreground
Black (color0): $color0
Red (color1): $color1
Green (color2): $color2
Yellow (color3): $color3
Blue (color4): $color4
Magenta (color5): $color5
Cyan (color6): $color6
White (color7): $color7
Bright Black (color8): $color8
Bright Red (color9): $color9
Bright Green (color10): $color10
Bright Yellow (color11): $color11
Bright Blue (color12): $color12
Bright Magenta (color13): $color13
Bright Cyan (color14): $color14
Bright White (color15): $color15
Done"

            COLOR=$(echo "$COLOR_OPTIONS" | fuzzel --dmenu --prompt="Select color to edit: " --lines=19)

            if [[ "$COLOR" == *"Done"* ]] || [ -z "$COLOR" ]; then
                continue
            fi

            # Extract color name and current value
            if [[ "$COLOR" == *"Background"* ]]; then
                NEW_VALUE=$("$EDITOR_DIR/color-picker.sh" "Background" "$background")
                [ $? -eq 0 ] && sed -i "s/^background=.*/background=\"$NEW_VALUE\"/" "$THEME_DIR/colors.conf"
            elif [[ "$COLOR" == *"Foreground"* ]]; then
                NEW_VALUE=$("$EDITOR_DIR/color-picker.sh" "Foreground" "$foreground")
                [ $? -eq 0 ] && sed -i "s/^foreground=.*/foreground=\"$NEW_VALUE\"/" "$THEME_DIR/colors.conf"
            elif [[ "$COLOR" =~ color([0-9]+) ]]; then
                COLOR_NUM="${BASH_REMATCH[1]}"
                COLOR_VAR="color$COLOR_NUM"
                CURRENT_VAL=$(eval echo \$$COLOR_VAR)
                NEW_VALUE=$("$EDITOR_DIR/color-picker.sh" "$COLOR_VAR" "$CURRENT_VAL")
                [ $? -eq 0 ] && sed -i "s/^color$COLOR_NUM=.*/color$COLOR_NUM=\"$NEW_VALUE\"/" "$THEME_DIR/colors.conf"
            fi
            ;;

        *"Edit Metadata"*)
            "$EDITOR_DIR/metadata-editor.sh" "$THEME_DIR"
            ;;

        *"Preview"*)
            # Generate configs first
            "$EDITOR_DIR/generate-configs.sh" "$THEME_DIR"

            # Preview in terminal
            if [ -f "$THEME_DIR/alacritty.toml" ]; then
                TEMP_CONFIG="/tmp/theme-preview-$$.toml"
                cat > "$TEMP_CONFIG" << 'ALACRITTY_END'
[window]
padding = { x = 10, y = 10 }
decorations = "full"
opacity = 1.0

[font]
size = 11
ALACRITTY_END
                cat "$THEME_DIR/alacritty.toml" >> "$TEMP_CONFIG"

                PREVIEW_SCRIPT="/tmp/theme-editor-preview-$$.sh"
                cat > "$PREVIEW_SCRIPT" << 'PREVIEW_EOF'
#!/bin/bash
clear
source "$1"
echo "════════════════════════════════════════════════════════════"
echo "  Theme Preview: $(basename $(dirname $1))"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Regular colors:"
echo -e "\033[30m■ Black\033[0m   \033[31m■ Red\033[0m     \033[32m■ Green\033[0m   \033[33m■ Yellow\033[0m"
echo -e "\033[34m■ Blue\033[0m    \033[35m■ Magenta\033[0m \033[36m■ Cyan\033[0m    \033[37m■ White\033[0m"
echo ""
echo "Bright colors:"
echo -e "\033[90m■ Black\033[0m   \033[91m■ Red\033[0m     \033[92m■ Green\033[0m   \033[93m■ Yellow\033[0m"
echo -e "\033[94m■ Blue\033[0m    \033[95m■ Magenta\033[0m \033[96m■ Cyan\033[0m    \033[97m■ White\033[0m"
echo ""
echo "Example code:"
echo -e "\033[34mfunction\033[0m \033[33mgreet\033[0m() {"
echo -e "  \033[32mecho\033[0m \033[36m\"Hello, World!\"\033[0m"
echo "}"
echo ""
echo "Press Enter to close preview..."
read
PREVIEW_EOF
                chmod +x "$PREVIEW_SCRIPT"
                alacritty --config-file "$TEMP_CONFIG" -e "$PREVIEW_SCRIPT" "$THEME_DIR/colors.conf"
                rm -f "$TEMP_CONFIG" "$PREVIEW_SCRIPT"
            fi
            ;;

        *"Generate Configs"*)
            "$EDITOR_DIR/generate-configs.sh" "$THEME_DIR"
            ;;

        *"Save & Apply"*)
            # Generate all configs
            "$EDITOR_DIR/generate-configs.sh" "$THEME_DIR"

            # Link to themes directory
            ln -sf "$THEME_DIR" "$HOME/.config/omarchy/themes/$(basename "$THEME_DIR")"

            # Apply theme
            notify-send "Applying Theme" "Switching to $(basename "$THEME_DIR")..."
            omarchy-theme-set "$(basename "$THEME_DIR")"
            notify-send "✓ Theme Applied" "Theme saved and activated"
            ;;

        *"Export"*)
            # Generate configs before export
            "$EDITOR_DIR/generate-configs.sh" "$THEME_DIR"

            # Export theme
            ~/.config/rice-menu/themes/sharing/export.sh "$THEME_DIR"
            ;;

        *"Back"|"")
            exit 0
            ;;
    esac
done
