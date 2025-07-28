#!/bin/bash

# =============================================================================
# Hyprland Post-Installation Setup Script
# =============================================================================
# This script automatically installs and configures all required packages
# and dependencies for a complete Hyprland desktop environment.
#
# Author: Hedverse
# Version: 1.0.0
# =============================================================================

set -e

rm -f /tmp/failed_services.txt
touch /tmp/failed_services.txt

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}$1${NC}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_packages() {
    local packages=("$@")
    print_status "Installing packages: ${packages[*]}"
    
    if sudo pacman -S --needed --noconfirm "${packages[@]}"; then
        print_success "Successfully installed: ${packages[*]}"
    else
        print_error "Failed to install some packages: ${packages[*]}"
        print_warning "You may need to install these packages manually:"
        for pkg in "${packages[@]}"; do
            echo "  sudo pacman -S $pkg"
        done
        echo
        read -p "Continue with setup anyway? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

enable_service() {
    local service=$1
    local user_service=${2:-false}
    
    if [[ "$user_service" == "true" ]]; then
        if systemctl --user is-enabled "$service" >/dev/null 2>&1; then
            print_status "User service $service is already enabled"
        else
            print_status "Enabling user service: $service"
            if systemctl --user enable "$service" 2>/dev/null; then
                print_success "Enabled user service: $service"
            else
                print_warning "Failed to enable user service: $service (may not exist yet)"
                echo "$service" >> /tmp/failed_services.txt
            fi
        fi
    else
        if systemctl is-enabled "$service" >/dev/null 2>&1; then
            print_status "Service $service is already enabled"
        else
            print_status "Enabling service: $service"
            if sudo systemctl enable "$service" 2>/dev/null; then
                print_success "Enabled service: $service"
            else
                print_warning "Failed to enable service: $service (may not exist)"
                echo "$service" >> /tmp/failed_services.txt
            fi
        fi
    fi
}

create_symlink() {
    local source="$1"
    local target="$2"
    
    mkdir -p "$(dirname "$target")"
    
    if [ -L "$target" ]; then
        print_status "Removing existing symlink: $target"
        rm "$target"
    elif [ -e "$target" ]; then
        print_status "Backing up existing file: $target -> $target.backup"
        mv "$target" "$target.backup"
    fi
    
    print_status "Creating symlink: $target -> $source"
    ln -sf "$source" "$target"
}

print_header "
╔══════════════════════════════════════════════════════════════════════════════╗
║                        HYPRLAB SETUP SCRIPT v1.0                            ║
║                                                                              ║
║  This script installs essential tools and configures your existing           ║
║  Hyprland installation with all necessary packages and configs.             ║
╚══════════════════════════════════════════════════════════════════════════════╝
"

if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root!"
    exit 1
fi

print_header "🌐 CHECKING NETWORK CONNECTION"

if ! ping -c 1 google.com >/dev/null 2>&1; then
    print_warning "No internet connection detected."
    print_status "Try connecting with NetworkManager:"
    echo "  nmcli radio wifi on"
    echo "  nmcli dev wifi list"
    echo "  nmcli dev wifi connect <SSID> password <PASSWORD>"
    echo
    read -p "Do you want to connect to WiFi using iwctl? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Starting iwctl for WiFi connection..."
        echo "Available commands:"
        echo "  device list"
        echo "  station wlan0 scan"
        echo "  station wlan0 get-networks"
        echo "  station wlan0 connect <SSID>"
        echo "  exit"
        echo
        print_status "Opening iwctl (type 'exit' when done)..."
        iwctl
        
        if ping -c 1 google.com >/dev/null 2>&1; then
            print_success "Internet connection established!"
        else
            print_error "Still no internet connection. Please connect manually and restart script."
            exit 1
        fi
    else
        print_error "Internet connection required. Please connect manually and restart script."
        exit 1
    fi
else
    print_success "Internet connection detected!"
fi

print_header "📦 UPDATING SYSTEM PACKAGES"
print_status "Updating package database..."
sudo pacman -Sy

print_status "Upgrading system packages..."
sudo pacman -Su --noconfirm

print_header "🏗️  INSTALLING MISSING HYPRLAND TOOLS"

MISSING_TOOLS=(
    "hypridle"              # Idle daemon
    "hyprpicker"            # Color picker
    "xdg-desktop-portal-hyprland"  # XDG portal
)

install_packages "${MISSING_TOOLS[@]}"

print_header "🔊 UPGRADING AUDIO SYSTEM (PULSEAUDIO → PIPEWIRE)"

print_status "You currently have PulseAudio. Upgrading to PipeWire for better Wayland support..."

PIPEWIRE_PACKAGES=(
    "pipewire"              # Audio server
    "pipewire-pulse"        # PulseAudio compatibility
    "pipewire-alsa"         # ALSA compatibility
    "pipewire-jack"         # JACK compatibility
    "wireplumber"           # Session manager
    "pavucontrol"           # Audio control GUI
    "playerctl"             # Media player control
)

install_packages "${PIPEWIRE_PACKAGES[@]}"

print_status "Configuring PipeWire to replace PulseAudio..."
systemctl --user disable pulseaudio.service 2>/dev/null || true
systemctl --user enable pipewire.service
systemctl --user enable pipewire-pulse.service
systemctl --user enable wireplumber.service

print_header "🛠️  INSTALLING MISSING UTILITIES"

MISSING_PACKAGES=(
    "mako"                 # Notification daemon
    "wl-clipboard"         # Wayland clipboard utility
    "xdg-utils"            # Desktop integration utilities
    "polkit-gnome"         # Authentication agent
    "rofi-wayland"         # Application launcher and menu system
)

install_packages "${MISSING_PACKAGES[@]}"

print_header "🛠️  INSTALLING ADDITIONAL USEFUL TOOLS"

UTILITY_PACKAGES=(
    "btop"                 # Modern process monitor
    "fzf"                  # Fuzzy finder
    "ripgrep"              # Text search
    "fd"                   # File finder
    "bat"                  # Better cat with syntax highlighting
    "eza"                  # Better ls
)

install_packages "${UTILITY_PACKAGES[@]}"

print_header "🎨 INSTALLING FONTS & THEMES"

FONTS_THEMES=(
    "ttf-font-awesome"
    "noto-fonts"
    "papirus-icon-theme"
)

install_packages "${FONTS_THEMES[@]}"

print_header "📦 INSTALLING AUR PACKAGES"

if command_exists yay; then
    print_status "yay is available, installing AUR packages..."
    
    ESSENTIAL_AUR=(
        "hyprshot"                      # Screenshot tool
        "zsh-theme-powerlevel10k-git"   # Zsh theme
    )
    
    read -p "Do you want to install development tools (VS Code)? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ESSENTIAL_AUR+=("visual-studio-code-bin")
    fi
    
    read -p "Do you want to install entertainment apps (Spotify)? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ESSENTIAL_AUR+=("spotify")
    fi
    
    read -p "Do you want to install communication apps (Discord)? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ESSENTIAL_AUR+=("discord")
    fi
    
    if [ ${#ESSENTIAL_AUR[@]} -gt 0 ]; then
        for package in "${ESSENTIAL_AUR[@]}"; do
            print_status "Installing $package from AUR..."
            yay -S --noconfirm "$package" || print_warning "Failed to install $package"
        done
        print_success "AUR packages installation complete!"
    else
        print_status "No AUR packages selected"
    fi
else
    print_warning "yay not found. Install it manually if you want AUR packages."
fi

print_header "⚙️  SETTING UP CONFIGURATIONS"

DOTFILES_DIR="$HOME/hyprlab"
CONFIG_DIR="$HOME/.config"

mkdir -p "$CONFIG_DIR"

print_status "Setting up configuration symlinks..."

print_status "Setting up config directories..."
create_symlink "$DOTFILES_DIR/config/hypr" "$CONFIG_DIR/hypr"
create_symlink "$DOTFILES_DIR/config/kitty" "$CONFIG_DIR/kitty"
create_symlink "$DOTFILES_DIR/config/nvim" "$CONFIG_DIR/nvim"
create_symlink "$DOTFILES_DIR/config/waybar" "$CONFIG_DIR/waybar"
create_symlink "$DOTFILES_DIR/config/wofi" "$CONFIG_DIR/wofi"
create_symlink "$DOTFILES_DIR/config/mako" "$CONFIG_DIR/mako"
create_symlink "$DOTFILES_DIR/config/scripts" "$CONFIG_DIR/scripts"

print_status "Setting up rofi configuration..."
mkdir -p "$CONFIG_DIR/rofi"
if [[ -d "$CONFIG_DIR/rofi" ]]; then
    print_success "Rofi themes directory created at ~/.config/rofi"
else
    print_warning "Failed to create rofi directory"
fi

print_status "Setting up shell configuration..."
create_symlink "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/p10k.zsh" "$HOME/.p10k.zsh"

print_header "🔧 CONFIGURING SERVICES & PERMISSIONS"

print_status "Adding user to necessary groups..."
sudo usermod -aG audio,video,input,wheel "$USER"

enable_service "pipewire.service" "true"
enable_service "pipewire-pulse.service" "true"
enable_service "wireplumber.service" "true"

if lspci | grep -i nvidia >/dev/null; then
    print_header "🖥️  NVIDIA GPU DETECTED - INSTALLING DRIVERS"
    
    NVIDIA_PACKAGES=(
        "nvidia"               # NVIDIA drivers
        "nvidia-utils"         # NVIDIA utilities
        "nvidia-settings"      # NVIDIA control panel
        "libva-nvidia-driver"  # Hardware video acceleration
    )
    
    install_packages "${NVIDIA_PACKAGES[@]}"
    
    print_success "NVIDIA drivers installed. Reboot recommended."
fi

print_header "🎯 FINAL SETUP STEPS"

print_status "Making scripts executable..."
chmod +x "$DOTFILES_DIR/config/scripts"/*.sh
chmod +x "$DOTFILES_DIR/config/wofi/"*menu* 2>/dev/null || true
chmod +x "$DOTFILES_DIR/setup.sh"

print_status "Creating necessary directories..."
mkdir -p "$HOME/Pictures/Screenshots"
mkdir -p "$HOME/Pictures/Wallpapers"

if [[ -d "$DOTFILES_DIR/config/assets/wallpapers" ]]; then
    print_status "Copying wallpapers..."
    cp -r "$DOTFILES_DIR/config/assets/wallpapers/"* "$HOME/Pictures/Wallpapers/" 2>/dev/null || true
fi

if command_exists zsh; then
    print_status "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
fi

print_header "
╔══════════════════════════════════════════════════════════════════════════════╗
║                            INSTALLATION COMPLETE!                            ║
╚══════════════════════════════════════════════════════════════════════════════╝
"

print_success "Hyprland environment has been successfully set up!"
echo
print_status "Next steps:"
echo "  1. Reboot your system: sudo reboot"
echo "  2. Log out and select 'Hyprland' from your display manager"
echo "  3. Or start Hyprland manually: Hyprland"
echo
print_status "Key bindings:"
echo "  • Super + Q: Close window"
echo "  • Super + Return: Open terminal"
echo "  • Super + D: Open application launcher"
echo "  • Super + E: Open file manager"
echo "  • Super + L: Lock screen"
echo
print_status "Configuration files are located in: ~/.config/"
echo
print_warning "If you encounter any issues, check the logs:"
echo "  • Hyprland: journalctl -u hyprland"
echo "  • Waybar: waybar -l debug"
echo
show_manual_instructions() {
    if [[ -f /tmp/failed_services.txt ]] && [[ -s /tmp/failed_services.txt ]]; then
        print_header "⚠️  MANUAL INSTALLATION REQUIRED"
        print_warning "Some services failed to enable automatically. Please run these commands manually:"
        echo
        while IFS= read -r service; do
            if [[ "$service" == *"pipewire"* ]] || [[ "$service" == *"wireplumber"* ]]; then
                echo "  systemctl --user enable $service"
                echo "  systemctl --user start $service"
            else
                echo "  sudo systemctl enable $service"
                echo "  sudo systemctl start $service"
            fi
        done < /tmp/failed_services.txt
        echo
        print_status "To check service status:"
        echo "  systemctl --user status pipewire pipewire-pulse wireplumber"
        echo
        rm -f /tmp/failed_services.txt
    fi
    rm -f /tmp/failed_services.txt
}

show_manual_instructions

print_success "Enjoy your new Hyprland setup! 🚀"