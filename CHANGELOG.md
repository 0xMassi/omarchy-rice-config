# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.2] - 2025-10-20

### Added - SwayNC Notification Center
- **Full SwayNC integration** with comprehensive CSS styling (226 lines)
- **SwayNC keybindings**:
  - `SUPER + ,` → Close Latest Notification
  - `SUPER + SHIFT + ,` → Toggle Notification Center
  - `SUPER + CTRL + ,` → Close All Notifications
  - `SUPER + ALT + ,` → Toggle Do Not Disturb
- **Notification system switcher** - Switch between Mako and SwayNC seamlessly
- **Daemon-aware notifications menu** - Automatically adapts to active notification system
- **Notification icon support** for both Mako and SwayNC with proper icon paths
- **State tracking system** for current notification daemon
- **Autostart configuration management** - Updates automatically when switching daemons

### Added - Wallpaper Theme Generation
- **Generate themes from wallpapers** using PyWal color extraction
- **16-color palette generation** from any image
- **Automatic theme creation** with all configuration files:
  - Alacritty terminal colors
  - Kitty terminal colors
  - Fuzzel launcher styling
  - Mako notifications
  - SwayNC notifications
  - Waybar statusbar
  - Hyprland window manager
  - btop system monitor
- **Wallpaper rotation** - Cycle through current theme backgrounds
- **Direct image selection** from Pictures and Downloads folders
- Theme files generated in `~/.local/share/omarchy/themes/`

### Changed
- **Notifications menu** now detects and configures the active daemon automatically
- **Service reload** now daemon-aware (uses makoctl or swaync-client appropriately)
- **Advanced menu** expanded with notification system switching option
- **Mako configuration** enhanced with explicit icon paths and 48px icon size
- **Wallpaper menu** redesigned with theme generation workflow
- **Theme generation** from color schemes now includes swaync.css

### Removed
- Unsplash download functionality (replaced with wallpaper theme generation)

### Fixed
- Fixed rose-pine-moon waybar accent color (cyan → pink)
- Fixed CSS specificity issues in SwayNC styles to override system defaults
- Fixed notification icons not displaying

### Technical Details
- Added `generate-from-wallpaper.sh` (251 lines) for PyWal-based theme creation
- Added `switch-notification-daemon.sh` for seamless daemon switching
- Added `swaync/style.css` with complete notification center styling
- SwayNC uses `@foreground`, `@background`, `@accent` CSS variables
- State file tracking at `~/.config/omarchy/notification-daemon.state`
- Proper CSS selector specificity to override `/etc/xdg/swaync/style.css`
- Both mako.ini and swaync.css generated for all themes

## [0.1.1] - 2025-10-18

### Fixed
- Fixed btop theme not updating when switching themes
- Theme generator now creates btop.theme files with proper color mappings
- All generated themes now include btop color schemes

### Added
- Added v0.2.0 roadmap for future development

## [0.1.0] - 2025-10-18

### Added
- Complete system-wide font management
- Font favorites system
- Google Fonts integration
- Terminal font selection
- Visual folder browser for wallpaper selection
- Unsplash integration with categories
- Solid color backgrounds with color picker
- Add custom images to current theme
- Working Waybar module toggle functionality
- Automatic reload after Waybar changes
- Module state persistence

### Changed
- Removed emoji clutter from menu options
- Simplified favorites management
- Better navigation and organization

[0.1.2]: https://github.com/0xMassi/omarchy-rice-config/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/0xMassi/omarchy-rice-config/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/0xMassi/omarchy-rice-config/releases/tag/v0.1.0
