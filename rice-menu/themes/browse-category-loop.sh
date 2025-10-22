#!/bin/bash
# Browse Category Loop - Shows themes for a specific category with looping

THEME_DIR="$HOME/.config/omarchy/themes"
SCHEME_DIR="$HOME/.config/rice-menu/color-schemes/alacritty"

category="$1"
pattern="$2"

if [ -z "$category" ] || [ -z "$pattern" ]; then
    exit 1
fi

while true; do
    # Fast loading with grep pre-filtering
    filtered=$({
        # Installed themes
        [ -d "$THEME_DIR" ] && ls -1 "$THEME_DIR" 2>/dev/null | \
            grep -E "$pattern" | sed 's/$/ [installed]/'

        # Available schemes
        if [ -d "$SCHEME_DIR" ]; then
            ls -1 "$SCHEME_DIR" | grep "\.toml$" | sed 's/\.toml$//' | \
            grep -E "$pattern" | while read name; do
                [ ! -d "$THEME_DIR/$name" ] && echo "$name [available]"
            done
        fi
    } | {
        # For "Other" category, find themes that don't match main patterns
        if [ "$category" = "Other" ]; then
            grep -vE "[Dd]ark|[Nn]ight|[Bb]lack|[Ll]ight|[Bb]right|[Bb]lue|[Gg]reen|[Rr]ed|[Pp]urple|[Pp]astel|[Nn]eon|[Mm]ono|[Gg]ra|[Rr]etro|[Vv]intage"
        else
            cat
        fi
    })

    if [ -z "$filtered" ]; then
        notify-send "No Themes Found" "No themes found in category: $category"
        exit 0
    fi

    # Show results
    SELECTED=$(echo "$filtered" | fuzzel --dmenu --prompt="$category Themes: " --lines=15)

    if [ -z "$SELECTED" ]; then
        # User cancelled, exit
        exit 0
    fi

    THEME_NAME=$(echo "$SELECTED" | sed 's/ \[.*\]$//')
    IS_INSTALLED="false"
    echo "$SELECTED" | grep -q "\[installed\]" && IS_INSTALLED="true"

    # Call theme actions - it will return here after preview
    ~/.config/rice-menu/themes/theme-actions.sh "$THEME_NAME" "$IS_INSTALLED"

    # Loop back to show the category themes again
done
