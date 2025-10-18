#!/bin/bash
# Fonts Menu

# Get current font
CURRENT_FONT=$(gsettings get org.gnome.desktop.interface font-name 2>/dev/null || echo "Unknown")

OPTIONS="Switch Font
Browse Available Fonts
Install from Google Fonts
Set Terminal Font
Font Favorites
Back to Main Menu"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt=" Fonts: " --lines=6)

case "$selected" in
    *"Switch Font"*)
        # List installed fonts
        FONTS=$(fc-list : family | sort -u | head -50)

        SELECTED=$(echo "$FONTS" | fuzzel --dmenu --prompt=" Current: $CURRENT_FONT | Select: " --lines=15)

        if [ -n "$SELECTED" ]; then
            # Set GTK font in config files
            mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0

            # Update GTK3
            if [ -f ~/.config/gtk-3.0/settings.ini ]; then
                sed -i "s/^gtk-font-name=.*/gtk-font-name=$SELECTED 11/" ~/.config/gtk-3.0/settings.ini
            else
                echo -e "[Settings]\ngtk-font-name=$SELECTED 11" > ~/.config/gtk-3.0/settings.ini
            fi

            # Update GTK4
            if [ -f ~/.config/gtk-4.0/settings.ini ]; then
                sed -i "s/^gtk-font-name=.*/gtk-font-name=$SELECTED 11/" ~/.config/gtk-4.0/settings.ini
            else
                echo -e "[Settings]\ngtk-font-name=$SELECTED 11" > ~/.config/gtk-4.0/settings.ini
            fi

            # Also set via gsettings for running apps
            gsettings set org.gnome.desktop.interface font-name "$SELECTED 11"
            gsettings set org.gnome.desktop.wm.preferences titlebar-font "$SELECTED Bold 11"

            # Update Alacritty terminal font
            if [ -f ~/.config/alacritty/alacritty.toml ]; then
                sed -i "s/family = \".*\"/family = \"$SELECTED\"/" ~/.config/alacritty/alacritty.toml
            fi

            # Update Waybar font
            if [ -f ~/.config/waybar/style.css ]; then
                sed -i "s/font-family: .*/font-family: $SELECTED;/" ~/.config/waybar/style.css
                killall waybar; sleep 0.5; waybar &
            fi

            # Update Fuzzel menu font
            if [ -f ~/.config/fuzzel/fuzzel.ini ]; then
                sed -i "s/^font=.*/font=$SELECTED:size=10/" ~/.config/fuzzel/fuzzel.ini
            fi

            # Update Mako notifications font
            if [ -f ~/.config/omarchy/current/theme/mako.ini ]; then
                sed -i "s/^font=.*/font=$SELECTED 11/" ~/.config/omarchy/current/theme/mako.ini
                makoctl reload 2>/dev/null
            fi

            # Update SwayOSD font
            if [ -f ~/.config/swayosd/style.css ]; then
                sed -i "s/font-family: .*/font-family: '$SELECTED';/" ~/.config/swayosd/style.css
            fi

            # Update Hyprlock font
            if [ -f ~/.config/hypr/hyprlock.conf ]; then
                sed -i "s/font_family = .*/font_family = $SELECTED/" ~/.config/hypr/hyprlock.conf
            fi

            notify-send "Font Changed" "System font: $SELECTED\nAll UI components updated\nRestart other apps to see changes"
        fi
        ;;
    *"Browse Available Fonts"*)
        # Show all installed fonts with preview
        FONTS=$(fc-list : family | sort -u)
        FONT_COUNT=$(echo "$FONTS" | wc -l)

        SELECTED=$(echo "$FONTS" | fuzzel --dmenu --prompt=" Browse Fonts ($FONT_COUNT installed): " --lines=20)

        if [ -n "$SELECTED" ]; then
            # Preview font
            notify-send "Font Preview" "$SELECTED\nABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n0123456789"

            # Ask if user wants to apply
            APPLY=$(echo -e "Apply Font\nCancel" | fuzzel --dmenu --prompt=" Apply $SELECTED? ")

            if [[ "$APPLY" == "Apply"* ]]; then
                # Update config files
                mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
                sed -i "s/^gtk-font-name=.*/gtk-font-name=$SELECTED 11/" ~/.config/gtk-3.0/settings.ini 2>/dev/null || echo -e "[Settings]\ngtk-font-name=$SELECTED 11" > ~/.config/gtk-3.0/settings.ini
                sed -i "s/^gtk-font-name=.*/gtk-font-name=$SELECTED 11/" ~/.config/gtk-4.0/settings.ini 2>/dev/null || echo -e "[Settings]\ngtk-font-name=$SELECTED 11" > ~/.config/gtk-4.0/settings.ini

                # Set via gsettings
                gsettings set org.gnome.desktop.interface font-name "$SELECTED 11"
                gsettings set org.gnome.desktop.wm.preferences titlebar-font "$SELECTED Bold 11"

                # Update Alacritty terminal font
                if [ -f ~/.config/alacritty/alacritty.toml ]; then
                    sed -i "s/family = \".*\"/family = \"$SELECTED\"/" ~/.config/alacritty/alacritty.toml
                fi

                # Update Waybar font
                if [ -f ~/.config/waybar/style.css ]; then
                    sed -i "s/font-family: .*/font-family: $SELECTED;/" ~/.config/waybar/style.css
                    killall waybar; sleep 0.5; waybar &
                fi

                # Update Fuzzel menu font
                if [ -f ~/.config/fuzzel/fuzzel.ini ]; then
                    sed -i "s/^font=.*/font=$SELECTED:size=10/" ~/.config/fuzzel/fuzzel.ini
                fi

                # Update Mako notifications font
                if [ -f ~/.config/omarchy/current/theme/mako.ini ]; then
                    sed -i "s/^font=.*/font=$SELECTED 11/" ~/.config/omarchy/current/theme/mako.ini
                    makoctl reload 2>/dev/null
                fi

                # Update SwayOSD font
                if [ -f ~/.config/swayosd/style.css ]; then
                    sed -i "s/font-family: .*/font-family: '$SELECTED';/" ~/.config/swayosd/style.css
                fi

                # Update Hyprlock font
                if [ -f ~/.config/hypr/hyprlock.conf ]; then
                    sed -i "s/font_family = .*/font_family = $SELECTED/" ~/.config/hypr/hyprlock.conf
                fi

                notify-send "Font Applied" "$SELECTED\nAll UI components updated\nRestart other apps to see changes"
            fi
        fi
        ;;
    *"Install from Google Fonts"*)
        CATEGORIES="Sans Serif
