#!/bin/bash
# Appearance Menu

OPTIONS=" Change Icon Theme
 Change GTK Theme
 Change Cursor Theme
 Font Settings
 Window Borders
 Window Gaps
 Back to Main Menu"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt=" Appearance: " --lines=7)

case "$selected" in
    *"Change Icon Theme")
        # List available icon themes
        ICONS=$(ls /usr/share/icons/ | grep -v "default\|hicolor\|locolor" | sed 's/^/ /')
        CURRENT=$(gsettings get org.gnome.desktop.interface icon-theme | tr -d "'")
        SELECTED_ICON=$(echo "$ICONS" | fuzzel --dmenu --prompt=" Current: $CURRENT | Select Icon Theme: ")
        
        if [ -n "$SELECTED_ICON" ]; then
            ICON_NAME=$(echo "$SELECTED_ICON" | xargs)
            gsettings set org.gnome.desktop.interface icon-theme "$ICON_NAME"
            sed -i "s/^gtk-icon-theme-name=.*/gtk-icon-theme-name=$ICON_NAME/" ~/.config/gtk-3.0/settings.ini
            sed -i "s/^gtk-icon-theme-name=.*/gtk-icon-theme-name=$ICON_NAME/" ~/.config/gtk-4.0/settings.ini
            notify-send "Icon Theme" "Changed to $ICON_NAME"
        fi
        ;;
    *"Change GTK Theme")
        THEMES=$(ls /usr/share/themes/ | sed 's/^/ /')
        CURRENT=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")
        SELECTED_THEME=$(echo "$THEMES" | fuzzel --dmenu --prompt=" Current: $CURRENT | Select GTK Theme: ")
        
        if [ -n "$SELECTED_THEME" ]; then
            THEME_NAME=$(echo "$SELECTED_THEME" | xargs)
            gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME"
            sed -i "s/^gtk-theme-name=.*/gtk-theme-name=$THEME_NAME/" ~/.config/gtk-3.0/settings.ini
            sed -i "s/^gtk-theme-name=.*/gtk-theme-name=$THEME_NAME/" ~/.config/gtk-4.0/settings.ini
            notify-send "GTK Theme" "Changed to $THEME_NAME"
        fi
        ;;
    *"Change Cursor Theme")
        CURSORS=$(ls /usr/share/icons/ | grep -i cursor | sed 's/^/ /')
        CURRENT=$(gsettings get org.gnome.desktop.interface cursor-theme | tr -d "'")
        SELECTED_CURSOR=$(echo "$CURSORS" | fuzzel --dmenu --prompt=" Current: $CURRENT | Select Cursor: ")
        
        if [ -n "$SELECTED_CURSOR" ]; then
            CURSOR_NAME=$(echo "$SELECTED_CURSOR" | xargs)
            gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_NAME"
            hyprctl setcursor "$CURSOR_NAME" 24
            notify-send "Cursor Theme" "Changed to $CURSOR_NAME"
        fi
        ;;
    *"Font Settings")
        FONTS="Liberation Sans 11
Noto Sans 11
CaskaydiaMono Nerd Font 11
DejaVu Sans 11"
        SELECTED_FONT=$(echo "$FONTS" | fuzzel --dmenu --prompt=" Select Font: ")
        
        if [ -n "$SELECTED_FONT" ]; then
            gsettings set org.gnome.desktop.interface font-name "$SELECTED_FONT"
            sed -i "s/^gtk-font-name=.*/gtk-font-name=$SELECTED_FONT/" ~/.config/gtk-3.0/settings.ini
            sed -i "s/^gtk-font-name=.*/gtk-font-name=$SELECTED_FONT/" ~/.config/gtk-4.0/settings.ini
            notify-send "Font" "Changed to $SELECTED_FONT"
        fi
        ;;
    *"Window Borders")
        BORDER_SIZE="0
1
2
3
4
5"
        SELECTED=$(echo "$BORDER_SIZE" | fuzzel --dmenu --prompt=" Border Size (pixels): ")
        
        if [ -n "$SELECTED" ]; then
            # This would need to update Hyprland config
            notify-send "Window Borders" "Border size: $SELECTED px (requires Hyprland config update)"
        fi
        ;;
    *"Window Gaps")
        GAP_SIZE="0
5
10
15
20"
        SELECTED=$(echo "$GAP_SIZE" | fuzzel --dmenu --prompt=" Gap Size (pixels): ")
        
        if [ -n "$SELECTED" ]; then
            # This would need to update Hyprland config
            notify-send "Window Gaps" "Gap size: $SELECTED px (requires Hyprland config update)"
        fi
        ;;
    *"Back to Main Menu")
        ~/.config/rice-menu/rice-control.sh
        ;;
esac
