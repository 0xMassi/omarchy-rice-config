#!/bin/bash
# Generate Omarchy theme from wallpaper using Matugen

WALLPAPER="$1"
THEME_NAME="$2"

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    echo "Usage: generate-from-wallpaper.sh <wallpaper-path> [theme-name]"
    exit 1
fi

if [ -z "$THEME_NAME" ]; then
    THEME_NAME="wallpaper-$(basename "$WALLPAPER" | sed 's/\.[^.]*$//' | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
fi

# Check if wal (pywal) is installed
WAL_CMD="$HOME/.local/bin/wal"
if [ ! -f "$WAL_CMD" ] && ! command -v wal &> /dev/null; then
    echo "ERROR: pywal is not installed"
    echo "Install it with: pip3 install --user pywal"
    exit 1
fi

# Use full path if available, otherwise use command
if [ -f "$WAL_CMD" ]; then
    WAL="$WAL_CMD"
else
    WAL="wal"
fi

OUTPUT_DIR="$HOME/.local/share/omarchy/themes/$THEME_NAME"

echo "Generating Omarchy theme from wallpaper"
echo "Source: $WALLPAPER"
echo "Theme: $THEME_NAME"
echo "Output: $OUTPUT_DIR"
echo ""

mkdir -p "$OUTPUT_DIR/backgrounds"

# Copy wallpaper to theme backgrounds preserving quality
# Detect original format and preserve it
WALLPAPER_EXT="${WALLPAPER##*.}"
WALLPAPER_EXT_LOWER=$(echo "$WALLPAPER_EXT" | tr '[:upper:]' '[:lower:]')

# Use magick to ensure quality preservation and proper format
if [[ "$WALLPAPER_EXT_LOWER" == "png" ]]; then
    magick "$WALLPAPER" -quality 100 "$OUTPUT_DIR/backgrounds/default.png"
else
    # For JPEG/JPG, use quality 100 to minimize compression
    magick "$WALLPAPER" -quality 100 "$OUTPUT_DIR/backgrounds/default.jpg"
fi

# Generate color scheme with pywal
echo "→ Extracting colors with Pywal"
$WAL -i "$WALLPAPER" -n -q

# Read colors from pywal cache
PYWAL_COLORS="$HOME/.cache/wal/colors"

if [ ! -f "$PYWAL_COLORS" ]; then
    echo "ERROR: Failed to extract colors from wallpaper"
    exit 1
fi

# Parse colors from pywal output (16 color palette)
BG_COLOR=$(sed -n '1p' "$PYWAL_COLORS")
FG_COLOR=$(sed -n '16p' "$PYWAL_COLORS")
BLACK=$(sed -n '1p' "$PYWAL_COLORS")
RED=$(sed -n '2p' "$PYWAL_COLORS")
GREEN=$(sed -n '3p' "$PYWAL_COLORS")
YELLOW=$(sed -n '4p' "$PYWAL_COLORS")
BLUE=$(sed -n '5p' "$PYWAL_COLORS")
MAGENTA=$(sed -n '6p' "$PYWAL_COLORS")
CYAN=$(sed -n '7p' "$PYWAL_COLORS")
WHITE=$(sed -n '8p' "$PYWAL_COLORS")
ACCENT_COLOR=$(sed -n '2p' "$PYWAL_COLORS")  # Use red as accent

echo "Extracted colors:"
echo "  Background: $BG_COLOR"
echo "  Foreground: $FG_COLOR"
echo "  Accent: $ACCENT_COLOR"
echo ""

# Generate alacritty.toml
echo "→ Generating alacritty.toml"
cat > "$OUTPUT_DIR/alacritty.toml" << EOF
[colors.primary]
background = "$BG_COLOR"
foreground = "$FG_COLOR"

[colors.cursor]
cursor = "$ACCENT_COLOR"
text = "$BG_COLOR"

[colors.normal]
black = "$BLACK"
red = "$RED"
green = "$GREEN"
yellow = "$YELLOW"
blue = "$BLUE"
magenta = "$MAGENTA"
cyan = "$CYAN"
white = "$WHITE"

[colors.bright]
black = "$BLACK"
red = "$RED"
green = "$GREEN"
yellow = "$YELLOW"
blue = "$BLUE"
magenta = "$MAGENTA"
cyan = "$CYAN"
white = "$WHITE"
EOF

# Generate kitty.conf
echo "→ Generating kitty.conf"
cat > "$OUTPUT_DIR/kitty.conf" << EOF
foreground $FG_COLOR
background $BG_COLOR
cursor $ACCENT_COLOR
color0 $BLACK
color1 $RED
color2 $GREEN
color3 $YELLOW
color4 $BLUE
color5 $MAGENTA
color6 $CYAN
color7 $WHITE
color8 $BLACK
color9 $RED
color10 $GREEN
color11 $YELLOW
color12 $BLUE
color13 $MAGENTA
color14 $CYAN
color15 $WHITE
EOF

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
cat > "$OUTPUT_DIR/btop.theme" << EOF
theme[main_bg]="$BG_COLOR"
theme[main_fg]="$FG_COLOR"
theme[title]="$FG_COLOR"
theme[hi_fg]="$ACCENT_COLOR"
theme[selected_bg]="$ACCENT_COLOR"
theme[selected_fg]="$BG_COLOR"
theme[inactive_fg]="$WHITE"
theme[proc_misc]="$CYAN"
theme[cpu_box]="$ACCENT_COLOR"
theme[mem_box]="$GREEN"
theme[net_box]="$MAGENTA"
theme[proc_box]="$BLUE"
theme[div_line]="$FG_COLOR"
theme[temp_start]="$GREEN"
theme[temp_mid]="$YELLOW"
theme[temp_end]="$RED"
theme[cpu_start]="$GREEN"
theme[cpu_mid]="$YELLOW"
theme[cpu_end]="$RED"
theme[free_start]="$GREEN"
theme[free_mid]="$YELLOW"
theme[free_end]="$RED"
theme[cached_start]="$GREEN"
theme[cached_mid]="$YELLOW"
theme[cached_end]="$RED"
theme[available_start]="$GREEN"
theme[available_mid]="$YELLOW"
theme[available_end]="$RED"
theme[used_start]="$GREEN"
theme[used_mid]="$YELLOW"
theme[used_end]="$RED"
theme[download_start]="$GREEN"
theme[download_mid]="$YELLOW"
theme[download_end]="$RED"
theme[upload_start]="$GREEN"
theme[upload_mid]="$YELLOW"
theme[upload_end]="$RED"
EOF

# Generate theme.info
echo "→ Generating theme.info"
cat > "$OUTPUT_DIR/theme.info" << EOF
name=$THEME_NAME
source=$WALLPAPER
type=wallpaper
generated=$(date +%Y-%m-%d)
EOF

echo ""
echo "✓ Theme generated successfully!"
echo ""
echo "To activate this theme, run:"
echo "  omarchy-theme-set $THEME_NAME"
