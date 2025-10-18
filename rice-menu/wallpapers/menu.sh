#!/bin/bash
# Wallpapers Menu - Omarchy Integration

CURRENT_BG=$(readlink ~/.config/omarchy/current/background)
THEME_BG_DIR="$HOME/.config/omarchy/current/theme/backgrounds"

OPTIONS="Browse Theme Backgrounds
Browse Custom Folder
Set Custom Wallpaper
Generate Theme from Wallpaper
Add to Current Theme
Random Theme Background
Rotate Current Wallpaper
Solid Color Background
Current: $(basename "$CURRENT_BG")
Back to Main Menu"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt=" Wallpapers: " --lines=9)

case "$selected" in
    *"Browse Theme Backgrounds"*)
        if [ -d "$THEME_BG_DIR" ]; then
            WALLPAPERS=$(ls -1 "$THEME_BG_DIR"/*.{png,jpg,jpeg} 2>/dev/null | xargs -n1 basename | sed 's/^/ /')
            
            if [ -z "$WALLPAPERS" ]; then
                notify-send "No Backgrounds" "Current theme has no backgrounds"
            else
                SELECTED=$(echo "$WALLPAPERS" | fuzzel --dmenu --prompt=" Select Background: ")
                
                if [ -n "$SELECTED" ]; then
                    BG_NAME=$(echo "$SELECTED" | xargs)
                    BG_PATH="$THEME_BG_DIR/$BG_NAME"
                    
                    # Update background symlink
                    ln -sf "$BG_PATH" ~/.config/omarchy/current/background
                    
                    # Set wallpaper
                    pkill swaybg
                    swaybg -i "$BG_PATH" -m fill &
                    
                    notify-send "Background Changed" "$BG_NAME"
                fi
            fi
        else
            notify-send "No Backgrounds" "Current theme has no background folder"
        fi
        ;;
    *"Browse Custom Folder"*)
        # Use folder browser
        IMG_PATH=$($HOME/.config/rice-menu/wallpapers/folder-browser.sh "$HOME")

        if [ -n "$IMG_PATH" ] && [ -f "$IMG_PATH" ]; then
            # Update symlink
            ln -sf "$IMG_PATH" ~/.config/omarchy/current/background

            # Set wallpaper
            pkill swaybg
            swaybg -i "$IMG_PATH" -m fill &

            notify-send "Background Changed" "$(basename "$IMG_PATH")"
        fi
        ;;
    *"Set Custom Wallpaper"*)
        # Find images in common directories
        IMAGES=$(fd -t f -e jpg -e jpeg -e png -e webp . "$HOME/Pictures" "$HOME/Downloads" 2>/dev/null | head -20 | sed 's/^/ /')
        
        if [ -z "$IMAGES" ]; then
            notify-send "No Images" "No images found in Pictures or Downloads"
        else
            SELECTED=$(echo "$IMAGES" | fuzzel --dmenu --prompt=" Select Image: ")
            
            if [ -n "$SELECTED" ]; then
                IMG_PATH=$(echo "$SELECTED" | xargs)
                
                # Update symlink
                ln -sf "$IMG_PATH" ~/.config/omarchy/current/background
                
                # Set wallpaper
                pkill swaybg
                swaybg -i "$IMG_PATH" -m fill &
                
                notify-send "Background Changed" "$(basename "$IMG_PATH")"
            fi
        fi
        ;;
    *"Generate Theme from Wallpaper"*)
        # Find images in common directories
        IMAGES=$(fd -t f -e jpg -e jpeg -e png -e webp . "$HOME/Pictures" "$HOME/Downloads" 2>/dev/null | head -20 | sed 's/^/ /')

        if [ -z "$IMAGES" ]; then
            notify-send "No Images" "No images found in Pictures or Downloads"
        else
            SELECTED=$(echo "$IMAGES" | fuzzel --dmenu --prompt=" Select Wallpaper: ")

            if [ -n "$SELECTED" ]; then
                IMG_PATH=$(echo "$SELECTED" | xargs)

                # Ask for theme name
                THEME_NAME=$(echo "" | fuzzel --dmenu --prompt=" Theme Name: ")

                if [ -z "$THEME_NAME" ]; then
                    THEME_NAME="wallpaper-$(basename "$IMG_PATH" | sed 's/\.[^.]*$//' | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
                fi

                # Generate theme
                notify-send "Generating Theme" "Extracting colors from wallpaper..."

                if ~/.config/rice-menu/wallpapers/generate-from-wallpaper.sh "$IMG_PATH" "$THEME_NAME"; then
                    notify-send "Theme Created" "Activating $THEME_NAME..."

                    # Create symlink if needed (generator uses ~/.local/share, setter uses ~/.config)
                    if [ ! -e ~/.config/omarchy/themes/"$THEME_NAME" ]; then
                        ln -sf ~/.local/share/omarchy/themes/"$THEME_NAME" ~/.config/omarchy/themes/"$THEME_NAME"
                    fi

                    # Activate the new theme
                    omarchy-theme-set "$THEME_NAME"

                    notify-send "Complete" "Theme generated and activated!"
                else
                    notify-send "Error" "Failed to generate theme. Make sure pywal is installed: pip3 install --user pywal"
                fi
            fi
        fi
        ;;
    *"Add to Current Theme"*)
        IMAGES=$(fd -t f -e jpg -e jpeg -e png -e webp . "$HOME/Pictures" "$HOME/Downloads" 2>/dev/null | head -20 | sed 's/^/ /')
        
        if [ -z "$IMAGES" ]; then
            notify-send "No Images" "No images found"
        else
            SELECTED=$(echo "$IMAGES" | fuzzel --dmenu --prompt=" Add to theme: ")
            
            if [ -n "$SELECTED" ]; then
                IMG_PATH=$(echo "$SELECTED" | xargs)
                mkdir -p "$THEME_BG_DIR"
                
                cp "$IMG_PATH" "$THEME_BG_DIR/"
                notify-send "Added" "$(basename "$IMG_PATH") added to theme backgrounds"
            fi
        fi
        ;;
    *"Random Theme Background"*)
        if [ -d "$THEME_BG_DIR" ]; then
            RANDOM_BG=$(ls -1 "$THEME_BG_DIR"/*.{png,jpg,jpeg} 2>/dev/null | shuf -n 1)

            if [ -n "$RANDOM_BG" ]; then
                ln -sf "$RANDOM_BG" ~/.config/omarchy/current/background
                pkill swaybg
                swaybg -i "$RANDOM_BG" -m fill &
                notify-send "Random Background" "$(basename "$RANDOM_BG")"
            else
                notify-send "No Backgrounds" "No backgrounds in theme"
            fi
        fi
        ;;
    *"Rotate Current Wallpaper"*)
        if [ -f "$CURRENT_BG" ]; then
            ROTATION_OPTIONS=" 90° Clockwise
 180°
 90° Counter-clockwise
 Flip Horizontal
 Flip Vertical"

            ROTATION=$(echo "$ROTATION_OPTIONS" | fuzzel --dmenu --prompt=" Rotate: ")

            if [ -n "$ROTATION" ]; then
                ROTATED_FILE="${CURRENT_BG%.*}-rotated.${CURRENT_BG##*.}"

                case "$ROTATION" in
                    *"90° Clockwise"*)
                        magick "$CURRENT_BG" -rotate 90 -quality 100 "$ROTATED_FILE"
                        ;;
                    *"180°"*)
                        magick "$CURRENT_BG" -rotate 180 -quality 100 "$ROTATED_FILE"
                        ;;
                    *"90° Counter-clockwise"*)
                        magick "$CURRENT_BG" -rotate 270 -quality 100 "$ROTATED_FILE"
                        ;;
                    *"Flip Horizontal"*)
                        magick "$CURRENT_BG" -flop -quality 100 "$ROTATED_FILE"
                        ;;
                    *"Flip Vertical"*)
                        magick "$CURRENT_BG" -flip -quality 100 "$ROTATED_FILE"
                        ;;
                esac

                if [ -f "$ROTATED_FILE" ]; then
                    # Replace original with rotated version
                    mv "$ROTATED_FILE" "$CURRENT_BG"

                    # Reload wallpaper
                    pkill swaybg
                    swaybg -i "$CURRENT_BG" -m fill &

                    notify-send "Wallpaper Rotated" "Applied rotation: $ROTATION"
                fi
            fi
        else
            notify-send "No Wallpaper" "No current wallpaper set"
        fi
        ;;
    *"Solid Color Background"*)
        notify-send "Color Picker" "Click to pick a color"
        COLOR=$(hyprpicker -a -f hex)
        
        if [ -n "$COLOR" ]; then
            # Create solid color image (requires ImageMagick)
            convert -size 1920x1080 "xc:$COLOR" "/tmp/solid-$COLOR.png" 2>/dev/null || {
                notify-send "Error" "ImageMagick not installed. Install with: yay -S imagemagick"
                exit 1
            }
            
            ln -sf "/tmp/solid-$COLOR.png" ~/.config/omarchy/current/background
            pkill swaybg
            swaybg -i "/tmp/solid-$COLOR.png" -m fill &
            
            notify-send "Solid Color" "Background set to $COLOR"
        fi
        ;;
    *"Current:"*)
        notify-send "Current Wallpaper" "$CURRENT_BG"
        ;;
    *"Back to Main Menu"*)
        ~/.config/rice-menu/rice-control.sh
        ;;
esac
