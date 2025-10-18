#!/bin/bash
# Theme Validator for Omarchy Compatibility

THEME_PATH="$1"

if [ -z "$THEME_PATH" ] || [ ! -d "$THEME_PATH" ]; then
    echo "ERROR: Invalid theme path"
    exit 1
fi

echo "Validating theme structure..."

# Required files for Omarchy theme
REQUIRED_FILES=(
    "fuzzel.ini"
    "mako.ini"
    "waybar.css"
)

OPTIONAL_FILES=(
    "hyprland.conf"
    "alacritty.toml"
    "backgrounds/"
)

MISSING_FILES=()
FOUND_FILES=()

# Check required files
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$THEME_PATH/$file" ] || [ -d "$THEME_PATH/$file" ]; then
        FOUND_FILES+=("$file")
    else
        MISSING_FILES+=("$file")
    fi
done

# Report results
if [ ${#MISSING_FILES[@]} -eq 0 ]; then
    echo "✓ Theme is Omarchy-compatible!"
    echo "Found: ${FOUND_FILES[*]}"
    exit 0
else
    echo "✗ Theme is NOT Omarchy-compatible"
    echo "Missing: ${MISSING_FILES[*]}"
    echo ""
    echo "This appears to be a generic dotfiles repo."
    echo "You can try the conversion tool to make it compatible."
    exit 1
fi
