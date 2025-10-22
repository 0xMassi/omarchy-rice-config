#!/bin/bash
# GTK Theme Tester - Test GTK3/GTK4 theme application
# This script opens various GTK dialogs to visually test your theme

THEME_NAME="${1:-test-theme}"

echo "Testing GTK Theme: $THEME_NAME"
echo "================================"
echo ""

# Check if theme files exist
echo "1. Checking theme files..."
if [ -f "$HOME/.themes/$THEME_NAME/gtk-3.0/gtk.css" ]; then
    echo "   ✓ GTK3 theme found: ~/.themes/$THEME_NAME/gtk-3.0/gtk.css"
else
    echo "   ✗ GTK3 theme NOT found"
fi

if [ -f "$HOME/.config/gtk-4.0/gtk.css" ]; then
    echo "   ✓ GTK4 theme found: ~/.config/gtk-4.0/gtk.css"
else
    echo "   ✗ GTK4 theme NOT found"
fi

echo ""
echo "2. Current GTK settings:"
echo "   GTK3 Theme: $(grep gtk-theme-name ~/.config/gtk-3.0/settings.ini 2>/dev/null | cut -d'=' -f2)"
if command -v gsettings &>/dev/null; then
    echo "   GSettings Theme: $(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null)"
fi

echo ""
echo "3. Opening test dialogs..."
echo "   (Close each dialog to continue to the next test)"
echo ""

# Test 1: Simple info dialog
echo "   Test 1: Info dialog with buttons..."
zenity --info \
    --title="GTK Theme Test - Info" \
    --text="This is an INFO dialog.\nCheck the colors:\n• Background color\n• Text color\n• Button styling" \
    --width=400 2>/dev/null || echo "   (Closed)"

# Test 2: Question dialog
echo "   Test 2: Question dialog..."
zenity --question \
    --title="GTK Theme Test - Question" \
    --text="Does the theme look correct?\n\nCheck:\n• Window background\n• Button colors\n• Text readability" \
    --width=400 2>/dev/null
if [ $? -eq 0 ]; then
    echo "   ✓ User confirmed theme looks good!"
else
    echo "   ℹ User indicated theme needs adjustment"
fi

# Test 3: Warning dialog
echo "   Test 3: Warning dialog..."
zenity --warning \
    --title="GTK Theme Test - Warning" \
    --text="This is a WARNING dialog.\n\nWarning color should be visible (yellow/orange)" \
    --width=400 2>/dev/null || echo "   (Closed)"

# Test 4: Error dialog
echo "   Test 4: Error dialog..."
zenity --error \
    --title="GTK Theme Test - Error" \
    --text="This is an ERROR dialog.\n\nError color should be visible (red)" \
    --width=400 2>/dev/null || echo "   (Closed)"

# Test 5: Entry dialog
echo "   Test 5: Text entry dialog..."
ENTRY_RESULT=$(zenity --entry \
    --title="GTK Theme Test - Entry" \
    --text="Test text input field:\nType something and check:" \
    --entry-text="Test input styling" \
    --width=400 2>/dev/null)
echo "   Input: $ENTRY_RESULT"

# Test 6: List selection
echo "   Test 6: List selection dialog..."
zenity --list \
    --title="GTK Theme Test - List" \
    --text="Test list styling and selection colors:" \
    --column="Color" --column="HEX" \
    "Background" "#1a1b26" \
    "Foreground" "#c0caf5" \
    "Accent" "#7aa2f7" \
    "Warning" "#e0af68" \
    "Error" "#f7768e" \
    --width=400 --height=300 2>/dev/null || echo "   (Closed)"

# Test 7: Progress dialog
echo "   Test 7: Progress bar dialog..."
(
for i in {1..100}; do
    echo $i
    echo "# Testing progress bar styling ($i%)"
    sleep 0.02
done
) | zenity --progress \
    --title="GTK Theme Test - Progress" \
    --text="Check progress bar colors..." \
    --percentage=0 \
    --width=400 2>/dev/null || echo "   (Closed)"

# Test 8: File picker (if available)
if command -v nautilus &>/dev/null; then
    echo "   Test 8: Opening Nautilus file manager..."
    echo "   (This will test GTK3 theme in a real application)"
    echo "   Close Nautilus window to continue..."
    nautilus ~ 2>/dev/null &
    NAUTILUS_PID=$!
    echo "   Nautilus PID: $NAUTILUS_PID"
    echo "   (Nautilus opened - you can close it manually or press Enter to continue)"
    read -p "   Press Enter when done checking Nautilus... "
fi

echo ""
echo "================================"
echo "GTK Theme Testing Complete!"
echo ""
echo "What to check:"
echo "  • Did all dialogs use the correct background/foreground colors?"
echo "  • Were buttons styled with your theme colors?"
echo "  • Did selection/hover states show the accent color?"
echo "  • Were warning/error colors appropriate?"
echo "  • Was text readable and properly colored?"
echo ""
echo "Theme files location:"
echo "  GTK3: ~/.themes/$THEME_NAME/gtk-3.0/gtk.css"
echo "  GTK4: ~/.config/gtk-4.0/gtk.css"
echo ""
echo "To regenerate theme:"
echo "  ~/.config/rice-menu/themes/gtk/generate-gtk3.sh <theme-dir>"
echo "  ~/.config/rice-menu/themes/gtk/generate-gtk4.sh <theme-dir>"
echo ""
