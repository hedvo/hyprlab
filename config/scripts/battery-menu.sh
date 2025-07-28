#!/bin/bash

get_battery_info() {
    local battery_path=$(upower -e | grep 'BAT' | head -1)
    if [[ -n "$battery_path" ]]; then
        upower -i "$battery_path"
    else
        echo "No battery found"
    fi
}

battery_info=$(get_battery_info)
battery_percentage=$(echo "$battery_info" | grep -o '[0-9]\+%' | head -1 | sed 's/%//')
battery_state=$(echo "$battery_info" | grep 'state:' | awk '{print $2}')
battery_capacity=$(echo "$battery_info" | grep 'capacity:' | awk '{print $2}' | sed 's/%//')
battery_cycles=$(echo "$battery_info" | grep 'charge-cycles:' | awk '{print $2}')
battery_energy=$(echo "$battery_info" | grep 'energy:' | head -1 | awk '{print $2, $3}')
battery_voltage=$(echo "$battery_info" | grep 'voltage:' | awk '{print $2, $3}')
battery_technology=$(echo "$battery_info" | grep 'technology:' | awk '{print $2}')

current_power_profile=$(powerprofilesctl get 2>/dev/null || echo "not-available")

create_battery_bar() {
    local percentage=$1
    local bar_length=30
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

get_battery_icon() {
    local percentage=$1
    local state=$2
    
    if [[ "$state" == "charging" ]]; then
        echo "󰂄"
    elif [[ "$state" == "fully-charged" ]]; then
        echo "󰁹"
    elif [[ $percentage -gt 80 ]]; then
        echo "󰁹"
    elif [[ $percentage -gt 60 ]]; then
        echo "󰁹"
    elif [[ $percentage -gt 40 ]]; then
        echo "󰁹"
    elif [[ $percentage -gt 20 ]]; then
        echo "󰂎"
    else
        echo "󰂎"
    fi
}

create_battery_menu() {
    local percentage=$1
    local state=$2
    local capacity=$3
    
    menu_options=""
    
    local battery_icon=$(get_battery_icon "$percentage" "$state")
    local battery_bar=$(create_battery_bar "$percentage")
    
    menu_options+="$battery_icon Battery: ${percentage}% [$battery_bar]\n"
    menu_options+="󰄰 Status: $(echo "$state" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')\n"
    
    if [[ -n "$capacity" ]]; then
        menu_options+="󱊝 Health: ${capacity}% capacity\n"
    fi
    
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    menu_options+="󰁹 Battery Details:\n"
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    
    if [[ -n "$battery_energy" ]]; then
        menu_options+="󰒡 Energy: $battery_energy\n"
    fi
    if [[ -n "$battery_voltage" ]]; then
        menu_options+="󰂄 Voltage: $battery_voltage\n"
    fi
    if [[ -n "$battery_cycles" ]]; then
        menu_options+="󰔄 Charge Cycles: $battery_cycles\n"
    fi
    if [[ -n "$battery_technology" ]]; then
        menu_options+="󰇪 Technology: $(echo "$battery_technology" | sed 's/-/ /g')\n"
    fi
    
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    menu_options+="󰏐 Power Management:\n"
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    
    if [[ "$current_power_profile" != "not-available" ]]; then
        menu_options+="󰆪 Current Profile: $(echo "$current_power_profile" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')\n"
        menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        
        if [[ "$current_power_profile" != "performance" ]]; then
            menu_options+="󰚀 Performance Mode\n"
        fi
        if [[ "$current_power_profile" != "balanced" ]]; then
            menu_options+="󰈖 Balanced Mode\n"
        fi
        if [[ "$current_power_profile" != "power-saver" ]]; then
            menu_options+="󰁹 Power Saver Mode\n"
        fi
        menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    fi
    
    menu_options+="󰊴 Suspend System\n"
    menu_options+="󰊲 Hibernate System\n"
    menu_options+="󰆊 Power Statistics\n"
    menu_options+="󰏗 Power Settings\n"
    
    echo -e "$menu_options"
}

show_battery_stats() {
    stats_options=""
    stats_options+="󰆊 Battery Statistics:\n"
    stats_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    
    local power_history=$(upower -i $(upower -e | grep 'BAT') | grep -E 'energy-rate|time')
    if [[ -n "$power_history" ]]; then
        echo "$power_history" | while read line; do
            stats_options+="$line\n"
        done
    fi
    
    stats_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    stats_options+="󰆕 Back to Battery Menu\n"
    
    echo -e "$stats_options"
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
        "󰊲 Hibernate System")
            systemctl hibernate
            ;;
        "󰆊 Power Statistics")
            chosen_stats=$(show_battery_stats | rofi -dmenu -p "📊 Stats" -theme "$HOME/.config/rofi/battery-menu.rasi" -i -no-custom)
            if [[ "$chosen_stats" == "󰆕 Back to Battery Menu" ]]; then
                $0
            fi
            ;;
        "󰏗 Power Settings")
            if command -v gnome-power-statistics &> /dev/null; then
                gnome-power-statistics &
            elif command -v powertop &> /dev/null; then
                kitty powertop &
            else
                notify-send "Power Settings" "No power management GUI found"
            fi
            ;;
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"|"󰁹 Battery Details:"|"󰏐 Power Management:"|*"Battery: "*|*"Status: "*|*"Health: "*|*"Energy: "*|*"Voltage: "*|*"Charge Cycles: "*|*"Technology: "*|*"Current Profile: "*)
            ;;
    esac
}

chosen=$(create_battery_menu "$battery_percentage" "$battery_state" "$battery_capacity" | rofi -dmenu -p "🔋 Battery" -theme "$HOME/.config/rofi/battery-menu.rasi" -i -no-custom)

handle_selection "$chosen"