#!/bin/bash
# Upload Theme - Upload to transfer.sh or GitHub Gist

THEME_FILE="$1"

if [ -z "$THEME_FILE" ] || [ ! -f "$THEME_FILE" ]; then
    notify-send "Error" "Invalid theme file"
    exit 1
fi

THEME_NAME=$(basename "$THEME_FILE" .omarchy-theme)

OPTIONS="transfer.sh (7 days, no account)
0x0.st (365 days, no account)
GitHub Gist (permanent, requires token)
Cancel"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt="Upload $THEME_NAME: " --lines=4)

case "$selected" in
    *"transfer.sh"*)
        notify-send "Uploading" "Uploading to transfer.sh..."

        URL=$(curl --upload-file "$THEME_FILE" "https://transfer.sh/$(basename "$THEME_FILE")" 2>/dev/null)

        if [ -n "$URL" ]; then
            echo -n "$URL" | wl-copy

            # Show success with instructions
            INSTRUCTIONS="Theme uploaded successfully!

URL (copied to clipboard):
$URL

Valid for: 7 days

Share this URL with others to let them download your theme.

To download:
curl -L \"$URL\" -o theme.omarchy-theme"

            echo "$INSTRUCTIONS" | fuzzel --dmenu --prompt="✓ Upload Complete" --lines=10 || true
            notify-send "✓ Upload Complete" "URL copied to clipboard\n$URL"
        else
            notify-send "Upload Failed" "Could not upload to transfer.sh"
        fi
        ;;

    *"0x0.st"*)
        notify-send "Uploading" "Uploading to 0x0.st..."

        URL=$(curl -F "file=@$THEME_FILE" https://0x0.st 2>/dev/null)

        if [ -n "$URL" ]; then
            echo -n "$URL" | wl-copy

            INSTRUCTIONS="Theme uploaded successfully!

URL (copied to clipboard):
$URL

Valid for: 365 days

Share this URL with others to let them download your theme.

To download:
curl -L \"$URL\" -o theme.omarchy-theme"

            echo "$INSTRUCTIONS" | fuzzel --dmenu --prompt="✓ Upload Complete" --lines=10 || true
            notify-send "✓ Upload Complete" "URL copied to clipboard\n$URL"
        else
            notify-send "Upload Failed" "Could not upload to 0x0.st"
        fi
        ;;

    *"GitHub Gist"*)
        # Check if gh CLI is installed and authenticated
        if ! command -v gh &> /dev/null || ! gh auth status &> /dev/null; then
            SETUP_OPTIONS="Setup GitHub Gist Now
