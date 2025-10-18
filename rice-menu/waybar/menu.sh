#!/bin/bash
# Waybar Menu

OPTIONS="Toggle Modules
Change Position
Change Height
Reload Waybar
Back to Main Menu"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt=" Waybar: " --lines=7)

case "$selected" in
    *"Toggle Modules")
        MODULES="custom/weather
custom/crypto
network
cpu
memory
battery
clock"

        MODULE=$(echo "$MODULES" | fuzzel --dmenu --prompt=" Toggle Module: ")

        if [ -n "$MODULE" ]; then
            TOGGLE_SCRIPT="$HOME/.config/rice-menu/waybar/toggle-module.sh"
            RESULT=$($TOGGLE_SCRIPT "$MODULE")

            killall waybar; sleep 0.5; waybar &

            if [ "$RESULT" = "enabled" ]; then
                notify-send "Waybar Module" "$MODULE enabled"
            else
                notify-send "Waybar Module" "$MODULE disabled"
            fi
        fi
        ;;
    *"Change Position")
        POSITIONS=" Top
 Bottom
 Left
 Right"
        
        POSITION=$(echo "$POSITIONS" | fuzzel --dmenu --prompt=" Select Position: ")
        
        if [ -n "$POSITION" ]; then
            POS_LOWER=$(echo "$POSITION" | xargs | tr '[:upper:]' '[:lower:]')
            sed -i "s/\"position\": \".*\"/\"position\": \"$POS_LOWER\"/" ~/.config/waybar/config.jsonc
            killall waybar; sleep 0.5; waybar &
            notify-send "Waybar Position" "Changed to $POS_LOWER"
        fi
        ;;
    *"Change Height")
        HEIGHTS="20
22
24
26
28
30
32"
        
        HEIGHT=$(echo "$HEIGHTS" | fuzzel --dmenu --prompt=" Select Height (px): ")
        
        if [ -n "$HEIGHT" ]; then
            sed -i "s/\"height\": [0-9]*/\"height\": $HEIGHT/" ~/.config/waybar/config.jsonc
            killall waybar; sleep 0.5; waybar &
            notify-send "Waybar Height" "Changed to ${HEIGHT}px"
        fi
        ;;
    *"Reload Waybar")
        killall waybar
        sleep 0.5
        waybar &
        notify-send "Waybar" "Reloaded"
        ;;
    *"Back to Main Menu")
        ~/.config/rice-menu/rice-control.sh
        ;;
esac
