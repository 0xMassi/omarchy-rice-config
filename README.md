# Omarchy Rice Control Center

**Version 0.1.1**

A powerful graphical control center for customizing Omarchy (Arch Linux + Hyprland). Manage themes, wallpapers, fonts, profiles, and system appearance through an intuitive menu interface.

## Features

### Theme Management
- **461+ themes available**: 17 built-in + 444 color schemes from iTerm2-Color-Schemes
- **Live preview**: See color palette before installing
- **Favorites system**: Quick access to preferred themes
- **One-click switching**: Change themes instantly
- **Auto-generation**: Themes created on-demand from color schemes

### Font Manager
- **System-wide font changes**: Update all UI components with one click
- **Components updated**:
  - GTK3/4 applications
  - Alacritty terminal
  - Waybar status bar
  - Fuzzel menu/launcher
  - Mako notifications
  - SwayOSD (volume/brightness popups)
  - Hyprlock (lock screen)
- **Font favorites**: Save and switch between preferred fonts
- **Browse fonts**: Preview all installed fonts
- **Terminal fonts**: Dedicated monospace font selection
- **Google Fonts integration**: Direct links to download new fonts

### Workspace Profiles
- **Save complete setups**: Theme + wallpaper + layout combinations
- **Quick profiles**: Work, Gaming, Creative, Evening presets
- **Export/Import**: Share profiles between systems
- **Profile favorites**: Mark frequently used setups

### Wallpaper Manager
- **Browse theme backgrounds**: Navigate through available wallpapers
- **Folder browser**: Visual file navigator for selecting custom images
- **Download from Unsplash**: Fetch wallpapers by category
- **Random backgrounds**: Shuffle theme wallpapers
- **Solid colors**: Color picker for solid backgrounds
- **Add to theme**: Import custom wallpapers to current theme

### Waybar Customization
- **Toggle modules**: Enable/disable individual modules (weather, crypto, CPU, memory, battery, etc.)
- **Change position**: Top, bottom, left, right
- **Adjust height**: 20-32px options
- **Live reload**: Automatic restart after changes

### Advanced Settings
- Icons management
- Color scheme tweaks
- Notifications customization
- Appearance settings

## Installation

### 1a. Install fuzzel
Hit `Super - Alt - Space` and go to `install`, then `Package`.
Search for `fuzzel` and install.

### 1. Clone This Repository
```bash
cd ~
git clone https://github.com/0xMassi/omarchy-rice-config
cd omarchy-rice-config
```

### 2. Install Rice Control Center
```bash
cp -r rice-menu ~/.config/
chmod +x ~/.config/rice-menu/rice-control.sh
chmod +x ~/.config/rice-menu/**/*.sh
```

### 3. Install Color Schemes (Required for 444+ themes)
```bash
git clone --depth=1 https://github.com/mbadolato/iTerm2-Color-Schemes /tmp/color-schemes
mkdir -p ~/.config/rice-menu/color-schemes
cp -r /tmp/color-schemes/alacritty ~/.config/rice-menu/color-schemes/
cp -r /tmp/color-schemes/kitty ~/.config/rice-menu/color-schemes/
rm -rf /tmp/color-schemes
```

### 4. Add Keybinding to Hyprland
Add this line to your `~/.config/hypr/bindings.conf`:
```bash
bind = SUPER, R, exec, ~/.config/rice-menu/rice-control.sh
```

Then reload Hyprland:
```bash
hyprctl reload
```

Done! Press **Super+R** to open the Rice Control Center.

## Usage

### Opening Rice Control
Press **Super+R** to open the Rice Control Center.

### Managing Fonts
1. Open Rice Control (Super+R)
2. Select "Fonts"
3. Options:
   - **Switch Font**: Quick font change from top 50 fonts
   - **Browse Available Fonts**: Preview all installed fonts
   - **Install from Google Fonts**: Open Google Fonts website
   - **Set Terminal Font**: Choose monospace fonts for terminal
   - **Font Favorites**: Manage favorite fonts

### Switching Themes
1. Open Rice Control (Super+R)
2. Select "Themes"
3. Select "Switch Theme"
4. Choose from installed themes

### Installing New Themes
1. Open Rice Control → Themes
2. Select "Browse All Themes"
3. Pick a theme marked **[AVAILABLE]**
4. Choose "Preview Colors" to see the palette
5. Select "Install & Activate" or "Install Only"

### Managing Theme Favorites
1. Open Rice Control → Themes → Favorites
2. Choose "Add to Favorites" or "Remove from Favorites"
3. Use "Switch to Favorite" for quick access

### Setting Wallpapers
1. Open Rice Control → Wallpapers
2. Options:
   - **Browse Theme Backgrounds**: Use wallpapers from current theme
   - **Browse Custom Folder**: Navigate filesystem for images
   - **Set Custom Wallpaper**: Quick selection from Pictures/Downloads
   - **Download from Unsplash**: Fetch wallpapers by category
   - **Random Theme Background**: Shuffle current theme wallpapers
   - **Solid Color Background**: Use color picker for solid colors

### Customizing Waybar
1. Open Rice Control → Waybar
2. Select "Toggle Modules" to enable/disable modules
3. Change position (top/bottom/left/right)
4. Adjust height (20-32px)

### Saving Workspace Profiles
1. Set up your desktop (theme, wallpaper, layout)
2. Open Rice Control → Profiles
3. Select "Save Current Setup"
4. Enter a profile name
5. Load it anytime from "Load Profile"

### Quick Profiles
1. Open Rice Control → Profiles
2. Select "Quick Profiles"
3. Choose: Work, Gaming, Creative, or Evening

## Requirements

- Hyprland
- Waybar
- Alacritty (terminal)
- Fuzzel (menu launcher)
- Mako (notification daemon)
- swaybg (wallpaper)
- SwayOSD (volume/brightness popups)
- Hyprlock (lock screen)
- grim (screenshots)
- curl, jq, bc (for widgets)
- fd (file finder)
- Any Nerd Font

## What's New in v0.1.1

**Bug Fixes:**
- Fixed btop theme not updating when switching themes
- Theme generator now creates btop.theme files automatically

[View Full Changelog](CHANGELOG.md)

## Versioning

This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

Current version: **0.1.1**

## License

MIT

---

**Made with 󰚩 by 0xMassi**