Serif
Monospace
Display
Handwriting"

        CATEGORY=$(echo "$CATEGORIES" | fuzzel --dmenu --prompt=" Select Category: ")

        if [ -n "$CATEGORY" ]; then
            notify-send "Google Fonts" "Opening Google Fonts in browser...\nDownload and place in ~/.local/share/fonts/"

            CATEGORY_URL=$(echo "$CATEGORY" | tr '[:upper:]' '[:lower:]' | tr ' ' '+')
            xdg-open "https://fonts.google.com/?category=$CATEGORY_URL"
        fi
        ;;
    *"Set Terminal Font"*)
        # Get monospace fonts only
        MONO_FONTS=$(fc-list :spacing=100 family | sort -u)

        SELECTED=$(echo "$MONO_FONTS" | fuzzel --dmenu --prompt=" Terminal Font: " --lines=15)

        if [ -n "$SELECTED" ]; then
            # Update alacritty config
            if [ -f ~/.config/alacritty/alacritty.toml ]; then
                sed -i "s/family = \".*\"/family = \"$SELECTED\"/" ~/.config/alacritty/alacritty.toml
                notify-send "Terminal Font" "Set to $SELECTED (restart terminal)"
            else
                notify-send "Config Not Found" "Alacritty config not found"
            fi
        fi
        ;;
    *"Font Favorites"*)
        FAVORITES_FILE="$HOME/.config/rice-menu/fonts/favorites.txt"
        mkdir -p "$(dirname "$FAVORITES_FILE")"
        touch "$FAVORITES_FILE"

        FAV_OPTIONS="Switch to Favorite
