#!/bin/bash
# Generate Omarchy theme from iTerm2 color scheme

SCHEME_FILE="$1"
THEME_NAME="$2"
OUTPUT_DIR="$HOME/.local/share/omarchy/themes/$THEME_NAME"

if [ -z "$SCHEME_FILE" ] || [ ! -f "$SCHEME_FILE" ]; then
    echo "Usage: generate-from-scheme.sh <scheme-file.toml> <theme-name>"
    exit 1
fi

if [ -z "$THEME_NAME" ]; then
    THEME_NAME=$(basename "$SCHEME_FILE" .toml | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
fi

echo "Generating Omarchy theme from color scheme"
echo "Source: $SCHEME_FILE"
echo "Output: $OUTPUT_DIR"
echo ""

mkdir -p "$OUTPUT_DIR/backgrounds"

# Extract colors from scheme
BG_COLOR=$(grep "^background = " "$SCHEME_FILE" | grep -oE '#[0-9a-fA-F]{6}' | head -1)
FG_COLOR=$(grep "^foreground = " "$SCHEME_FILE" | grep -oE '#[0-9a-fA-F]{6}' | head -1)
CURSOR_COLOR=$(grep "^cursor = " "$SCHEME_FILE" | grep -oE '#[0-9a-fA-F]{6}' | head -1)

# Extract a vibrant color for accent (use cyan or blue)
ACCENT_COLOR=$(grep "^cyan = " "$SCHEME_FILE" | grep -oE '#[0-9a-fA-F]{6}' | head -1)
if [ -z "$ACCENT_COLOR" ]; then
    ACCENT_COLOR=$(grep "^blue = " "$SCHEME_FILE" | grep -oE '#[0-9a-fA-F]{6}' | head -1)
fi
if [ -z "$ACCENT_COLOR" ]; then
    ACCENT_COLOR="$CURSOR_COLOR"
fi

# Fallbacks
BG_COLOR="${BG_COLOR:-#1e1e2e}"
FG_COLOR="${FG_COLOR:-#cdd6f4}"
ACCENT_COLOR="${ACCENT_COLOR:-#89dceb}"

echo "Extracted colors:"
echo "  Background: $BG_COLOR"
echo "  Foreground: $FG_COLOR"
echo "  Accent: $ACCENT_COLOR"
echo ""

# Copy alacritty scheme
echo "→ Copying alacritty scheme"
cp "$SCHEME_FILE" "$OUTPUT_DIR/alacritty.toml"

# Find and copy corresponding kitty scheme
SCHEME_NAME=$(basename "$SCHEME_FILE" .toml)
KITTY_SCHEME="$(dirname "$(dirname "$SCHEME_FILE")")/kitty/${SCHEME_NAME}.conf"
if [ -f "$KITTY_SCHEME" ]; then
    echo "→ Copying kitty scheme"
    cp "$KITTY_SCHEME" "$OUTPUT_DIR/kitty.conf"
else
    echo "→ Generating basic kitty.conf"
    cat > "$OUTPUT_DIR/kitty.conf" << EOF
foreground $FG_COLOR
background $BG_COLOR
cursor $ACCENT_COLOR
EOF
fi

# Generate fuzzel.ini
echo "→ Generating fuzzel.ini"
cat > "$OUTPUT_DIR/fuzzel.ini" << EOF
[colors]
background=${BG_COLOR}f9
prompt=${FG_COLOR}ff
input=${FG_COLOR}ff
text=${FG_COLOR}ff
match=${FG_COLOR}ff
selection-match=${ACCENT_COLOR}ff
selection=00000000
selection-text=${ACCENT_COLOR}ff
border=${ACCENT_COLOR}ff
EOF

# Generate mako.ini
echo "→ Generating mako.ini"
cat > "$OUTPUT_DIR/mako.ini" << EOF
include=~/.local/share/omarchy/default/mako/core.ini

text-color=${FG_COLOR}
border-color=${ACCENT_COLOR}
background-color=${BG_COLOR}
padding=10
border-size=2
font=Liberation Sans 11
max-icon-size=32
outer-margin=20
EOF

# Generate waybar.css
echo "→ Generating waybar.css"
cat > "$OUTPUT_DIR/waybar.css" << EOF
@define-color foreground $FG_COLOR;
@define-color background $BG_COLOR;
EOF

# Generate hyprland.conf
echo "→ Generating hyprland.conf"
ACCENT_RGB=$(echo "$ACCENT_COLOR" | sed 's/#//')
cat > "$OUTPUT_DIR/hyprland.conf" << EOF
general {
    col.active_border = rgb($ACCENT_RGB)
}
EOF

# Generate theme.info
cat > "$OUTPUT_DIR/theme.info" << EOF
name=$THEME_NAME
source=$SCHEME_FILE
type=color-scheme
generated=$(date +%Y-%m-%d)
colors_bg=$BG_COLOR
colors_fg=$FG_COLOR
colors_accent=$ACCENT_COLOR
EOF

echo ""
echo "✓ Theme generated successfully!"
echo "Location: $OUTPUT_DIR"
echo ""
echo "To use:"
echo "  ln -sf $OUTPUT_DIR ~/.config/omarchy/themes/$THEME_NAME"
echo "  omarchy-theme-set $THEME_NAME"
