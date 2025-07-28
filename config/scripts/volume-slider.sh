#!/bin/bash

current_volume=$(pactl get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print $5}' | sed 's/%//')
is_muted=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -q "yes" && echo "true" || echo "false")

create_interactive_bar() {
    local current_vol=$1
    local segments=20
    local segment_value=$((100 / segments))
    
    menu_options=""
    
    if [[ "$is_muted" == "true" ]]; then
        menu_options+="🔊 Unmute (Currently Muted)\n"
    else
        menu_options+="🔇 Mute (Currently ${current_vol}%)\n"
    fi
    
    menu_options+="──────────────────────────────────────\n"
    menu_options+="📊 Click on volume level to set:\n"
    menu_options+="──────────────────────────────────────\n"
    
    for ((i=1; i<=segments; i++)); do
        local vol_level=$((i * segment_value))
        local filled=$((current_vol >= vol_level ? 1 : 0))
        
        local bar=""
        for ((j=1; j<=i; j++)); do
            bar+="█"
        done
        for ((j=i+1; j<=segments; j++)); do
            bar+="░"
        done
        
        if [[ $filled -eq 1 ]]; then
            menu_options+="🔊 ${vol_level}% [$bar] ← Current\n"
        else
            menu_options+="🔈 ${vol_level}% [$bar]\n"
        fi
    done
    
    menu_options+="──────────────────────────────────────\n"
    menu_options+="🎚️ Advanced Audio Settings\n"
    
    echo -e "$menu_options"
}

chosen=$(create_interactive_bar "$current_volume" | rofi -dmenu -p "🎵 Volume Slider" -theme "$HOME/.config/rofi/volume-control.rasi" -i)

case "$chosen" in
    "🔊 Unmute"*)
        pactl set-sink-mute @DEFAULT_SINK@ false
        notify-send "Audio" "🔊 Unmuted"
        ;;
    "🔇 Mute"*)
        pactl set-sink-mute @DEFAULT_SINK@ true
        notify-send "Audio" "🔇 Muted"
        ;;
    "🎚️ Advanced Audio Settings")
        pavucontrol &
        ;;
    *"% ["*)
        volume=$(echo "$chosen" | grep -o '[0-9]\+%' | head -1 | sed 's/%//')
        if [[ -n "$volume" ]]; then
            pactl set-sink-volume @DEFAULT_SINK@ "${volume}%"
            notify-send "Audio" "🔊 Volume set to ${volume}%"
        fi
        ;;
    "📊 Click on volume level to set:"|"──────────────────────────────────────")
        ;;
esac