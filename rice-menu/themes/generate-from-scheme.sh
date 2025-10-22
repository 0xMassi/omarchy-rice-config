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
@define-color accent $ACCENT_COLOR;
EOF

# Generate swaync.css
echo "→ Generating swaync.css"
cat > "$OUTPUT_DIR/swaync.css" << EOF
@define-color foreground $FG_COLOR;
@define-color background $BG_COLOR;
@define-color accent $ACCENT_COLOR;
EOF

# Generate hyprland.conf
echo "→ Generating hyprland.conf"
ACCENT_RGB=$(echo "$ACCENT_COLOR" | sed 's/#//')
cat > "$OUTPUT_DIR/hyprland.conf" << EOF
general {
    col.active_border = rgb($ACCENT_RGB)
}
EOF

# Generate btop.theme
echo "→ Generating btop.theme"
# Extract additional colors for btop
BLACK=$(grep "^black = " "$SCHEME_FILE" | grep -oE '#[0-9a-fA-F]{6}' | head -1)
RED=$(grep "^red = " "$SCHEME_FILE" | grep -oE '#[0-9a-fA-F]{6}' | head -1)
GREEN=$(grep "^green = " "$SCHEME_FILE" | grep -oE '#[0-9a-fA-F]{6}' | head -1)
YELLOW=$(grep "^yellow = " "$SCHEME_FILE" | grep -oE '#[0-9a-fA-F]{6}' | head -1)
BLUE=$(grep "^blue = " "$SCHEME_FILE" | grep -oE '#[0-9a-fA-F]{6}' | head -1)
MAGENTA=$(grep "^magenta = " "$SCHEME_FILE" | grep -oE '#[0-9a-fA-F]{6}' | head -1)
CYAN=$(grep "^cyan = " "$SCHEME_FILE" | grep -oE '#[0-9a-fA-F]{6}' | head -1)
WHITE=$(grep "^white = " "$SCHEME_FILE" | grep -oE '#[0-9a-fA-F]{6}' | head -1)

# Fallbacks for missing colors
BLACK="${BLACK:-#000000}"
RED="${RED:-#ff0000}"
GREEN="${GREEN:-#00ff00}"
YELLOW="${YELLOW:-#ffff00}"
BLUE="${BLUE:-#0000ff}"
MAGENTA="${MAGENTA:-#ff00ff}"
CYAN="${CYAN:-#00ffff}"
WHITE="${WHITE:-#ffffff}"

cat > "$OUTPUT_DIR/btop.theme" << EOF
# btop theme - Generated from $THEME_NAME

# Main background, empty for terminal default, need to be empty if you want transparent background
theme[main_bg]="$BG_COLOR"

# Main text color
theme[main_fg]="$FG_COLOR"

# Title color for boxes
theme[title]="$FG_COLOR"

# Highlight color for keyboard shortcuts
theme[hi_fg]="$ACCENT_COLOR"

# Background color of selected item in processes box
theme[selected_bg]="$ACCENT_COLOR"

# Foreground color of selected item in processes box
theme[selected_fg]="$BG_COLOR"

# Color of inactive/disabled text
theme[inactive_fg]="$BLACK"

# Color of text appearing on top of graphs, i.e uptime and current network graph scaling
theme[graph_text]="$FG_COLOR"

# Background color of the percentage meters
theme[meter_bg]="$BLACK"

# Misc colors for processes box including mini cpu graphs, details memory graph and details status text
theme[proc_misc]="$ACCENT_COLOR"

# CPU, Memory, Network, Proc box outline colors
theme[cpu_box]="$ACCENT_COLOR"
theme[mem_box]="$GREEN"
theme[net_box]="$MAGENTA"
theme[proc_box]="$BLUE"

# Box divider line and small boxes line color
theme[div_line]="$BLACK"

# Temperature graph color (Green -> Yellow -> Red)
theme[temp_start]="$GREEN"
theme[temp_mid]="$YELLOW"
theme[temp_end]="$RED"

# CPU graph colors (Teal -> Lavender)
theme[cpu_start]="$CYAN"
theme[cpu_mid]="$BLUE"
theme[cpu_end]="$MAGENTA"

# Mem/Disk free meter (Mauve -> Lavender -> Blue)
theme[free_start]="$MAGENTA"
theme[free_mid]="$BLUE"
theme[free_end]="$CYAN"

# Mem/Disk cached meter (Sapphire -> Lavender)
theme[cached_start]="$BLUE"
theme[cached_mid]="$MAGENTA"
theme[cached_end]="$MAGENTA"

# Mem/Disk available meter (Peach -> Red)
theme[available_start]="$YELLOW"
theme[available_mid]="$YELLOW"
theme[available_end]="$RED"

# Mem/Disk used meter (Green -> Sky)
theme[used_start]="$GREEN"
theme[used_mid]="$GREEN"
theme[used_end]="$CYAN"

# Download graph colors (Peach -> Red)
theme[download_start]="$YELLOW"
theme[download_mid]="$YELLOW"
theme[download_end]="$RED"

# Upload graph colors (Green -> Sky)
theme[upload_start]="$GREEN"
theme[upload_mid]="$GREEN"
theme[upload_end]="$CYAN"

# Process box color gradient for threads, mem and cpu usage (Sapphire -> Mauve)
theme[process_start]="$BLUE"
theme[process_mid]="$MAGENTA"
theme[process_end]="$MAGENTA"
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

# Generate colors.conf for GTK theme generation
echo "→ Generating colors.conf for GTK themes"
cat > "$OUTPUT_DIR/colors.conf" << EOF
# Auto-generated from $SCHEME_FILE
background="$BG_COLOR"
foreground="$FG_COLOR"

color0="$BLACK"
color1="$RED"
color2="$GREEN"
color3="$YELLOW"
color4="$BLUE"
color5="$MAGENTA"
color6="$CYAN"
color7="$WHITE"

color8="$BLACK"
color9="$RED"
color10="$GREEN"
color11="$YELLOW"
color12="$BLUE"
color13="$MAGENTA"
color14="$CYAN"
color15="$WHITE"
EOF

echo ""
echo "✓ Theme generated successfully!"
echo "Location: $OUTPUT_DIR"
echo ""
echo "To use:"
echo "  ln -sf $OUTPUT_DIR ~/.config/omarchy/themes/$THEME_NAME"
echo "  omarchy-theme-set $THEME_NAME"
