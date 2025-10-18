#!/bin/bash
# Icons Menu

OPTIONS=" Switch Icon Theme
 Download Papirus Folders (Colors)
 Install Tela Icons
 Install Flatery Icons
 Preview Current Icons
 Back to Main Menu"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt=" Icons: " --lines=6)

case "$selected" in
    *"Switch Icon Theme")
        ~/.config/rice-menu/appearance/menu.sh
        ;;
    *"Download Papirus Folders (Colors)")
        notify-send "Downloading" "Installing papirus-folders-git..."
        alacritty -e bash -c "yay -S --noconfirm papirus-folders-git && papirus-folders -l && read -p 'Press enter to continue'"
        ;;
    *"Install Tela Icons")
        notify-send "Downloading" "Installing Tela icon theme..."
        alacritty -e bash -c "yay -S --noconfirm tela-icon-theme && notify-send 'Installed' 'Tela icons installed' && read -p 'Press enter to continue'"
        ;;
    *"Install Flatery Icons")
        notify-send "Info" "Flatery must be installed manually from GitHub"
        ;;
    *"Preview Current Icons")
        CURRENT=$(gsettings get org.gnome.desktop.interface icon-theme | tr -d "'")
        notify-send "Current Icon Theme" "$CURRENT"
        nautilus /usr/share/icons/$CURRENT &
        ;;
    *"Back to Main Menu")
        ~/.config/rice-menu/rice-control.sh
        ;;
esac
