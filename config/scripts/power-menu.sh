#!/bin/bash

create_power_theme() {
    cat > "$HOME/hyprlab/config/rofi/power-menu.rasi" << 'EOF'
* {
    bg-col:             rgba(30, 30, 46, 100%);
    bg-col-light:       rgba(49, 50, 68, 100%);
    border-col:         rgba(243, 139, 168, 100%);
    selected-col:       rgba(243, 139, 168, 100%);
    fg-col:             rgba(205, 214, 244, 100%);
    
    font: "JetBrainsMono Nerd Font 12";
    background-color: transparent;
}

window {
    transparency: "real";
    location: northeast;
    anchor: northeast;
    width: 280px;
    height: 200px;
    x-offset: -10px;
    y-offset: 48px;
    border: 2px solid;
    border-radius: 12px;
    border-color: @border-col;
    background-color: @bg-col;
}

mainbox {
    spacing: 8px;
    padding: 8px;
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
    columns: 1;
    lines: 5;
    spacing: 2px;
    background-color: transparent;
}

element {
    padding: 8px 12px;
    border-radius: 6px;
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

create_power_menu() {
    echo "󰐥 Power Off"
    echo "󰜉 Restart"
    echo "󰤄 Sleep"
    echo "󰍃 Log Out"
    echo "󰌾 Lock Screen"
}

handle_selection() {
    case "$1" in
        "󰐥 Power Off")
            systemctl poweroff
            ;;
        "󰜉 Restart")
            systemctl reboot
            ;;
        "󰤄 Sleep")
            systemctl suspend
            ;;
        "󰍃 Log Out")
            hyprctl dispatch exit
            ;;
        "󰌾 Lock Screen")
            hyprlock
            ;;
    esac
}

if [[ ! -f "$HOME/hyprlab/config/rofi/power-menu.rasi" ]]; then
    create_power_theme
fi

chosen=$(create_power_menu | rofi -dmenu -p "⚡ Power" -theme "$HOME/hyprlab/config/rofi/power-menu.rasi" -i -no-custom)

if [[ -n "$chosen" ]]; then
    handle_selection "$chosen"
fi