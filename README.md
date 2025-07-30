# 🚀 Arch Linux Hyprland Configuration (HyprLab)

Complete Arch Linux configuration with automated installation for a beautiful Hyprland desktop environment.

## ✨ Features

- **🪟 Hyprland**: Wayland compositor with stunning animations and tiling
- **📊 Waybar**: Highly customizable status bar with modern styling  
- **🐱 Kitty**: GPU-accelerated terminal emulator
- **🌸 Catppuccin Theme**: Consistent theming across all applications
- **💻 Neovim**: Fully configured IDE with LSP support
- **🔍 Wofi**: Beautiful app launcher and menu system
- **🎯 Rofi**: Interactive menus for system controls (WiFi, Bluetooth, Audio, etc.)
- **🎨 Wallpaper Collection**: Curated anime, nature, and artistic wallpapers
- **🔧 Zsh + Powerlevel10k**: Fast shell with beautiful prompt
- **🔊 PipeWire Audio**: Modern audio system with full compatibility
- **🔧 Automated Setup**: One-command installation script

## 📦 Included Configurations

### Window Manager & Compositor
- **Hyprland**: Main configuration with modular setup
  - Animations and transitions
  - Window rules and workspace management
  - Keybindings and shortcuts
  - Monitor configuration
  - NVIDIA GPU support

### Status Bar & UI
- **Waybar**: Interactive status bar with Nerd Font icons and click-to-open controls
- **Rofi**: Interactive menus for WiFi, Bluetooth, Battery, Audio, Brightness controls
- **Wofi**: Application launcher with custom styling
- **Spotify Integration**: Live music status with playback controls
- **Hyprlock**: Screen locking utility
- **Hypridle**: Idle management

### Terminal & Development
- **Kitty**: Terminal emulator configuration
- **Neovim**: Complete IDE setup with:
  - LSP configurations
  - Syntax highlighting (Treesitter)
  - Git integration
  - File explorer (Neo-tree)
  - Code completion
  - Linting and formatting

### Shell Environment
- **Zsh**: Shell configuration
- **Powerlevel10k**: Prompt theme

## 🎨 Screenshots

*Beautiful, modern desktop environment with consistent theming*

## 📋 Prerequisites

### Base Arch Installation
Complete a standard Arch Linux installation with these essentials:

```bash
# During arch-chroot setup
pacstrap -i /mnt base base-devel linux linux-firmware sudo nano git networkmanager

# After reboot, install display manager and basic Hyprland
sudo pacman -Syu
sudo pacman -S sddm hyprland
sudo systemctl enable sddm
```

### AUR Helper (Required)
Install `yay` for AUR package management:
```bash
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si
```

## 🚀 Automated Installation

**One-command setup after base Arch installation:**

```bash
# Clone dotfiles
git clone https://github.com/hedversecorp/hyprlab.git
cd ~/hyprlab

# Run the automated setup script
chmod +x setup.sh
./setup.sh
```

The script automatically:
- ✅ Checks network connectivity (with iwctl fallback)
- ✅ Upgrades audio system (PulseAudio → PipeWire)
- ✅ Installs all required packages and AUR packages
- ✅ Configures all dotfiles with symlinks
- ✅ Sets up services and permissions
- ✅ Handles NVIDIA drivers (if detected)
- ✅ Provides manual instructions for any failures

## 📦 What Gets Installed

### Core Packages
- **Window Manager**: Hyprland, hypridle, hyprpicker, xdg-desktop-portal-hyprland
- **Audio System**: PipeWire, pipewire-pulse, pipewire-alsa, wireplumber, pavucontrol
- **UI Components**: Waybar, Wofi, Rofi-wayland, Mako (notifications), polkit-gnome
- **Utilities**: wl-clipboard, xdg-utils, btop, fzf, ripgrep, fd, bat, eza
- **Fonts**: Font Awesome, Noto Fonts, Papirus icons

### AUR Packages (Optional)
- **Screenshot**: hyprshot
- **Development**: visual-studio-code-bin (optional)
- **Entertainment**: spotify (optional)  
- **Communication**: discord (optional)
- **Shell**: zsh-theme-powerlevel10k-git

### NVIDIA Support
Automatically detects and installs NVIDIA drivers if GPU is detected.

## 🔧 Manual Installation

<details>
<summary>Click to expand manual installation steps</summary>

```bash
sudo pacman -S hyprland waybar kitty neovim zsh wofi rofi-wayland mako pipewire pipewire-pulse wireplumber

mkdir -p ~/.config $HOME/hyprlab/config/rofi
ln -sf ~/hyprlab/config/hypr ~/.config/hypr
ln -sf ~/hyprlab/config/kitty ~/.config/kitty
ln -sf ~/hyprlab/config/nvim ~/.config/nvim
ln -sf ~/hyprlab/config/waybar ~/.config/waybar
ln -sf ~/hyprlab/config/wofi ~/.config/wofi
ln -sf ~/hyprlab/config/mako ~/.config/mako
ln -sf ~/hyprlab/config/scripts ~/.config/scripts
ln -sf ~/hyprlab/zshrc ~/.zshrc
ln -sf ~/hyprlab/p10k.zsh ~/.p10k.zsh

chmod +x ~/.config/scripts/*.sh

systemctl --user enable pipewire pipewire-pulse wireplumber
chsh -s $(which zsh)
```
</details>

