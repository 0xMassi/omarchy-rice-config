#!/bin/bash
# Advanced Menu

OPTIONS=" Edit Hyprland Config
 Edit Waybar Config
 Edit Mako Config
 Edit Fuzzel Config
 Reload All Services
 System Info
 Backup Everything
 Restore Backup
 Reset to Defaults
 Back to Main Menu"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt="⚙️ Advanced: " --lines=10)

case "$selected" in
    *"Edit Hyprland Config")
        CONFIG_FILES=" bindings.conf
 hyprland.conf
 autostart.conf
 input.conf"
        
        CONFIG=$(echo "$CONFIG_FILES" | fuzzel --dmenu --prompt=" Select Config: ")
        
        if [ -n "$CONFIG" ]; then
            CONFIG_NAME=$(echo "$CONFIG" | xargs)
            alacritty -e nvim ~/.config/hypr/$CONFIG_NAME
        fi
        ;;
    *"Edit Waybar Config")
        WAYBAR_FILES=" config.jsonc
 style.css"
        
        FILE=$(echo "$WAYBAR_FILES" | fuzzel --dmenu --prompt=" Select File: ")
        
        if [ -n "$FILE" ]; then
            FILE_NAME=$(echo "$FILE" | xargs)
            alacritty -e nvim ~/.config/waybar/$FILE_NAME
        fi
        ;;
    *"Edit Mako Config")
        alacritty -e nvim ~/.config/mako/config
        ;;
    *"Edit Fuzzel Config")
        FUZZEL_FILES=" fuzzel.ini
 fuzzel.theme.ini"
        
        FILE=$(echo "$FUZZEL_FILES" | fuzzel --dmenu --prompt=" Select File: ")
        
        if [ -n "$FILE" ]; then
            FILE_NAME=$(echo "$FILE" | xargs)
            alacritty -e nvim ~/.config/fuzzel/$FILE_NAME
        fi
        ;;
    *"Reload All Services")
        notify-send "Reloading" "Reloading all services..."
        hyprctl reload
        killall waybar; sleep 0.5; waybar &
        makoctl reload
        notify-send "Reload Complete" "All services reloaded"
        ;;
    *"System Info")
        INFO="Hyprland: $(hyprctl version | head -1)
Waybar: $(waybar --version 2>&1 | head -1)
Kernel: $(uname -r)
Theme: $(gsettings get org.gnome.desktop.interface gtk-theme)
Icons: $(gsettings get org.gnome.desktop.interface icon-theme)"
        
        notify-send "System Info" "$INFO"
        ;;
    *"Backup Everything")
        ~/.config/rice-menu/themes/menu.sh
        ;;
    *"Restore Backup")
        ~/.config/rice-menu/themes/menu.sh
        ;;
    *"Reset to Defaults")
        CONFIRM=$(echo -e "Yes\nNo" | fuzzel --dmenu --prompt="⚠️ Reset everything to defaults? ")
        
        if [ "$CONFIRM" = "Yes" ]; then
            notify-send "Resetting" "This would reset all configs to Omarchy defaults"
        fi
        ;;
    *"Back to Main Menu")
        ~/.config/rice-menu/rice-control.sh
        ;;
esac
