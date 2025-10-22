#!/bin/bash
# Import Theme - Install theme from file or URL

OPTIONS="From URL
From Local File
From Clipboard (URL)
Back"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt=" Import Theme: " --lines=4)

TEMP_FILE=""

case "$selected" in
    *"From URL"*)
        URL=$(echo "" | fuzzel --dmenu --prompt="Enter theme URL: ")

        if [ -z "$URL" ]; then
            exit 0
        fi

        notify-send "Downloading Theme" "Fetching from $URL..."

        TEMP_FILE="/tmp/theme-download-$$.omarchy-theme"

        # Download the file
        if curl -L "$URL" -o "$TEMP_FILE" 2>/dev/null; then
            # Verify it's a valid tar.gz
            if tar -tzf "$TEMP_FILE" &>/dev/null; then
                notify-send "✓ Downloaded" "Theme downloaded successfully"
            else
                notify-send "Invalid File" "Downloaded file is not a valid theme package"
                rm -f "$TEMP_FILE"
                exit 1
            fi
        else
            notify-send "Download Failed" "Could not download theme from URL"
            rm -f "$TEMP_FILE"
            exit 1
        fi
        ;;

    *"From Local File"*)
        # Find .omarchy-theme files
        THEME_FILES=$(find ~/Downloads ~/.local/share/omarchy/theme-exports -name "*.omarchy-theme" 2>/dev/null | head -20)

        if [ -z "$THEME_FILES" ]; then
            notify-send "No Files Found" "No .omarchy-theme files found in Downloads or exports folder"
            exit 0
        fi

        SELECTED_FILE=$(echo "$THEME_FILES" | sed 's|.*/||' | fuzzel --dmenu --prompt="Select theme file: " --lines=15)

        if [ -z "$SELECTED_FILE" ]; then
            exit 0
        fi

        # Find full path
        TEMP_FILE=$(echo "$THEME_FILES" | grep "$SELECTED_FILE")
        ;;

    *"From Clipboard"*)
        URL=$(wl-paste)

        if [ -z "$URL" ]; then
            notify-send "Clipboard Empty" "No URL found in clipboard"
            exit 0
        fi

        # Check if it looks like a URL
        if [[ ! "$URL" =~ ^https?:// ]]; then
            notify-send "Invalid URL" "Clipboard does not contain a valid URL"
            exit 0
        fi

        notify-send "Downloading Theme" "Fetching from clipboard URL..."

        TEMP_FILE="/tmp/theme-download-$$.omarchy-theme"

        if curl -L "$URL" -o "$TEMP_FILE" 2>/dev/null; then
            if tar -tzf "$TEMP_FILE" &>/dev/null; then
                notify-send "✓ Downloaded" "Theme downloaded successfully"
            else
                notify-send "Invalid File" "Downloaded file is not a valid theme package"
                rm -f "$TEMP_FILE"
                exit 1
            fi
        else
            notify-send "Download Failed" "Could not download theme from URL"
            rm -f "$TEMP_FILE"
            exit 1
        fi
        ;;

    *)
        exit 0
        ;;
esac

# If we have a theme file, extract and install it
if [ -n "$TEMP_FILE" ] && [ -f "$TEMP_FILE" ]; then
    # Extract to temp directory to inspect
    EXTRACT_DIR="/tmp/theme-extract-$$"
    mkdir -p "$EXTRACT_DIR"

    tar -xzf "$TEMP_FILE" -C "$EXTRACT_DIR"

    # Find the theme directory
    THEME_DIR=$(find "$EXTRACT_DIR" -maxdepth 1 -type d ! -path "$EXTRACT_DIR" | head -1)

    if [ -z "$THEME_DIR" ]; then
        notify-send "Invalid Package" "Could not find theme directory in package"
        rm -rf "$EXTRACT_DIR"
        exit 1
    fi

    THEME_NAME=$(basename "$THEME_DIR")

    # Load metadata if available
    if [ -f "$THEME_DIR/theme.json" ]; then
        DISPLAY_NAME=$(jq -r '.name // ""' "$THEME_DIR/theme.json" 2>/dev/null)
        AUTHOR=$(jq -r '.author // "Unknown"' "$THEME_DIR/theme.json" 2>/dev/null)
        DESCRIPTION=$(jq -r '.description // ""' "$THEME_DIR/theme.json" 2>/dev/null)
        VERSION=$(jq -r '.version // "1.0.0"' "$THEME_DIR/theme.json" 2>/dev/null)

        INFO="Theme: $DISPLAY_NAME
Author: $AUTHOR
Version: $VERSION
Description: $DESCRIPTION

Install this theme?"

        INSTALL_OPTIONS="Install Only
Install & Apply
Preview First
Cancel"

        action=$(echo "$INSTALL_OPTIONS" | fuzzel --dmenu --prompt="Import: $DISPLAY_NAME " --lines=4)

        case "$action" in
            *"Preview First"*)
                # Show preview
                if [ -f "$THEME_DIR/alacritty.toml" ]; then
                    TEMP_CONFIG="/tmp/theme-import-preview-$$.toml"
                    cat > "$TEMP_CONFIG" << 'ALACRITTY_END'
