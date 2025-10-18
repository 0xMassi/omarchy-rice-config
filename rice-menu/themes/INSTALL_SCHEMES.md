# Color Schemes Installation

The Rice Control Center requires the iTerm2-Color-Schemes library for the theme system.

## Installation

Run this command to install 444 color schemes:

```bash
git clone --depth=1 https://github.com/mbadolato/iTerm2-Color-Schemes ~/.config/rice-menu/color-schemes-temp
cp -r ~/.config/rice-menu/color-schemes-temp/alacritty ~/.config/rice-menu/color-schemes/
cp -r ~/.config/rice-menu/color-schemes-temp/kitty ~/.config/rice-menu/color-schemes/
rm -rf ~/.config/rice-menu/color-schemes-temp
```

Or install during setup:

```bash
./install.sh
```

## What This Provides

- **444 professional color schemes** including:
  - Dracula, Monokai, Nord, Tokyo Night
  - Catppuccin, Gruvbox, Solarized
  - One Dark, Ayu, Palenight
  - And 434 more!

- **On-demand theme generation**
  - Complete Omarchy themes from any scheme
  - Terminal colors (Alacritty + Kitty)
  - Waybar, Hyprland, Fuzzel, Mako theming

## Usage

After installation:

1. Press `Super+R` → Themes → Browse All Themes
2. Select any of 444 color schemes
3. Click "Activate" to generate and apply
4. Theme is created instantly!

Total: **461+ themes available** (17 built-in + 444 color schemes)
