#!/bin/bash
# Rice Control Center - Main Menu

MENU_DIR="$HOME/.config/rice-menu"

OPTIONS="Appearance
Themes
Profiles
Fonts
Icons
Colors
Wallpapers
Waybar
Notifications
Advanced"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt=" Rice Control: " --lines=10)

case "$selected" in
    *Appearance)
        "$MENU_DIR/appearance/menu.sh"
        ;;
    *Themes)
        "$MENU_DIR/themes/menu.sh"
        ;;
    *Profiles)
        "$MENU_DIR/profiles/menu.sh"
        ;;
    *Fonts)
        "$MENU_DIR/fonts/menu.sh"
        ;;
    *Icons)
        "$MENU_DIR/icons/menu.sh"
        ;;
    *Colors)
        "$MENU_DIR/colors/menu.sh"
        ;;
    *Wallpapers)
        "$MENU_DIR/wallpapers/menu.sh"
        ;;
    *Waybar)
        "$MENU_DIR/waybar/menu.sh"
        ;;
    *Notifications)
        "$MENU_DIR/notifications/menu.sh"
        ;;
    *Advanced)
        "$MENU_DIR/advanced/menu.sh"
        ;;
esac
