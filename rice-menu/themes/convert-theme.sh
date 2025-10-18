#!/bin/bash
# Omarchy Theme Converter - Convert dotfiles to Omarchy format

DOTFILES_DIR="$1"
THEME_NAME="$2"
OUTPUT_DIR="$HOME/.local/share/omarchy/themes/$THEME_NAME"

if [ -z "$DOTFILES_DIR" ] || [ -z "$THEME_NAME" ]; then
    echo "Usage: convert-theme.sh <dotfiles-dir> <theme-name>"
    exit 1
fi

echo "Converting dotfiles to Omarchy theme: $THEME_NAME"
echo "Source: $DOTFILES_DIR"
echo "Output: $OUTPUT_DIR"
echo ""

mkdir -p "$OUTPUT_DIR/backgrounds"

# Color extraction function
extract_colors() {
    local file="$1"
    
    # Extract common color formats
    grep -oE '#[0-9a-fA-F]{6,8}' "$file" | head -20
}

# Find config files in dotfiles
find_config() {
    local pattern="$1"
    find "$DOTFILES_DIR" -name "$pattern" 2>/dev/null | head -1
}

echo "Step 1: Searching for configuration files..."

# Find Hyprland config (but don't copy full config, just extract colors)
HYPR_CONF=$(find_config "hyprland.conf")
if [ -n "$HYPR_CONF" ]; then
    echo "  ✓ Found Hyprland config (will extract colors)"
fi

# Find Waybar configs for color extraction (don't copy directly)
WAYBAR_CONFIG=$(find_config "config.jsonc") || WAYBAR_CONFIG=$(find_config "config")
WAYBAR_STYLE=$(find_config "style.css")
WAYBAR_THEME=$(find "$DOTFILES_DIR" -path "*/waybar/theme.css" 2>/dev/null | head -1)
if [ -n "$WAYBAR_STYLE" ]; then
    echo "  ✓ Found Waybar style (will extract colors)"
fi
if [ -n "$WAYBAR_THEME" ]; then
    echo "  ✓ Found Waybar theme.css (will extract colors)"
fi

# Find Alacritty config
ALACRITTY_CONF=$(find_config "alacritty.toml") || ALACRITTY_CONF=$(find_config "alacritty.yml")
if [ -n "$ALACRITTY_CONF" ]; then
    echo "  ✓ Found Alacritty config"
    cp "$ALACRITTY_CONF" "$OUTPUT_DIR/alacritty.toml"
fi

# Find Kitty config
KITTY_CONF=$(find_config "kitty.conf")
if [ -n "$KITTY_CONF" ]; then
    echo "  ✓ Found Kitty config"
    cp "$KITTY_CONF" "$OUTPUT_DIR/kitty.conf"
fi

# Find Hyprlock config
HYPRLOCK_CONF=$(find_config "hyprlock.conf")
if [ -n "$HYPRLOCK_CONF" ]; then
    echo "  ✓ Found Hyprlock config"
    cp "$HYPRLOCK_CONF" "$OUTPUT_DIR/hyprlock.conf"
fi

