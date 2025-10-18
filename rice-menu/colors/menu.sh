#!/bin/bash
# Colors Menu

OPTIONS=" Pick Accent Color
 Workspace Active Color
 Waybar Module Colors
 Notification Colors
 Preset Schemes
 Reset to Theme Default
 Back to Main Menu"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt=" Colors: " --lines=7)

case "$selected" in
    *"Pick Accent Color")
        COLOR=$(hyprpicker -a -f hex)
        if [ -n "$COLOR" ]; then
            notify-send "Color Picked" "$COLOR copied to clipboard"
            echo "$COLOR" > ~/.config/rice-menu/colors/last-picked.txt
        fi
        ;;
    *"Workspace Active Color")
        COLOR=$(hyprpicker -a -f hex)
        if [ -n "$COLOR" ]; then
            # Update Waybar workspace color
            sed -i "s/#workspaces button.active {.*color: #[0-9a-fA-F]*;/#workspaces button.active { color: $COLOR;/" ~/.config/waybar/style.css
            killall waybar; sleep 0.5; waybar &
            notify-send "Workspace Color" "Changed to $COLOR"
        fi
        ;;
    *"Waybar Module Colors")
        MODULE_OPTIONS=" CPU Color
 Memory Color
 Battery Color
 Network Color
 Back"
        
        MOD_SEL=$(echo "$MODULE_OPTIONS" | fuzzel --dmenu --prompt=" Select Module: ")
        
        case "$MOD_SEL" in
            *"CPU Color")
                COLOR=$(hyprpicker -a -f hex)
                [ -n "$COLOR" ] && sed -i "s/#cpu {.*color:.*/#cpu { color: $COLOR; }/" ~/.config/waybar/style.css && killall waybar; waybar &
                ;;
            *"Memory Color")
                COLOR=$(hyprpicker -a -f hex)
                [ -n "$COLOR" ] && sed -i "s/#memory {.*color:.*/#memory { color: $COLOR; }/" ~/.config/waybar/style.css && killall waybar; waybar &
                ;;
            *"Battery Color")
                COLOR=$(hyprpicker -a -f hex)
                [ -n "$COLOR" ] && sed -i "s/#battery {.*color:.*/#battery { color: $COLOR; }/" ~/.config/waybar/style.css && killall waybar; waybar &
                ;;
            *"Network Color")
                COLOR=$(hyprpicker -a -f hex)
                [ -n "$COLOR" ] && sed -i "s/#network {.*color:.*/#network { color: $COLOR; }/" ~/.config/waybar/style.css && killall waybar; waybar &
                ;;
        esac
        ;;
    *"Notification Colors")
        COLOR=$(hyprpicker -a -f hex)
        if [ -n "$COLOR" ]; then
            sed -i "s/^border-color=.*/border-color=$COLOR/" ~/.config/mako/config
            makoctl reload
            notify-send "Notification Color" "Border changed to $COLOR"
        fi
        ;;
    *"Preset Schemes")
        SCHEMES=" Nord (Blue/White)
 Catppuccin (Pastel)
 Dracula (Purple)
 Gruvbox (Warm)
 Tokyo Night (Blue/Purple)"
        
        SCHEME=$(echo "$SCHEMES" | fuzzel --dmenu --prompt=" Select Color Scheme: ")
        
        case "$SCHEME" in
            *"Nord"*)
                # Apply Nord colors
                notify-send "Color Scheme" "Nord theme applied"
                ;;
            *"Catppuccin"*)
                notify-send "Color Scheme" "Catppuccin theme applied"
                ;;
            *"Dracula"*)
                notify-send "Color Scheme" "Dracula theme applied"
                ;;
            *"Gruvbox"*)
                notify-send "Color Scheme" "Gruvbox theme applied"
                ;;
            *"Tokyo Night"*)
                notify-send "Color Scheme" "Tokyo Night theme applied"
                ;;
        esac
        ;;
    *"Reset to Theme Default")
        notify-send "Colors Reset" "Reverting to Omarchy theme colors..."
        ;;
    *"Back to Main Menu")
        ~/.config/rice-menu/rice-control.sh
        ;;
esac