Cancel Upload"

            setup=$(echo "$SETUP_OPTIONS" | fuzzel --dmenu --prompt="GitHub Gist not configured: " --lines=2)

            if [[ "$setup" =~ "Setup" ]]; then
                ~/.config/rice-menu/themes/sharing/setup-gist.sh

                # Check again after setup
                if ! gh auth status &> /dev/null; then
                    notify-send "Setup Incomplete" "GitHub Gist not configured"
                    exit 1
                fi
            else
                exit 0
            fi
        fi

        notify-send "Uploading" "Uploading to GitHub Gist..."

        # Extract theme for gist (unpack to temp dir)
        TEMP_DIR="/tmp/gist-upload-$$"
        mkdir -p "$TEMP_DIR"
        tar -xzf "$THEME_FILE" -C "$TEMP_DIR"

        THEME_DIR_NAME=$(ls "$TEMP_DIR" | head -1)
        THEME_PATH="$TEMP_DIR/$THEME_DIR_NAME"

        # Debug: list what was extracted
        echo "Extracted theme contents:" > /tmp/gist-upload-debug.log
        ls -la "$THEME_PATH" >> /tmp/gist-upload-debug.log

        # Get theme description from metadata
        DESCRIPTION="Omarchy Theme: $THEME_NAME"
        THEME_DISPLAY_NAME="$THEME_NAME"
        if [ -f "$THEME_PATH/theme.json" ]; then
            DESCRIPTION=$(jq -r '.description // "Omarchy Theme"' "$THEME_PATH/theme.json" 2>/dev/null)
            THEME_DISPLAY_NAME=$(jq -r '.name // "'"$THEME_NAME"'"' "$THEME_PATH/theme.json" 2>/dev/null)
        fi

        # Create gist with config files AND the full theme package
        cd "$THEME_PATH"

        # Build list of config files to upload (for preview in gist)
        FILES_TO_UPLOAD=""
        for file in *.toml *.conf *.css *.ini colors.conf theme.json README.md; do
            if [ -f "$file" ]; then
                FILES_TO_UPLOAD="$FILES_TO_UPLOAD $file"
                echo "Found file to upload: $file" >> /tmp/gist-upload-debug.log
            fi
        done

        echo "Files to upload: $FILES_TO_UPLOAD" >> /tmp/gist-upload-debug.log

        if [ -z "$FILES_TO_UPLOAD" ]; then
            notify-send "Upload Failed" "No theme files found to upload. Check /tmp/gist-upload-debug.log"
            rm -rf "$TEMP_DIR"
            exit 1
        fi

        # Upload the full package to 0x0.st (since Gist doesn't support binary files)
        notify-send "Uploading Package" "Uploading full theme package to 0x0.st..."
        PACKAGE_URL=$(curl -F "file=@$THEME_FILE" https://0x0.st 2>/dev/null)

        if [ -z "$PACKAGE_URL" ]; then
            notify-send "Warning" "Could not upload package file, continuing with configs only..."
            PACKAGE_URL="(upload failed - share the .omarchy-theme file manually)"
        fi

        echo "Package uploaded to: $PACKAGE_URL" >> /tmp/gist-upload-debug.log

        # Create installation instructions file
        cat > "$THEME_PATH/INSTALL.md" << EOF
# $THEME_DISPLAY_NAME - Omarchy Theme

$DESCRIPTION

## Requirements

This theme requires **Omarchy Rice Config** to be installed.

**Get Omarchy:** [github.com/0xMassi/omarchy-rice-config](https://github.com/0xMassi/omarchy-rice-config)

If you don't have Omarchy installed, follow the installation guide in the repository README.

## Installation

### Automatic Import (Recommended)

1. Download the theme package: [\`${THEME_NAME}.omarchy-theme\`]($PACKAGE_URL)
2. Open **Omarchy Rice Menu** (Super + R)
3. Navigate to: **Themes → Export/Import → Import Theme**
4. Select **"From Local File"** and choose the downloaded file
5. Preview the theme, then click **"Install & Apply"**
6. Done! Your theme is now active.

### Quick Import from URL

\`\`\`bash
# Download and open Rice Menu for import
curl -L "$PACKAGE_URL" -o ~/Downloads/${THEME_NAME}.omarchy-theme
# Then: Super + R → Themes → Export/Import → Import Theme → From Local File
\`\`\`

### Manual Installation

\`\`\`bash
# Download the theme package (includes wallpapers)
curl -L "$PACKAGE_URL" -o ${THEME_NAME}.omarchy-theme

# Extract to Omarchy themes directory
mkdir -p ~/.local/share/omarchy/themes
tar -xzf ${THEME_NAME}.omarchy-theme -C ~/.local/share/omarchy/themes

# Link to active themes
ln -sf ~/.local/share/omarchy/themes/${THEME_NAME} ~/.config/omarchy/themes/${THEME_NAME}

# Apply the theme
omarchy-theme-set ${THEME_NAME}
\`\`\`

## Download

**Full Theme Package (includes wallpapers):** $PACKAGE_URL

*Package hosted on 0x0.st - valid for 365 days*

## What's Included

- All color configs (Alacritty, Hyprland, Waybar, Fuzzel, etc.)
- Theme metadata and description
- Wallpapers (if available)
- Complete installation instructions

## Support

For issues or questions:
- **Omarchy Rice Config:** [github.com/0xMassi/omarchy-rice-config/issues](https://github.com/0xMassi/omarchy-rice-config/issues)
- **Theme Editor Documentation:** Check the Omarchy repository wiki

---
*Created with Omarchy Theme Editor*
EOF

        FILES_TO_UPLOAD="$FILES_TO_UPLOAD INSTALL.md"

        # Upload to gist
        echo "Running: gh gist create --public --desc \"$DESCRIPTION\" $FILES_TO_UPLOAD" >> /tmp/gist-upload-debug.log
        GIST_OUTPUT=$(gh gist create --public --desc "$DESCRIPTION" $FILES_TO_UPLOAD 2>&1)
        echo "Gist output: $GIST_OUTPUT" >> /tmp/gist-upload-debug.log

        GIST_URL=$(echo "$GIST_OUTPUT" | grep -o 'https://gist.github.com/[^[:space:]]*' | head -1)
        echo "Extracted URL: $GIST_URL" >> /tmp/gist-upload-debug.log

        # Debug: if upload failed, show error
        if [ -z "$GIST_URL" ]; then
            notify-send "Upload Failed" "Check /tmp/gist-upload-debug.log for details"
            rm -rf "$TEMP_DIR"
            exit 1
        fi

        rm -rf "$TEMP_DIR"

        if [ -n "$GIST_URL" ]; then
            echo -n "$GIST_URL" | wl-copy

            INSTRUCTIONS="✓ Theme uploaded to GitHub Gist!

Gist URL (copied to clipboard):
$GIST_URL

Theme Package URL (with wallpapers):
$PACKAGE_URL

The gist contains:
• All config files (for preview)
• Installation instructions
• Link to full package download

Share the gist URL with others!
They can download and import the theme using the instructions."

            echo "$INSTRUCTIONS" | fuzzel --dmenu --prompt="✓ Upload Complete" --lines=12 || true
            notify-send "✓ Upload Complete" "Gist: $GIST_URL\nPackage: $PACKAGE_URL"
        else
            notify-send "Upload Failed" "Could not create gist"
        fi
        ;;

    *)
        exit 0
        ;;
esac
