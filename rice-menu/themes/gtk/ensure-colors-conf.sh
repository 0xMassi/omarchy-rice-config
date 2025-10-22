#!/bin/bash
# Ensure colors.conf exists - Auto-generate from theme files if missing
# This script extracts colors from alacritty.toml, waybar.css, or hyprland.conf

THEME_DIR="$1"

if [ -z "$THEME_DIR" ] || [ ! -d "$THEME_DIR" ]; then
    echo "Error: Invalid theme directory"
    exit 1
fi

COLORS_FILE="$THEME_DIR/colors.conf"

# If colors.conf already exists, we're done
if [ -f "$COLORS_FILE" ]; then
    exit 0
fi

echo "Auto-generating colors.conf for $(basename "$THEME_DIR")..."

# Try to extract colors from alacritty.toml (most reliable source)
if [ -f "$THEME_DIR/alacritty.toml" ]; then
    echo "# Auto-generated from alacritty.toml" > "$COLORS_FILE"
    echo "" >> "$COLORS_FILE"

    # Extract background and foreground
    background=$(grep -E '^\s*background\s*=' "$THEME_DIR/alacritty.toml" | head -1 | sed -E 's/.*"([^"]+)".*/\1/')
    foreground=$(grep -E '^\s*foreground\s*=' "$THEME_DIR/alacritty.toml" | head -1 | sed -E 's/.*"([^"]+)".*/\1/')

    echo "background=\"$background\"" >> "$COLORS_FILE"
    echo "foreground=\"$foreground\"" >> "$COLORS_FILE"
    echo "" >> "$COLORS_FILE"

    # Extract normal colors
    for i in {0..7}; do
        color=$(grep -A 8 '^\[colors.normal\]' "$THEME_DIR/alacritty.toml" | grep -E "^\s*(black|red|green|yellow|blue|magenta|cyan|white)\s*=" | sed -n "$((i+1))p" | sed -E 's/.*"([^"]+)".*/\1/')
        echo "color$i=\"$color\"" >> "$COLORS_FILE"
    done

    echo "" >> "$COLORS_FILE"

    # Extract bright colors
    for i in {8..15}; do
        idx=$((i-8))
        color=$(grep -A 8 '^\[colors.bright\]' "$THEME_DIR/alacritty.toml" | grep -E "^\s*(black|red|green|yellow|blue|magenta|cyan|white)\s*=" | sed -n "$((idx+1))p" | sed -E 's/.*"([^"]+)".*/\1/')
        echo "color$i=\"$color\"" >> "$COLORS_FILE"
    done

    echo "✓ Generated colors.conf from alacritty.toml"
    exit 0
fi

# Fallback: Try to extract from waybar.css
if [ -f "$THEME_DIR/waybar.css" ]; then
    echo "# Auto-generated from waybar.css" > "$COLORS_FILE"
    echo "" >> "$COLORS_FILE"

    background=$(grep '@define-color background' "$THEME_DIR/waybar.css" | sed -E 's/.*#([0-9a-fA-F]{6}).*/\1/' | head -1)
    foreground=$(grep '@define-color foreground' "$THEME_DIR/waybar.css" | sed -E 's/.*#([0-9a-fA-F]{6}).*/\1/' | head -1)
    accent=$(grep '@define-color accent' "$THEME_DIR/waybar.css" | sed -E 's/.*#([0-9a-fA-F]{6}).*/\1/' | head -1)

    if [ -n "$background" ]; then
        echo "background=\"#$background\"" >> "$COLORS_FILE"
    else
        echo "background=\"#1a1b26\"" >> "$COLORS_FILE"
    fi

    if [ -n "$foreground" ]; then
        echo "foreground=\"#$foreground\"" >> "$COLORS_FILE"
    else
        echo "foreground=\"#c0caf5\"" >> "$COLORS_FILE"
    fi

    echo "" >> "$COLORS_FILE"

    # Generate basic color palette based on background/foreground/accent
    # This is a fallback and won't be perfect, but better than nothing
    echo "color0=\"#${background:-1a1b26}\"" >> "$COLORS_FILE"
    echo "color1=\"#${accent:-7aa2f7}\"" >> "$COLORS_FILE"
    echo "color2=\"#9ece6a\"" >> "$COLORS_FILE"
    echo "color3=\"#e0af68\"" >> "$COLORS_FILE"
    echo "color4=\"#${accent:-7aa2f7}\"" >> "$COLORS_FILE"
    echo "color5=\"#bb9af7\"" >> "$COLORS_FILE"
    echo "color6=\"#7dcfff\"" >> "$COLORS_FILE"
    echo "color7=\"#${foreground:-c0caf5}\"" >> "$COLORS_FILE"
    echo "" >> "$COLORS_FILE"
    echo "color8=\"#414868\"" >> "$COLORS_FILE"
    echo "color9=\"#${accent:-7aa2f7}\"" >> "$COLORS_FILE"
    echo "color10=\"#9ece6a\"" >> "$COLORS_FILE"
    echo "color11=\"#e0af68\"" >> "$COLORS_FILE"
    echo "color12=\"#${accent:-7aa2f7}\"" >> "$COLORS_FILE"
    echo "color13=\"#bb9af7\"" >> "$COLORS_FILE"
    echo "color14=\"#7dcfff\"" >> "$COLORS_FILE"
    echo "color15=\"#${foreground:-c0caf5}\"" >> "$COLORS_FILE"

    echo "⚠ Generated basic colors.conf from waybar.css (limited palette)"
    exit 0
fi

echo "⚠ Warning: Could not auto-generate colors.conf - no suitable source file found"
exit 1
