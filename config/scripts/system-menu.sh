#!/bin/bash

create_system_theme() {
    cat > "$HOME/hyprlab/config/rofi/system-menu.rasi" << 'EOF'
* {
    bg-col:             rgba(30, 30, 46, 100%);
    bg-col-light:       rgba(49, 50, 68, 100%);
    border-col:         rgba(166, 227, 161, 100%);
    selected-col:       rgba(166, 227, 161, 100%);
    fg-col:             rgba(205, 214, 244, 100%);
    
    font: "JetBrainsMono Nerd Font 12";
    background-color: transparent;
}

window {
    transparency: "real";
    location: center;
    anchor: center;
    width: 500px;
    height: 450px;
    border: 2px solid;
    border-radius: 12px;
    border-color: @border-col;
    background-color: @bg-col;
}

mainbox {
    spacing: 8px;
    padding: 12px;
    background-color: transparent;
    children: [ "inputbar", "listview" ];
}

inputbar {
    spacing: 8px;
    padding: 8px;
    border-radius: 8px;
    background-color: @bg-col-light;
    children: [ "prompt" ];
}

prompt {
    padding: 6px 12px;
    border-radius: 6px;
    background-color: @selected-col;
    text-color: @bg-col;
}

listview {
    columns: 2;
    lines: 8;
    spacing: 4px;
    background-color: transparent;
}

element {
    padding: 10px 12px;
    border-radius: 8px;
    background-color: transparent;
    text-color: @fg-col;
}

element selected {
    background-color: @selected-col;
    text-color: @bg-col;
}

element-text {
    background-color: transparent;
    text-color: inherit;
}
EOF
}

create_system_menu() {
    echo "🚀 Applications"
    echo "📖 Arch Wiki"
    echo "⚡ Power Menu"
    echo "📸 Screenshots"
    echo "🎨 Themes"
    echo "🔊 Audio Control"
    echo "🌐 Network"
    echo "💽 Bluetooth"
    echo "🔋 Battery Info"
    echo "📅 Calendar"
    echo "💻 System Monitor"
    echo "⚙️ Settings"
    echo "🖼️ Wallpapers"
    echo "📁 File Manager"
    echo "💾 System Update"
    echo "🛠️ Maintenance"
}

handle_selection() {
    case "$1" in
        "🚀 Applications")
            rofi -show drun -theme Monokai -show-icons -icon-theme Papirus-Dark &
            ;;
        "📖 Arch Wiki")
            ~/hyprlab/config/scripts/arch-wiki-menu.sh &
            ;;
        "⚡ Power Menu")
            ~/hyprlab/config/scripts/power-menu.sh &
            ;;
        "📸 Screenshots")
            ~/hyprlab/config/scripts/screenshot-menu.sh &
            ;;
        "🎨 Themes")
            ~/hyprlab/config/scripts/theme-menu.sh &
            ;;
        "🔊 Audio Control")
            ~/hyprlab/config/scripts/volume-rofi.sh &
            ;;
        "🌐 Network")
            ~/hyprlab/config/scripts/wifi-menu.sh &
            ;;
        "💽 Bluetooth")
            ~/hyprlab/config/scripts/bluetooth-menu.sh &
            ;;
        "🔋 Battery Info")
            ~/hyprlab/config/scripts/battery-menu.sh &
            ;;
        "📅 Calendar")
            ~/hyprlab/config/scripts/date-menu.sh &
            ;;
        "💻 System Monitor")
            if command -v htop &> /dev/null; then
                kitty htop &
            elif command -v btop &> /dev/null; then
                kitty btop &
            else
                kitty top &
            fi
            ;;
        "⚙️ Settings")
            if command -v gnome-control-center &> /dev/null; then
                gnome-control-center &
            elif command -v systemsettings5 &> /dev/null; then
                systemsettings5 &
            else
                notify-send "Settings" "No settings manager found"
            fi
            ;;
        "🖼️ Wallpapers")
            ~/hyprlab/config/scripts/swww.sh &
            ;;
        "📁 File Manager")
            if command -v dolphin &> /dev/null; then
                dolphin &
            elif command -v nautilus &> /dev/null; then
                nautilus &
            elif command -v thunar &> /dev/null; then
                thunar &
            else
                notify-send "File Manager" "No file manager found"
            fi
            ;;
        "💾 System Update")
            kitty bash ~/hyprlab/config/scripts/maintenance.sh &
            ;;
        "🛠️ Maintenance")
            kitty bash ~/hyprlab/config/scripts/maintenance.sh &
            ;;
    esac
}

if [[ ! -f "$HOME/hyprlab/config/rofi/system-menu.rasi" ]]; then
    create_system_theme
fi

chosen=$(create_system_menu | rofi -dmenu -p "⚙️ System" -theme "$HOME/hyprlab/config/rofi/system-menu.rasi" -i -no-custom)

if [[ -n "$chosen" ]]; then
    handle_selection "$chosen"
fi