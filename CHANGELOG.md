# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2025-10-22

### Added - Theme Editor
- **Complete theme creation system** - Create custom themes from scratch
- **Visual color picker** - Edit all 16 terminal colors, background, and foreground
- **Real-time preview** - See color changes as you edit
- **Auto-config generation** - Generates configs for Alacritty, Kitty, Hyprland, Waybar, Fuzzel, notifications, btop, and GTK
- **Metadata editor** - Set theme name, author, description, tags, and version
- **README generation** - Auto-creates documentation with color palette table

### Added - Theme Sharing System
- **Export themes** - Package themes as .tar.gz archives with all assets
- **Import themes** - Install community themes from archives
- **GitHub Gist integration** - Upload and share themes via Gist
- **One-command Gist setup** - Automatic GitHub token configuration
- **Direct URL sharing** - Share downloadable theme links
- **Theme validation** - Verify theme integrity on import

### Added - GTK Theme Integration
- **Auto-generate GTK3 themes** - Creates complete GTK3 CSS in ~/.themes
- **Auto-generate GTK4 themes** - Creates GTK4 CSS in ~/.config/gtk-4.0
- **Automatic color extraction** - Pulls colors from existing theme files
- **Dynamic application** - Applies GTK themes on every theme switch
- **Comprehensive styling** - Full coverage of GTK widgets (windows, buttons, menus, dialogs, etc.)
- **Fallback generation** - Auto-creates color configs from existing theme files
- **Testing utility** - Visual GTK theme testing with dialogs

### Added - Enhanced Theme Browsing
- **Browse by category** - Organized browsing (Dark, Light, Colorful, Pastel, etc.)
- **Category loop navigation** - Quick cycling through themed categories
- **Recently used themes** - Access your most recent themes
- **Live color preview** - View full color palette before applying
- **Theme actions menu** - Apply or preview from any browser

### Added - Effects Menu
- **Animations control** - Adjust animation speed and style
- **Blur settings** - Configure background blur intensity for different layers
- **Opacity adjustments** - Set transparency for active and inactive windows
- **Rounding control** - Customize window corner radius (0-20px)
- **Shadow settings** - Configure drop shadow size, offset, and color
- **Performance presets** - Quick profiles (Performance, Balanced, Eye Candy)

### Changed
- **Theme menu** - Reorganized with Theme Editor, Browse by Category, Recently Used, and Sharing options
- **Main menu** - Added Effects option
- **Theme generation** - Now includes GTK theme support
- **Config generation** - Integrated into theme editor workflow

### Technical Details
- Added theme editor with color picker and metadata management
- Added theme sharing system with export/import and Gist integration
- Added GTK3/GTK4 theme generators with automatic application
- Added effects menu with comprehensive visual customization
- Added category-based theme browsing
- Added recently used themes tracking
- Updated theme generation to include GTK support

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
