#!/bin/bash

current_volume=$(pactl get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print $5}' | sed 's/%//')
is_muted=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -q "yes" && echo "true" || echo "false")

create_volume_menu() {
    local vol=$1
    local muted=$2
    
    menu_options=""
    
    if [[ "$muted" == "true" ]]; then
        menu_options+="🔊 Unmute (Currently Muted)\n"
    else
        menu_options+="🔇 Mute (Currently ${vol}%)\n"
    fi
    
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    
    local bar_length=30
    local filled=$((vol * bar_length / 100))
    local empty=$((bar_length - filled))
    
    local current_bar=""
    for ((i=0; i<filled; i++)); do
        current_bar+="█"
    done
    for ((i=0; i<empty; i++)); do
        current_bar+="░"
    done
    
    if [[ "$muted" == "true" ]]; then
        menu_options+="🔇 Volume: MUTED [$current_bar] 0%\n"
    else
        menu_options+="🔊 Volume: ${vol}% [$current_bar]\n"
    fi
    
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    menu_options+="📊 Click to set volume level:\n"
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    
    for level in 100 95 90 85 80 75 70 65 60 55 50 45 40 35 30 25 20 15 10 5 0; do
        local level_filled=$((level * bar_length / 100))
        local level_empty=$((bar_length - level_filled))
        
        local level_bar=""
        for ((i=0; i<level_filled; i++)); do
            level_bar+="█"
        done
        for ((i=0; i<level_empty; i++)); do
            level_bar+="░"
        done
        
        local icon="🔈"
        if [[ $level -gt 66 ]]; then
            icon="🔊"
        elif [[ $level -gt 33 ]]; then
            icon="🔉"
        elif [[ $level -eq 0 ]]; then
            icon="🔇"
        fi
        
        if [[ $level -eq $vol ]] && [[ "$muted" == "false" ]]; then
            menu_options+="► $icon ${level}% [$level_bar] ◄ CURRENT\n"
        else
            menu_options+="  $icon ${level}% [$level_bar]\n"
        fi
    done
    
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    menu_options+="⚙️ Advanced Audio Settings\n"
    
    echo -e "$menu_options"
}

chosen=$(create_volume_menu "$current_volume" "$is_muted" | rofi -dmenu -p "🎵 Volume" -theme "$HOME/.config/rofi/volume-control.rasi" -i -no-custom)

case "$chosen" in
    "🔊 Unmute"*)
        pactl set-sink-mute @DEFAULT_SINK@ false
        notify-send "Audio" "🔊 Unmuted"
        ;;
    "🔇 Mute"*)
        pactl set-sink-mute @DEFAULT_SINK@ true
        notify-send "Audio" "🔇 Muted"
        ;;
    "⚙️ Advanced Audio Settings")
        pavucontrol &
        ;;
    *"% ["*)
        volume=$(echo "$chosen" | grep -o '[0-9]\+%' | head -1 | sed 's/%//')
        if [[ -n "$volume" ]]; then
            pactl set-sink-volume @DEFAULT_SINK@ "${volume}%"
            
            if [[ $volume -eq 0 ]]; then
                notify-send "Audio" "🔇 Volume muted (0%)"
            elif [[ $volume -le 33 ]]; then
                notify-send "Audio" "🔈 Volume: ${volume}%"
            elif [[ $volume -le 66 ]]; then
                notify-send "Audio" "🔉 Volume: ${volume}%"
            else
                notify-send "Audio" "🔊 Volume: ${volume}%"
            fi
        fi
        ;;
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"|"📊 Click to set volume level:"|"🔊 Volume: "*|"🔇 Volume: "*)
        ;;
esac