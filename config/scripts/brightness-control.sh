#!/bin/bash

current_brightness=$(brightnessctl info | grep -o '[0-9]\+%' | sed 's/%//')
device_name=$(brightnessctl info | head -n1 | sed "s/Device '\([^']*\)'.*/\1/")

create_brightness_menu() {
    local brightness=$1
    
    menu_options=""
    
    local bar_length=30
    local filled=$((brightness * bar_length / 100))
    local empty=$((bar_length - filled))
    
    local current_bar=""
    for ((i=0; i<filled; i++)); do
        current_bar+="█"
    done
    for ((i=0; i<empty; i++)); do
        current_bar+="░"
    done
    
    local current_icon="🔅"
    if [[ $brightness -gt 75 ]]; then
        current_icon="🔆"
    elif [[ $brightness -gt 50 ]]; then
        current_icon="☀️"
    elif [[ $brightness -gt 25 ]]; then
        current_icon="🌤️"
    elif [[ $brightness -gt 10 ]]; then
        current_icon="🔅"
    else
        current_icon="🌑"
    fi
    
    menu_options+="$current_icon Brightness: ${brightness}% [$current_bar]\n"
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    menu_options+="💡 Click to set brightness level:\n"
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    
    for level in 100 95 90 85 80 75 70 65 60 55 50 45 40 35 30 25 20 15 10 5 1; do
        local level_filled=$((level * bar_length / 100))
        local level_empty=$((bar_length - level_filled))
        
        local level_bar=""
        for ((i=0; i<level_filled; i++)); do
            level_bar+="█"
        done
        for ((i=0; i<level_empty; i++)); do
            level_bar+="░"
        done
        
        local icon="🔅"
        if [[ $level -gt 75 ]]; then
            icon="🔆"
        elif [[ $level -gt 50 ]]; then
            icon="☀️"
        elif [[ $level -gt 25 ]]; then
            icon="🌤️"
        elif [[ $level -gt 10 ]]; then
            icon="🔅"
        else
            icon="🌑"
        fi
        
        if [[ $level -eq $brightness ]]; then
            menu_options+="► $icon ${level}% [$level_bar] ◄ CURRENT\n"
        else
            menu_options+="  $icon ${level}% [$level_bar]\n"
        fi
    done
    
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    menu_options+="🔧 Quick Adjustments:\n"
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    menu_options+="⬆️ Increase +10%\n"
    menu_options+="⬇️ Decrease -10%\n"
    menu_options+="⬆️ Increase +5%\n"
    menu_options+="⬇️ Decrease -5%\n"
    menu_options+="⬆️ Increase +1%\n"
    menu_options+="⬇️ Decrease -1%\n"
    
    echo -e "$menu_options"
}

create_brightness_theme() {
    cat > "$HOME/hyprlab/config/rofi/brightness-control.rasi" << 'EOF'
/**
 * Brightness Control Theme - Catppuccin Mocha
 */

* {
    bg-col:             rgba(30, 30, 46, 100%);
    bg-col-light:       rgba(49, 50, 68, 100%);
    border-col:         rgba(249, 226, 175, 100%);
    selected-col:       rgba(249, 226, 175, 100%);
    yellow:             rgba(249, 226, 175, 100%);
    fg-col:             rgba(205, 214, 244, 100%);
    grey:               rgba(108, 112, 134, 100%);
    accent:             rgba(245, 194, 231, 100%);
    
    font: "JetBrainsMono Nerd Font 11";
    background-color: transparent;
}

window {
    transparency: "real";
    location: northeast;
    anchor: northeast;
    fullscreen: false;
    width: 400px;
    height: 450px;
    x-offset: -10px;
    y-offset: 48px;
    enabled: true;
    margin: 0px;
    padding: 0px;
    border: 2px solid;
    border-radius: 12px;
    border-color: @border-col;
    background-color: @bg-col;
    cursor: "default";
}

mainbox {
    enabled: true;
    spacing: 8px;
    margin: 0px;
    padding: 8px;
    border: 0px solid;
    border-radius: 0px;
    border-color: @border-col;
    background-color: transparent;
    children: [ "inputbar", "listview" ];
}

inputbar {
    enabled: true;
    spacing: 8px;
    margin: 0px 0px 8px 0px;
    padding: 8px;
    border: 0px solid;
    border-radius: 8px;
    border-color: @border-col;
    background-color: @bg-col-light;
    text-color: @fg-col;
    children: [ "prompt", "entry" ];
}

prompt {
    enabled: true;
    padding: 6px 12px;
    border-radius: 6px;
    background-color: @yellow;
    text-color: @bg-col;
}

entry {
    enabled: true;
    padding: 6px;
    border-radius: 6px;
    background-color: transparent;
    text-color: @fg-col;
    cursor: text;
    placeholder: "Brightness controls...";
    placeholder-color: @grey;
}

listview {
    enabled: true;
    columns: 1;
    lines: 15;
    cycle: true;
    dynamic: true;
    scrollbar: false;
    layout: vertical;
    reverse: false;
    fixed-height: true;
    fixed-columns: true;
    spacing: 1px;
    margin: 0px;
    padding: 0px;
    border: 0px solid;
    border-radius: 0px;
    border-color: @border-col;
    background-color: transparent;
    text-color: @fg-col;
    cursor: "default";
}

element {
    enabled: true;
    spacing: 8px;
    margin: 0px;
    padding: 6px 12px;
    border: 0px solid;
    border-radius: 6px;
    border-color: @border-col;
    background-color: transparent;
    text-color: @fg-col;
    cursor: pointer;
}

element normal.normal {
    background-color: transparent;
    text-color: @fg-col;
}

element selected.normal {
    background-color: @selected-col;
    text-color: @bg-col;
}

element-text {
    background-color: transparent;
    text-color: inherit;
    highlight: inherit;
    cursor: inherit;
}

element-icon {
    background-color: transparent;
    text-color: inherit;
    size: 16px;
    cursor: inherit;
}
EOF
}

