# Omarchy Rice Control Center

**Version 0.1.2**

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
- **Generate themes from wallpapers**: PyWal-powered color extraction creates complete themes
- **16-color palette generation**: Extract and apply colors from any image
- **Wallpaper rotation**: Cycle through current theme backgrounds
- **Random backgrounds**: Shuffle theme wallpapers
- **Solid colors**: Color picker for solid backgrounds
- **Add to theme**: Import custom wallpapers to current theme

### Waybar Customization
- **Toggle modules**: Enable/disable individual modules (weather, crypto, CPU, memory, battery, etc.)
- **Change position**: Top, bottom, left, right
- **Adjust height**: 20-32px options
- **Live reload**: Automatic restart after changes

### Notifications
- **Dual notification system support**: Mako (lightweight) and SwayNC (advanced center)
- **Seamless switching**: Switch between notification daemons with automatic configuration
- **Daemon-aware menu**: Settings automatically adapt to active notification system
- **SwayNC keybindings**: Control notification center with keyboard shortcuts
- **Icon support**: Notifications display with proper icons
- **Customization options**: Timeout, position, border radius, Do Not Disturb
- **Test notifications**: Preview different notification types

### Advanced Settings
- **Notification system switcher**: Switch between Mako and SwayNC
- **Service management**: Reload all services with daemon awareness
- Icons management
- Color scheme tweaks
- Direct config editing
- System information

## Installation

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
   - **Generate Theme from Wallpaper**: Create complete theme from any image (requires PyWal)
   - **Rotate Current Wallpaper**: Cycle through theme backgrounds
   - **Random Theme Background**: Shuffle current theme wallpapers
   - **Solid Color Background**: Use color picker for solid colors

### Generating Themes from Wallpapers
1. Open Rice Control → Wallpapers
2. Select "Generate Theme from Wallpaper"
3. Choose an image from Pictures or Downloads
4. Enter a theme name (or leave blank for auto-generated name)
5. Wait for PyWal to extract colors
6. Theme is automatically created and activated
7. All components updated with extracted colors

### Managing Notifications
1. Open Rice Control → Notifications
2. View current notification system (Mako or SwayNC)
3. Options:
   - **Change Timeout**: Set notification duration
   - **Change Position**: Move notifications on screen
   - **Change Border Radius**: Customize notification appearance
   - **Test Notifications**: Preview different types
   - **Toggle Do Not Disturb**: Silence notifications
   - **Edit Config Directly**: Manual configuration

### Switching Notification Systems
1. Open Rice Control → Advanced
2. Select "Switch Notification System"
3. Confirm the switch
4. System automatically:
   - Stops current daemon
   - Starts new daemon
   - Updates autostart configuration
   - Saves state for next boot

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
- **Mako or SwayNC** (notification daemon - choose one or both)
- swaybg (wallpaper)
- SwayOSD (volume/brightness popups)
- Hyprlock (lock screen)
- grim (screenshots)
- curl, jq, bc (for widgets)
- fd (file finder)
- **PyWal** (optional - for wallpaper theme generation: `pip3 install --user pywal`)
- Any Nerd Font

## What's New in v0.1.2

**SwayNC Notification Center:**
- Full SwayNC integration with comprehensive styling
- Switch between Mako and SwayNC seamlessly
- Daemon-aware notification settings
- Complete keybinding support

**Wallpaper Theme Generation:**
- Generate complete themes from any wallpaper using PyWal
- 16-color palette extraction
- Automatic configuration for all components
- One-click theme creation and activation

**Improvements:**
- Notification icon support for both daemons
- Enhanced wallpaper menu with rotation feature
- Daemon state tracking and automatic configuration
- Fixed notification icons and CSS specificity issues

[View Full Changelog](CHANGELOG.md)

## Versioning

This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

Current version: **0.1.2**

## License

MIT

---

**Made with 󰚩 by 0xMassi**
