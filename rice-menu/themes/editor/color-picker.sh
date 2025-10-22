#!/bin/bash
# Color Picker - Visual color selection for theme editing

COLOR_NAME="$1"
CURRENT_VALUE="$2"

if [ -z "$COLOR_NAME" ]; then
    echo "Error: No color name provided"
    exit 1
fi

# Default to black if no current value
[ -z "$CURRENT_VALUE" ] && CURRENT_VALUE="#000000"

while true; do
    OPTIONS="Enter HEX Value
Enter RGB Values
Pick from Palette
Copy from Theme
Preview Color
Done (Save: $CURRENT_VALUE)
Cancel"

    selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt="Edit $COLOR_NAME (Current: $CURRENT_VALUE): " --lines=7)

    case "$selected" in
        *"Enter HEX"*)
            # Get HEX value from user
            HEX=$(echo "$CURRENT_VALUE" | fuzzel --dmenu --prompt="Enter HEX color (#RRGGBB): ")

            # Validate HEX format
            if [[ "$HEX" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
                CURRENT_VALUE="$HEX"
                notify-send "Color Updated" "$COLOR_NAME set to $HEX"
            else
                notify-send "Invalid HEX" "Format must be #RRGGBB (e.g., #FF5733)"
            fi
            ;;

        *"Enter RGB"*)
            # Get RGB values
            R=$(echo "255" | fuzzel --dmenu --prompt="Red (0-255): ")
            [ -z "$R" ] && continue

            G=$(echo "255" | fuzzel --dmenu --prompt="Green (0-255): ")
            [ -z "$G" ] && continue

            B=$(echo "255" | fuzzel --dmenu --prompt="Blue (0-255): ")
            [ -z "$B" ] && continue

            # Validate RGB ranges
            if [ "$R" -ge 0 ] && [ "$R" -le 255 ] && \
               [ "$G" -ge 0 ] && [ "$G" -le 255 ] && \
               [ "$B" -ge 0 ] && [ "$B" -le 255 ] 2>/dev/null; then
                # Convert RGB to HEX
                CURRENT_VALUE=$(printf "#%02X%02X%02X" "$R" "$G" "$B")
                notify-send "Color Updated" "$COLOR_NAME set to $CURRENT_VALUE (RGB: $R,$G,$B)"
            else
                notify-send "Invalid RGB" "Values must be 0-255"
            fi
            ;;

        *"Pick from Palette"*)
            # Preset color palette
            PALETTE="Black #000000
White #FFFFFF
Red #FF0000
Green #00FF00
Blue #0000FF
Yellow #FFFF00
Cyan #00FFFF
Magenta #FF00FF
Orange #FF8800
Purple #8800FF
Pink #FF00AA
Lime #88FF00
Sky Blue #00AAFF
Violet #AA00FF
Dark Red #880000
Dark Green #008800
Dark Blue #000088
Gray #808080
Light Gray #C0C0C0
Dark Gray #404040"

            COLOR=$(echo "$PALETTE" | fuzzel --dmenu --prompt="Select color: " --lines=20)
            if [ -n "$COLOR" ]; then
                CURRENT_VALUE=$(echo "$COLOR" | awk '{print $NF}')
                notify-send "Color Updated" "$COLOR_NAME set to $CURRENT_VALUE"
            fi
            ;;

        *"Copy from Theme"*)
            # List installed themes to copy colors from
            THEME_DIR="$HOME/.config/omarchy/themes"
            THEMES=$(ls -1 "$THEME_DIR" 2>/dev/null)

            if [ -z "$THEMES" ]; then
                notify-send "No Themes" "No installed themes found"
                continue
            fi

            THEME=$(echo "$THEMES" | fuzzel --dmenu --prompt="Copy from theme: " --lines=15)
            if [ -z "$THEME" ]; then
                continue
            fi

            # Extract colors from theme's alacritty.toml
            THEME_FILE="$THEME_DIR/$THEME/alacritty.toml"
            if [ ! -f "$THEME_FILE" ]; then
                notify-send "Error" "Theme config not found"
                continue
            fi

            # Show available colors from that theme
            COLORS=$(grep -E "^(background|foreground|black|red|green|yellow|blue|magenta|cyan|white)" "$THEME_FILE" | \
                     sed 's/[="]//g' | sed 's/  */ /g')

            if [ -z "$COLORS" ]; then
                notify-send "Error" "No colors found in theme"
                continue
            fi

            COLOR=$(echo "$COLORS" | fuzzel --dmenu --prompt="Select color from $THEME: " --lines=20)
            if [ -n "$COLOR" ]; then
                CURRENT_VALUE=$(echo "$COLOR" | awk '{print $NF}')
                notify-send "Color Copied" "$COLOR_NAME set to $CURRENT_VALUE"
            fi
            ;;

        *"Preview"*)
            # Show preview in a terminal with the color
            PREVIEW_SCRIPT="/tmp/color-preview-$$.sh"
            cat > "$PREVIEW_SCRIPT" << PREVIEW_EOF
#!/bin/bash
clear
echo "════════════════════════════════════════"
echo " Color Preview: $COLOR_NAME"
echo " HEX: $CURRENT_VALUE"
echo "════════════════════════════════════════"
echo ""
echo "This is how the color looks in text"
echo ""
# Show the color as background
echo -e "\033[48;2;$((0x${CURRENT_VALUE:1:2}));$((0x${CURRENT_VALUE:3:2}));$((0x${CURRENT_VALUE:5:2}))m                                        \033[0m"
echo ""
echo "Press Enter to close preview..."
read
PREVIEW_EOF
            chmod +x "$PREVIEW_SCRIPT"
            alacritty -e "$PREVIEW_SCRIPT"
            rm -f "$PREVIEW_SCRIPT"
            ;;

        *"Done"*)
            # Return the selected color
            echo "$CURRENT_VALUE"
            exit 0
            ;;

        *"Cancel"|"")
            # Return original value
            echo "$2"
            exit 1
            ;;
    esac
done
