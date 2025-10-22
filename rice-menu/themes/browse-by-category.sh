#!/bin/bash
# Browse Themes by Category - Ultra Fast

THEME_DIR="$HOME/.config/omarchy/themes"
SCHEME_DIR="$HOME/.config/rice-menu/color-schemes/alacritty"

CATEGORY_OPTIONS="All Themes
Dark Themes
Light Themes
Blue Themes
Green Themes
Red Themes
Purple Themes
Pastel Themes
Neon Themes
Monochrome Themes
Retro Themes
Other
Back"

selected=$(echo "$CATEGORY_OPTIONS" | fuzzel --dmenu --prompt="Browse by Category: " --lines=13)

case "$selected" in
    "All Themes") category="all"; pattern=".*" ;;
    "Dark Themes") category="Dark"; pattern="[Dd]ark|[Nn]ight|[Bb]lack|[Ss]hadow|[Mm]idnight|[Nn]oir" ;;
    "Light Themes") category="Light"; pattern="[Ll]ight|[Bb]right|[Dd]ay|[Ww]hite|[Ss]now|[Ii]vory" ;;
    "Blue Themes") category="Blue"; pattern="[Oo]cean|[Ss]ea|[Bb]lue|[Aa]qua|[Ww]ater" ;;
    "Green Themes") category="Green"; pattern="[Ff]orest|[Gg]reen|[Nn]ature|[Gg]rass|[Mm]int" ;;
    "Red Themes") category="Red"; pattern="[Ff]ire|[Rr]ed|[Rr]uby|[Cc]rimson|[Rr]ose" ;;
    "Purple Themes") category="Purple"; pattern="[Pp]urple|[Vv]iolet|[Ll]avender|[Gg]rape" ;;
    "Pastel Themes") category="Pastel"; pattern="[Pp]astel|[Ss]oft|[Gg]entle|[Mm]uted" ;;
    "Neon Themes") category="Neon"; pattern="[Nn]eon|[Cc]yber|[Ee]lectric|[Gg]low|[Vv]ibrant" ;;
    "Monochrome Themes") category="Monochrome"; pattern="[Mm]ono|[Gg]ray|[Gg]rey|[Gg]rayscale" ;;
    "Retro Themes") category="Retro"; pattern="[Rr]etro|[Vv]intage|[Cc]lassic|80s|90s" ;;
    "Other") category="Other"; pattern="" ;;
    "Back"|"") exec ~/.config/rice-menu/themes/menu.sh; exit 0 ;;
esac

# Call the looping category browser
exec ~/.config/rice-menu/themes/browse-category-loop.sh "$category" "$pattern"