[window]
padding = { x = 10, y = 10 }
decorations = "full"
opacity = 1.0

[font]
size = 11
ALACRITTY_END
                    cat "$THEME_DIR/alacritty.toml" >> "$TEMP_CONFIG"

                    PREVIEW_SCRIPT="/tmp/theme-import-preview-$$.sh"
                    cat > "$PREVIEW_SCRIPT" << PREVIEW_EOF
#!/bin/bash
clear
echo "════════════════════════════════════════════════════════════"
echo "  Preview: $DISPLAY_NAME"
echo "  Author: $AUTHOR"
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
echo "Press Enter to close preview..."
read
PREVIEW_EOF
                    chmod +x "$PREVIEW_SCRIPT"
                    alacritty --config-file "$TEMP_CONFIG" -e "$PREVIEW_SCRIPT"
                    rm -f "$TEMP_CONFIG" "$PREVIEW_SCRIPT"
                fi

                # Ask again after preview
                action=$(echo -e "Install Only\nInstall & Apply\nCancel" | fuzzel --dmenu --prompt="After preview: ")
                ;;
        esac

        case "$action" in
            *"Install"*)
                # Install theme
                INSTALL_DIR="$HOME/.local/share/omarchy/themes/$THEME_NAME"

                if [ -d "$INSTALL_DIR" ]; then
                    OVERWRITE=$(echo -e "Yes, overwrite\nNo, cancel" | fuzzel --dmenu --prompt="Theme exists. Overwrite? ")
                    if [[ ! "$OVERWRITE" =~ "Yes" ]]; then
                        rm -rf "$EXTRACT_DIR"
                        exit 0
                    fi
                    rm -rf "$INSTALL_DIR"
                fi

                cp -r "$THEME_DIR" "$INSTALL_DIR"
                ln -sf "$INSTALL_DIR" "$HOME/.config/omarchy/themes/$THEME_NAME"

                notify-send "✓ Theme Installed" "$DISPLAY_NAME installed successfully"

                if [[ "$action" =~ "Apply" ]]; then
                    notify-send "Applying Theme" "Switching to $DISPLAY_NAME..."
                    omarchy-theme-set "$THEME_NAME"
                    notify-send "✓ Theme Applied" "Now using $DISPLAY_NAME"
                fi
                ;;
        esac
    else
        # No metadata, basic install
        INSTALL_DIR="$HOME/.local/share/omarchy/themes/$THEME_NAME"
        cp -r "$THEME_DIR" "$INSTALL_DIR"
        ln -sf "$INSTALL_DIR" "$HOME/.config/omarchy/themes/$THEME_NAME"
        notify-send "✓ Theme Installed" "$THEME_NAME installed"
    fi

    # Cleanup
    rm -rf "$EXTRACT_DIR"
    [ -f "/tmp/theme-download-$$.omarchy-theme" ] && rm -f "/tmp/theme-download-$$.omarchy-theme"
fi
