#!/bin/bash
# Generate visual preview of a color scheme

SCHEME_FILE="$1"
PREVIEW_DIR="$HOME/.cache/rice-menu/previews"

if [ -z "$SCHEME_FILE" ] || [ ! -f "$SCHEME_FILE" ]; then
    echo "Usage: preview-theme.sh <scheme-file.toml>"
    exit 1
fi

mkdir -p "$PREVIEW_DIR"

# Extract theme name and colors
THEME_NAME=$(basename "$SCHEME_FILE" .toml)
PREVIEW_FILE="$PREVIEW_DIR/${THEME_NAME}.txt"

# Extract colors from scheme
BG=$(grep "^background = " "$SCHEME_FILE" | grep -oE '#[0-9a-fA-F]{6}' | head -1)
FG=$(grep "^foreground = " "$SCHEME_FILE" | grep -oE '#[0-9a-fA-F]{6}' | head -1)

# Extract ANSI colors from [colors.normal] section
BLACK=$(grep -A 20 '\[colors.normal\]' "$SCHEME_FILE" | grep "^black = " | grep -oE '#[0-9a-fA-F]{6}' | head -1)
RED=$(grep -A 20 '\[colors.normal\]' "$SCHEME_FILE" | grep "^red = " | grep -oE '#[0-9a-fA-F]{6}' | head -1)
GREEN=$(grep -A 20 '\[colors.normal\]' "$SCHEME_FILE" | grep "^green = " | grep -oE '#[0-9a-fA-F]{6}' | head -1)
YELLOW=$(grep -A 20 '\[colors.normal\]' "$SCHEME_FILE" | grep "^yellow = " | grep -oE '#[0-9a-fA-F]{6}' | head -1)
BLUE=$(grep -A 20 '\[colors.normal\]' "$SCHEME_FILE" | grep "^blue = " | grep -oE '#[0-9a-fA-F]{6}' | head -1)
MAGENTA=$(grep -A 20 '\[colors.normal\]' "$SCHEME_FILE" | grep "^magenta = " | grep -oE '#[0-9a-fA-F]{6}' | head -1)
CYAN=$(grep -A 20 '\[colors.normal\]' "$SCHEME_FILE" | grep "^cyan = " | grep -oE '#[0-9a-fA-F]{6}' | head -1)
WHITE=$(grep -A 20 '\[colors.normal\]' "$SCHEME_FILE" | grep "^white = " | grep -oE '#[0-9a-fA-F]{6}' | head -1)

# Create text-based preview
cat > "$PREVIEW_FILE" << EOF
$THEME_NAME

Colors:
  BG: $BG  FG: $FG

ANSI Palette:
  $RED  $GREEN  $YELLOW  $BLUE
  $MAGENTA  $CYAN  $BLACK  $WHITE
EOF

# Show preview in terminal using colored text
echo -e "\n\033[1m$THEME_NAME Preview:\033[0m"
echo ""
echo -e "Background: \033[48;2;$(printf '%d;%d;%d' 0x${BG:1:2} 0x${BG:3:2} 0x${BG:5:2})m    \033[0m $BG"
echo -e "Foreground: \033[38;2;$(printf '%d;%d;%d' 0x${FG:1:2} 0x${FG:3:2} 0x${FG:5:2})m████\033[0m $FG"
echo ""
echo "ANSI Colors:"
[ -n "$RED" ] && echo -e "  Red:     \033[38;2;$(printf '%d;%d;%d' 0x${RED:1:2} 0x${RED:3:2} 0x${RED:5:2})m████\033[0m $RED"
[ -n "$GREEN" ] && echo -e "  Green:   \033[38;2;$(printf '%d;%d;%d' 0x${GREEN:1:2} 0x${GREEN:3:2} 0x${GREEN:5:2})m████\033[0m $GREEN"
[ -n "$YELLOW" ] && echo -e "  Yellow:  \033[38;2;$(printf '%d;%d;%d' 0x${YELLOW:1:2} 0x${YELLOW:3:2} 0x${YELLOW:5:2})m████\033[0m $YELLOW"
[ -n "$BLUE" ] && echo -e "  Blue:    \033[38;2;$(printf '%d;%d;%d' 0x${BLUE:1:2} 0x${BLUE:3:2} 0x${BLUE:5:2})m████\033[0m $BLUE"
[ -n "$MAGENTA" ] && echo -e "  Magenta: \033[38;2;$(printf '%d;%d;%d' 0x${MAGENTA:1:2} 0x${MAGENTA:3:2} 0x${MAGENTA:5:2})m████\033[0m $MAGENTA"
[ -n "$CYAN" ] && echo -e "  Cyan:    \033[38;2;$(printf '%d;%d;%d' 0x${CYAN:1:2} 0x${CYAN:3:2} 0x${CYAN:5:2})m████\033[0m $CYAN"
echo ""
echo "Press Enter to continue..."
read