if [[ ! -f "$HOME/hyprlab/config/rofi/brightness-control.rasi" ]]; then
    create_brightness_theme
fi

chosen=$(create_brightness_menu "$current_brightness" | rofi -dmenu -p "💡 Brightness" -theme "$HOME/hyprlab/config/rofi/brightness-control.rasi" -i -no-custom)

case "$chosen" in
    *"% ["*)
        brightness=$(echo "$chosen" | grep -o '[0-9]\+%' | head -1 | sed 's/%//')
        if [[ -n "$brightness" ]]; then
            brightnessctl set "${brightness}%"
            
            if [[ $brightness -gt 75 ]]; then
                notify-send "Display" "🔆 Brightness: ${brightness}%"
            elif [[ $brightness -gt 50 ]]; then
                notify-send "Display" "☀️ Brightness: ${brightness}%"
            elif [[ $brightness -gt 25 ]]; then
                notify-send "Display" "🌤️ Brightness: ${brightness}%"
            elif [[ $brightness -gt 10 ]]; then
                notify-send "Display" "🔅 Brightness: ${brightness}%"
            else
                notify-send "Display" "🌑 Brightness: ${brightness}%"
            fi
        fi
        ;;
    "⬆️ Increase +10%")
        brightnessctl set +10%
        new_brightness=$(brightnessctl info | grep -o '[0-9]\+%' | sed 's/%//')
        notify-send "Display" "🔆 Brightness: ${new_brightness}%"
        ;;
    "⬇️ Decrease -10%")
        brightnessctl set 10%-
        new_brightness=$(brightnessctl info | grep -o '[0-9]\+%' | sed 's/%//')
        notify-send "Display" "🔅 Brightness: ${new_brightness}%"
        ;;
    "⬆️ Increase +5%")
        brightnessctl set +5%
        new_brightness=$(brightnessctl info | grep -o '[0-9]\+%' | sed 's/%//')
        notify-send "Display" "🔆 Brightness: ${new_brightness}%"
        ;;
    "⬇️ Decrease -5%")
        brightnessctl set 5%-
        new_brightness=$(brightnessctl info | grep -o '[0-9]\+%' | sed 's/%//')
        notify-send "Display" "🔅 Brightness: ${new_brightness}%"
        ;;
    "⬆️ Increase +1%")
        brightnessctl set +1%
        new_brightness=$(brightnessctl info | grep -o '[0-9]\+%' | sed 's/%//')
        notify-send "Display" "🔆 Brightness: ${new_brightness}%"
        ;;
    "⬇️ Decrease -1%")
        brightnessctl set 1%-
        new_brightness=$(brightnessctl info | grep -o '[0-9]\+%' | sed 's/%//')
        notify-send "Display" "🔅 Brightness: ${new_brightness}%"
        ;;
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"|"💡 Click to set brightness level:"|"🔧 Quick Adjustments:"|*"Brightness: "*)
        ;;
esac