## 🎯 Post-Installation

After running the setup script:

1. **Reboot your system**:
   ```bash
   reboot
   ```

2. **Select Hyprland** from your display manager (SDDM)

3. **Configure Powerlevel10k** (first run):
   ```bash
   p10k configure
   ```

## 📁 Structure

```
hyprlab/
├── config/
│   ├── hypr/           # Hyprland configuration
│   ├── kitty/          # Terminal emulator  
│   ├── nvim/           # Neovim IDE setup
│   ├── waybar/         # Status bar
│   ├── wofi/           # App launcher
│   ├── mako/           # Notification daemon
│   ├── scripts/        # System control menus and utilities
│   └── assets/         # Wallpapers and resources
├── zshrc               # Zsh configuration
├── p10k.zsh            # Powerlevel10k theme
├── setup.sh            # Automated installation script
└── README.md           # This file
```

## ⌨️ Default Keybindings

| Key Combination | Action |
|-----------------|--------|
| `Super + Q` | Close window |
| `Super + Return` | Open terminal (Kitty) |
| `Super + Space` | Open application launcher (Wofi) |
| `Super + E` | Open file manager |
| `Super + L` | Lock screen |
| `Super + 1-9` | Switch to workspace 1-9 |
| `Super + Shift + 1-9` | Move window to workspace 1-9 |

## 📱 Waybar Features

### Interactive System Controls
- **WiFi Module** (󰖩): Click to open WiFi connection menu with network selection
- **Bluetooth Module** (󰂯): Click to manage Bluetooth devices and connections
- **Audio Module** (󰕾): Click for volume control with visual sliders
- **Battery Module** (󰁹): Click for power management and system profiles
- **Brightness Module** (󰃞): Click for display brightness control
- **Clock Module** (󰥔): Click for calendar and time zone information

### Wallpaper Management
- **Wallpaper Button** (󰸉): Left click for next wallpaper, right click to switch themes
- **Animation Button** (󰽡): Click to select wallpaper transition animations (fade, grow, wave, etc.)

### Media Controls
- **Spotify Module**: Shows current playing track with click for play/pause, scroll for next/previous

## 🎨 Customization

### Wallpapers
The `config/assets/wallpapers/` directory contains curated wallpaper collections:
- Anime-themed wallpapers
- Nature photography
- Abstract and artistic designs

*Wallpapers sourced from [Pixabay](https://pixabay.com) under their Content License, which allows free use in open source projects.*

**Individual Wallpaper Credits:**
- Anime1: [Backpacker Road Walk Anime](https://pixabay.com/illustrations/backpacker-road-walk-anime-7628303/)
- Anime2: [Girl Sunset House Farmhouse Anime](https://pixabay.com/illustrations/girl-sunset-house-farmhouse-anime-7628308/)
- Nature1: [Mountains Panorama Forest](https://pixabay.com/vectors/mountains-panorama-forest-mountain-1412683/)
- Nature2: [Natural Mountain Landscape Pine](https://pixabay.com/vectors/natural-mountain-landscape-pine-4821585/)

### Themes
The configuration uses the Catppuccin color scheme. To change themes, modify the theme files in each application's config directory.

### Keybindings
Hyprland keybindings are defined in `config/hypr/keybindings.conf`. Customize them according to your preferences.

## 🔧 Utility Scripts

### Wallpaper Management
- `scripts/swww.sh`: Dynamic wallpaper switching with configurable animations
- `scripts/swww-animation.sh`: Interactive animation selector for wallpaper transitions

### System Control Menus
- `scripts/wifi-menu.sh`: WiFi network management with rofi interface
- `scripts/bluetooth-menu.sh`: Bluetooth device pairing and connection management
- `scripts/battery-menu.sh`: Power management and battery statistics
- `scripts/brightness-control.sh`: Display brightness control with visual feedback
- `scripts/volume-rofi.sh`: Audio control with volume sliders and device selection

### Media Controls
- `scripts/spotify-control.sh`: Spotify playback control and status display
- `scripts/spotify-menu.sh`: Spotify playlist and track management

### System Utilities
- `scripts/maintenance.sh`: System maintenance automation  
- `scripts/gitswitch.sh`: Git branch switching utility

## 🐛 Troubleshooting

### Audio Issues
```bash
# Check PipeWire status
systemctl --user status pipewire pipewire-pulse wireplumber

# Restart audio services if needed
systemctl --user restart pipewire pipewire-pulse wireplumber
```

### Hyprland Issues
```bash
# Check Hyprland logs
journalctl --user -u hyprland -f

# Check display manager logs
journalctl -u sddm -f
```

### Network Issues
```bash
# Connect to WiFi manually
nmcli radio wifi on
nmcli dev wifi list
nmcli dev wifi connect "SSID" password "PASSWORD"
```

## 🔄 Updating

To update your dotfiles configuration:
```bash
cd ~/hyprlab
git pull origin main
./setup.sh  # Re-run if needed
```

## 🤝 Contributing

Feel free to fork this repository and submit pull requests for improvements or additional configurations.

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- [Hyprland](https://hyprland.org/) - Amazing Wayland compositor
- [Catppuccin](https://catppuccin.com/) - Beautiful color palette
- [LazyVim](https://lazyvim.org/) - Neovim configuration framework
- The amazing Arch Linux community

---

⭐ **Star this repository if you found it helpful!**