#!/bin/bash


create_battery_theme() {
    cat > "$HOME/hyprlab/config/rofi/battery-menu.rasi" << 'EOF'
* {
    bg-col:             rgba(30, 30, 46, 100%);
    bg-col-light:       rgba(49, 50, 68, 100%);
    border-col:         rgba(250, 179, 135, 100%);
    selected-col:       rgba(250, 179, 135, 100%);
    fg-col:             rgba(205, 214, 244, 100%);
    
    font: "JetBrainsMono Nerd Font 12";
    background-color: transparent;
}

window {
    transparency: "real";
    location: northeast;
    anchor: northeast;
    width: 400px;
    height: 350px;
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
    lines: 12;
    spacing: 2px;
    background-color: transparent;
}

element {
    padding: 6px 12px;
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

get_battery_info() {
    local battery_path=$(upower -e | grep 'BAT' | head -1)
    if [[ -n "$battery_path" ]]; then
        upower -i "$battery_path"
    else
        echo "No battery found"
    fi
}

get_battery_icon() {
    local percentage=$1
    local state=$2
    
    if [[ "$state" == "charging" ]]; then
        echo "󰂄"
    elif [[ "$state" == "fully-charged" ]]; then
        echo "󰁹"
    elif [[ $percentage -gt 80 ]]; then
        echo "󰂂"
    elif [[ $percentage -gt 60 ]]; then
        echo "󰂀"
    elif [[ $percentage -gt 40 ]]; then
        echo "󰁾"
    elif [[ $percentage -gt 20 ]]; then
        echo "󰁼"
    else
        echo "󰁺"
    fi
}

create_battery_bar() {
    local percentage=$1
    local bar_length=25
    local filled=$((percentage * bar_length / 100))
    local empty=$((bar_length - filled))
    
    local bar=""
    for ((i=0; i<filled; i++)); do
        bar+="█"
    done
    for ((i=0; i<empty; i++)); do
        bar+="░"
    done
    echo "$bar"
}

create_battery_menu() {
    local battery_info=$(get_battery_info)
    local battery_percentage=$(echo "$battery_info" | grep -o '[0-9]\+%' | head -1 | sed 's/%//')
    local battery_state=$(echo "$battery_info" | grep 'state:' | awk '{print $2}')
    local battery_capacity=$(echo "$battery_info" | grep 'capacity:' | awk '{print $2}' | sed 's/%//')
    local battery_energy=$(echo "$battery_info" | grep 'energy:' | head -1 | awk '{print $2, $3}')
    local battery_technology=$(echo "$battery_info" | grep 'technology:' | awk '{print $2}')
    
    local battery_icon=$(get_battery_icon "$battery_percentage" "$battery_state")
    local battery_bar=$(create_battery_bar "$battery_percentage")
    local current_power_profile=$(powerprofilesctl get 2>/dev/null || echo "not-available")
    
    echo "$battery_icon Battery: ${battery_percentage}% [$battery_bar]"
    echo "󰄰 Status: $(echo "$battery_state" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')"
    
    if [[ -n "$battery_capacity" ]]; then
        echo "󱊝 Health: ${battery_capacity}% capacity"
    fi
    
    if [[ -n "$battery_energy" ]]; then
        echo "󰒡 Energy: $battery_energy"
    fi
    
    if [[ -n "$battery_technology" ]]; then
        echo "󰇪 Technology: $(echo "$battery_technology" | sed 's/-/ /g')"
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "󰏐 Power Management:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ "$current_power_profile" != "not-available" ]]; then
        echo "󰆪 Current: $(echo "$current_power_profile" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')"
        
        if [[ "$current_power_profile" != "performance" ]]; then
            echo "󰚀 Performance Mode"
        fi
        if [[ "$current_power_profile" != "balanced" ]]; then
            echo "󰈖 Balanced Mode"
        fi
        if [[ "$current_power_profile" != "power-saver" ]]; then
            echo "󰁹 Power Saver Mode"
        fi
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "󰊴 Suspend System"
    echo "󰆊 Battery Statistics"
}

handle_selection() {
    case "$1" in
        "󰚀 Performance Mode")
            if command -v powerprofilesctl &> /dev/null; then
                powerprofilesctl set performance
                notify-send "Power Management" "󰚀 Performance mode activated"
            else
                notify-send "Power Management" "❌ Power profiles not available"
            fi
            ;;
        "󰈖 Balanced Mode")
            if command -v powerprofilesctl &> /dev/null; then
                powerprofilesctl set balanced
                notify-send "Power Management" "󰈖 Balanced mode activated"
            else
                notify-send "Power Management" "❌ Power profiles not available"
            fi
            ;;
        "󰁹 Power Saver Mode")
            if command -v powerprofilesctl &> /dev/null; then
                powerprofilesctl set power-saver
                notify-send "Power Management" "󰁹 Power saver mode activated"
            else
                notify-send "Power Management" "❌ Power profiles not available"
            fi
            ;;
        "󰊴 Suspend System")
            systemctl suspend
            ;;
        "󰆊 Battery Statistics")
            if command -v gnome-power-statistics &> /dev/null; then
                gnome-power-statistics &
            elif command -v powertop &> /dev/null; then
                kitty powertop &
            else
                notify-send "Battery" "No power statistics tool found"
            fi
            ;;
    esac
}

if [[ ! -f "$HOME/hyprlab/config/rofi/battery-menu.rasi" ]]; then
    create_battery_theme
fi

chosen=$(create_battery_menu | rofi -dmenu -p "🔋 Battery" -theme "$HOME/hyprlab/config/rofi/battery-menu.rasi" -i -no-custom)

if [[ -n "$chosen" ]]; then
    handle_selection "$chosen"
fi