# Find wallpapers
WALLPAPERS=$(find "$DOTFILES_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) 2>/dev/null | head -5)
if [ -n "$WALLPAPERS" ]; then
    echo "  ✓ Found wallpapers"
    echo "$WALLPAPERS" | while read -r wallpaper; do
        cp "$wallpaper" "$OUTPUT_DIR/backgrounds/"
    done
fi

echo ""
echo "Step 2: Generating missing Omarchy configs..."

# Extract colors from found configs (prioritize theme.css)
COLORS=()
if [ -n "$WAYBAR_THEME" ] && [ -f "$WAYBAR_THEME" ]; then
    COLORS+=($(extract_colors "$WAYBAR_THEME"))
fi
if [ -n "$WAYBAR_STYLE" ] && [ -f "$WAYBAR_STYLE" ]; then
    COLORS+=($(extract_colors "$WAYBAR_STYLE"))
fi
if [ -n "$HYPR_CONF" ] && [ -f "$HYPR_CONF" ]; then
    COLORS+=($(extract_colors "$HYPR_CONF"))
fi
if [ -n "$ALACRITTY_CONF" ] && [ -f "$ALACRITTY_CONF" ]; then
    COLORS+=($(extract_colors "$ALACRITTY_CONF"))
fi

# Get unique colors
UNIQUE_COLORS=($(printf '%s\n' "${COLORS[@]}" | sort -u | head -10))

# Smart color detection: find dark backgrounds and light text
BG_COLOR="#1e1e2e"
TEXT_COLOR="#cdd6f4"
ACCENT_COLOR="#89dceb"

# Try to find a dark background (low RGB values)
for color in "${UNIQUE_COLORS[@]}"; do
    # Remove # and convert to decimal
    r=$((16#${color:1:2}))
    g=$((16#${color:3:2}))
    b=$((16#${color:5:2}))
    brightness=$(( (r + g + b) / 3 ))

    if [ $brightness -lt 50 ]; then
        BG_COLOR="$color"
        break
    fi
done

# Try to find a light text color (high RGB values)
for color in "${UNIQUE_COLORS[@]}"; do
    r=$((16#${color:1:2}))
    g=$((16#${color:3:2}))
    b=$((16#${color:5:2}))
    brightness=$(( (r + g + b) / 3 ))

    if [ $brightness -gt 180 ]; then
        TEXT_COLOR="$color"
        break
    fi
done

# Find accent color (vibrant, medium brightness)
for color in "${UNIQUE_COLORS[@]}"; do
    if [ "$color" != "$BG_COLOR" ] && [ "$color" != "$TEXT_COLOR" ]; then
        r=$((16#${color:1:2}))
        g=$((16#${color:3:2}))
        b=$((16#${color:5:2}))
        brightness=$(( (r + g + b) / 3 ))

        if [ $brightness -gt 80 ] && [ $brightness -lt 180 ]; then
            ACCENT_COLOR="$color"
            break
        fi
    fi
done

BORDER_COLOR="$ACCENT_COLOR"

echo "  Extracted colors:"
echo "    Background: $BG_COLOR"
echo "    Text: $TEXT_COLOR"
echo "    Accent: $ACCENT_COLOR"
echo "    Border: $BORDER_COLOR"

# Find matching color scheme from iTerm2-Color-Schemes library
SCHEME_DIR="$HOME/.config/rice-menu/color-schemes"
MATCHED_SCHEME=""

if [ -d "$SCHEME_DIR/alacritty" ]; then
    echo "  → Searching for matching color scheme..."

    # Calculate color distance (simple RGB difference)
    color_distance() {
        local c1="$1"  # #rrggbb
        local c2="$2"  # #rrggbb

        r1=$((16#${c1:1:2}))
        g1=$((16#${c1:3:2}))
        b1=$((16#${c1:5:2}))

        r2=$((16#${c2:1:2}))
        g2=$((16#${c2:3:2}))
        b2=$((16#${c2:5:2}))

        dr=$(( (r1 - r2) * (r1 - r2) ))
        dg=$(( (g1 - g2) * (g1 - g2) ))
        db=$(( (b1 - b2) * (b1 - b2) ))

        echo $(( dr + dg + db ))
    }

    # Search for best matching scheme
    best_distance=999999
    for scheme in "$SCHEME_DIR/alacritty"/*.toml; do
        scheme_bg=$(grep "^background = " "$scheme" | head -1 | grep -oE '#[0-9a-fA-F]{6}')
        scheme_fg=$(grep "^foreground = " "$scheme" | head -1 | grep -oE '#[0-9a-fA-F]{6}')

        if [ -n "$scheme_bg" ] && [ -n "$scheme_fg" ]; then
            bg_dist=$(color_distance "$BG_COLOR" "$scheme_bg")
            fg_dist=$(color_distance "$TEXT_COLOR" "$scheme_fg")
            total_dist=$(( bg_dist + fg_dist ))

            if [ $total_dist -lt $best_distance ]; then
                best_distance=$total_dist
                MATCHED_SCHEME="$scheme"
            fi
        fi
    done

    if [ -n "$MATCHED_SCHEME" ]; then
        scheme_name=$(basename "$MATCHED_SCHEME" .toml)
        echo "    ✓ Matched color scheme: $scheme_name (distance: $best_distance)"
    fi
fi

# Generate Fuzzel config
if [ ! -f "$OUTPUT_DIR/fuzzel.ini" ]; then
    echo "  → Generating fuzzel.ini"
    cat > "$OUTPUT_DIR/fuzzel.ini" << FUZZELEOF
[colors]
background=${BG_COLOR}f9
prompt=${TEXT_COLOR}ff
input=${TEXT_COLOR}ff
text=${TEXT_COLOR}ff
match=${TEXT_COLOR}ff
selection-match=${ACCENT_COLOR}ff
selection=00000000
selection-text=${ACCENT_COLOR}ff
border=${BORDER_COLOR}ff
FUZZELEOF
fi

# Generate Mako config
if [ ! -f "$OUTPUT_DIR/mako.ini" ]; then
    echo "  → Generating mako.ini"
    cat > "$OUTPUT_DIR/mako.ini" << MAKOEOF
include=~/.local/share/omarchy/default/mako/core.ini

text-color=${TEXT_COLOR}
border-color=${BORDER_COLOR}
background-color=${BG_COLOR}
padding=10
border-size=2
font=Liberation Sans 11
max-icon-size=32
outer-margin=20
MAKOEOF
fi

# Always generate Omarchy-compatible Waybar CSS
echo "  → Generating Omarchy-compatible waybar.css"
cat > "$OUTPUT_DIR/waybar.css" << WAYBAREOF
@define-color foreground $TEXT_COLOR;
@define-color background $BG_COLOR;
WAYBAREOF

# Generate Alacritty terminal theme if missing
if [ ! -f "$OUTPUT_DIR/alacritty.toml" ]; then
    if [ -n "$MATCHED_SCHEME" ] && [ -f "$MATCHED_SCHEME" ]; then
        echo "  → Using matched alacritty color scheme"
        cp "$MATCHED_SCHEME" "$OUTPUT_DIR/alacritty.toml"
    else
        echo "  → Generating alacritty.toml with basic colors"
        cat > "$OUTPUT_DIR/alacritty.toml" << ALACRITTYEOF
[colors.primary]
background = "$BG_COLOR"
foreground = "$TEXT_COLOR"

[colors.cursor]
text = "$BG_COLOR"
cursor = "$ACCENT_COLOR"

[colors.selection]
text = "$BG_COLOR"
background = "$ACCENT_COLOR"

[colors.normal]
black = "#2e3440"
red = "#bf616a"
green = "#a3be8c"
yellow = "#ebcb8b"
blue = "#81a1c1"
magenta = "#b48ead"
cyan = "#88c0d0"
white = "#e5e9f0"

[colors.bright]
black = "#4c566a"
red = "#bf616a"
green = "#a3be8c"
yellow = "#ebcb8b"
blue = "#81a1c1"
magenta = "#b48ead"
cyan = "#8fbcbb"
white = "#eceff4"
ALACRITTYEOF
    fi
fi

# Generate Kitty terminal theme if missing
if [ ! -f "$OUTPUT_DIR/kitty.conf" ]; then
    if [ -n "$MATCHED_SCHEME" ]; then
        # Try to find corresponding kitty scheme
        scheme_name=$(basename "$MATCHED_SCHEME" .toml)
        kitty_scheme="$SCHEME_DIR/kitty/${scheme_name}.conf"

        if [ -f "$kitty_scheme" ]; then
            echo "  → Using matched kitty color scheme"
            cp "$kitty_scheme" "$OUTPUT_DIR/kitty.conf"
        else
            echo "  → Generating kitty.conf with basic colors"
            cat > "$OUTPUT_DIR/kitty.conf" << KITTYEOF
foreground $TEXT_COLOR
background $BG_COLOR
selection_foreground $BG_COLOR
selection_background $ACCENT_COLOR
cursor $ACCENT_COLOR
cursor_text_color $BG_COLOR
KITTYEOF
        fi
    else
        echo "  → Generating kitty.conf with basic colors"
        cat > "$OUTPUT_DIR/kitty.conf" << KITTYEOF
foreground $TEXT_COLOR
background $BG_COLOR
selection_foreground $BG_COLOR
selection_background $ACCENT_COLOR
cursor $ACCENT_COLOR
cursor_text_color $BG_COLOR
KITTYEOF
    fi
fi

# Always generate Omarchy-compatible Hyprland config (just border color)
echo "  → Generating hyprland.conf with border colors"
# Remove # from colors for Hyprland rgb() format
ACCENT_RGB=$(echo "$ACCENT_COLOR" | sed 's/#//')
cat > "$OUTPUT_DIR/hyprland.conf" << HYPREOF
general {
    col.active_border = rgb($ACCENT_RGB)
}
HYPREOF

# Generate theme info
cat > "$OUTPUT_DIR/theme.info" << INFOEOF
name=$THEME_NAME
source=$DOTFILES_DIR
converted=$(date +%Y-%m-%d)
colors_bg=$BG_COLOR
colors_text=$TEXT_COLOR
colors_accent=$ACCENT_COLOR
colors_border=$BORDER_COLOR
INFOEOF

echo ""
echo "Step 3: Validating theme..."

MISSING=()
[ ! -f "$OUTPUT_DIR/fuzzel.ini" ] && MISSING+=("fuzzel.ini")
[ ! -f "$OUTPUT_DIR/mako.ini" ] && MISSING+=("mako.ini")
[ ! -f "$OUTPUT_DIR/waybar.css" ] && MISSING+=("waybar.css")

if [ ${#MISSING[@]} -eq 0 ]; then
    echo "  ✓ Theme is Omarchy-compatible!"
    echo ""
    echo "Theme converted successfully!"
    echo "Location: $OUTPUT_DIR"
    echo ""
    echo "To use this theme:"
    echo "  1. ln -sf $OUTPUT_DIR ~/.config/omarchy/themes/$THEME_NAME"
    echo "  2. omarchy-theme-set $THEME_NAME"
    exit 0
else
    echo "  ⚠ Warning: Missing files: ${MISSING[*]}"
    echo "  Theme may need manual adjustments"
    exit 1
fi
