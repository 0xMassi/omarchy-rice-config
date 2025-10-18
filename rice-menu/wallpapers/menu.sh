#!/bin/bash
# Wallpapers Menu - Omarchy Integration

CURRENT_BG=$(readlink ~/.config/omarchy/current/background)
THEME_BG_DIR="$HOME/.config/omarchy/current/theme/backgrounds"

OPTIONS="Browse Theme Backgrounds
Browse Custom Folder
Set Custom Wallpaper
Download from Unsplash
Add to Current Theme
Random Theme Background
Solid Color Background
Current: $(basename "$CURRENT_BG")
Back to Main Menu"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt=" Wallpapers: " --lines=8)

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
    *"Download from Unsplash"*)
        CATEGORIES=" Nature
 Space
 Architecture
 Animals
 Technology
 Abstract
 Minimalist
 Dark
 Random"
        
        CATEGORY=$(echo "$CATEGORIES" | fuzzel --dmenu --prompt=" Select Category: ")
        
        if [ -n "$CATEGORY" ]; then
            CATEGORY_CLEAN=$(echo "$CATEGORY" | xargs | tr '[:upper:]' '[:lower:]')
            OUTPUT_FILE="/tmp/unsplash-$CATEGORY_CLEAN-$(date +%s).jpg"
            
            notify-send "Downloading" "Fetching wallpaper from Unsplash..."
            curl -L "https://source.unsplash.com/1920x1080/?$CATEGORY_CLEAN" -o "$OUTPUT_FILE"
            
            if [ -f "$OUTPUT_FILE" ]; then
                # Update symlink
                ln -sf "$OUTPUT_FILE" ~/.config/omarchy/current/background
                
                # Set wallpaper
                pkill swaybg
                swaybg -i "$OUTPUT_FILE" -m fill &
                
                notify-send "Downloaded" "Wallpaper set from Unsplash"
                
                # Ask if user wants to save permanently
                SAVE=$(echo -e "Yes\nNo" | fuzzel --dmenu --prompt=" Save to theme backgrounds? ")
                if [ "$SAVE" = "Yes" ]; then
                    mkdir -p "$THEME_BG_DIR"
                    cp "$OUTPUT_FILE" "$THEME_BG_DIR/unsplash-$CATEGORY_CLEAN-$(date +%s).jpg"
                    notify-send "Saved" "Added to theme backgrounds"
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