Add to Favorites
Remove from Favorites
Back"

        SELECTED=$(echo "$FAV_OPTIONS" | fuzzel --dmenu --prompt=" Font Favorites: ")

        case "$SELECTED" in
            *"Switch"*)
                if [ -s "$FAVORITES_FILE" ]; then
                    FONT=$(cat "$FAVORITES_FILE" | fuzzel --dmenu --prompt=" Switch to: ")
                    if [ -n "$FONT" ]; then
                        # Update GTK config files
                        mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0

                        if [ -f ~/.config/gtk-3.0/settings.ini ]; then
                            sed -i "s/^gtk-font-name=.*/gtk-font-name=$FONT 11/" ~/.config/gtk-3.0/settings.ini
                        else
                            echo -e "[Settings]\ngtk-font-name=$FONT 11" > ~/.config/gtk-3.0/settings.ini
                        fi

                        if [ -f ~/.config/gtk-4.0/settings.ini ]; then
                            sed -i "s/^gtk-font-name=.*/gtk-font-name=$FONT 11/" ~/.config/gtk-4.0/settings.ini
                        else
                            echo -e "[Settings]\ngtk-font-name=$FONT 11" > ~/.config/gtk-4.0/settings.ini
                        fi

                        gsettings set org.gnome.desktop.interface font-name "$FONT 11"
                        gsettings set org.gnome.desktop.wm.preferences titlebar-font "$FONT Bold 11"

                        # Update Alacritty terminal font
                        if [ -f ~/.config/alacritty/alacritty.toml ]; then
                            sed -i "s/family = \".*\"/family = \"$FONT\"/" ~/.config/alacritty/alacritty.toml
                        fi

                        # Update Waybar font
                        if [ -f ~/.config/waybar/style.css ]; then
                            sed -i "s/font-family: .*/font-family: $FONT;/" ~/.config/waybar/style.css
                            killall waybar; sleep 0.5; waybar &
                        fi

                        # Update Fuzzel menu font
                        if [ -f ~/.config/fuzzel/fuzzel.ini ]; then
                            sed -i "s/^font=.*/font=$FONT:size=10/" ~/.config/fuzzel/fuzzel.ini
                        fi

                        # Update Mako notifications font
                        if [ -f ~/.config/omarchy/current/theme/mako.ini ]; then
                            sed -i "s/^font=.*/font=$FONT 11/" ~/.config/omarchy/current/theme/mako.ini
                            makoctl reload 2>/dev/null
                        fi

                        # Update SwayOSD font
                        if [ -f ~/.config/swayosd/style.css ]; then
                            sed -i "s/font-family: .*/font-family: '$FONT';/" ~/.config/swayosd/style.css
                        fi

                        # Update Hyprlock font
                        if [ -f ~/.config/hypr/hyprlock.conf ]; then
                            sed -i "s/font_family = .*/font_family = $FONT/" ~/.config/hypr/hyprlock.conf
                        fi

                        notify-send "Font Changed" "$FONT\nAll UI components updated\nRestart other apps to see changes"
                    fi
                else
                    notify-send "No Favorites" "Add fonts to favorites first"
                fi
                ;;
            *"Add"*)
                FONTS=$(fc-list : family | sort -u)
                FONT=$(echo "$FONTS" | fuzzel --dmenu --prompt=" Add to favorites: ")
                if [ -n "$FONT" ] && ! grep -q "^$FONT$" "$FAVORITES_FILE"; then
                    echo "$FONT" >> "$FAVORITES_FILE"
                    notify-send "Favorite Added" "$FONT"
                fi
                ;;
            *"Remove"*)
                if [ -s "$FAVORITES_FILE" ]; then
                    FONT=$(cat "$FAVORITES_FILE" | fuzzel --dmenu --prompt=" Remove: ")
                    if [ -n "$FONT" ]; then
                        sed -i "/^${FONT}$/d" "$FAVORITES_FILE"
                        notify-send "Favorite Removed" "$FONT"
                    fi
                fi
                ;;
        esac
        ;;
    *"Back to Main Menu"*)
        ~/.config/rice-menu/rice-control.sh
        ;;
esac
