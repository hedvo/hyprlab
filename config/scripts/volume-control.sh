#!/bin/bash

current_volume=$(pactl get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print $5}' | sed 's/%//')

is_muted=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -q "yes" && echo "true" || echo "false")

create_volume_bar() {
    local vol=$1
    local bar_length=20
    local filled=$((vol * bar_length / 100))
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

menu_options=""

if [[ "$is_muted" == "true" ]]; then
    menu_options+="🔊 Unmute\n"
    volume_bar="$(create_volume_bar 0)"
    menu_options+="🔇 Volume: MUTED [$volume_bar]\n"
else
    menu_options+="🔇 Mute\n"
    volume_bar="$(create_volume_bar $current_volume)"
    menu_options+="🔊 Volume: ${current_volume}% [$volume_bar]\n"
fi

menu_options+="──────────────────────────\n"

menu_options+="🔈 10% Volume\n"
menu_options+="🔉 25% Volume\n" 
menu_options+="🔉 50% Volume\n"
menu_options+="🔊 75% Volume\n"
menu_options+="🔊 100% Volume\n"

menu_options+="──────────────────────────\n"

menu_options+="➕ Volume +5%\n"
menu_options+="➖ Volume -5%\n"
menu_options+="➕ Volume +1%\n"
menu_options+="➖ Volume -1%\n"

menu_options+="──────────────────────────\n"
menu_options+="🎚️ Audio Settings\n"

chosen=$(echo -e "$menu_options" | rofi -dmenu -p "🎵 Audio" -theme "$HOME/.config/rofi/volume-control.rasi")

case "$chosen" in
    "🔊 Unmute")
        pactl set-sink-mute @DEFAULT_SINK@ false
        notify-send "Audio" "🔊 Unmuted"
        ;;
    "🔇 Mute")
        pactl set-sink-mute @DEFAULT_SINK@ true
        notify-send "Audio" "🔇 Muted"
        ;;
    "🔈 10% Volume")
        pactl set-sink-volume @DEFAULT_SINK@ 10%
        notify-send "Audio" "🔈 Volume set to 10%"
        ;;
    "🔉 25% Volume")
        pactl set-sink-volume @DEFAULT_SINK@ 25%
        notify-send "Audio" "🔉 Volume set to 25%"
        ;;
    "🔉 50% Volume")
        pactl set-sink-volume @DEFAULT_SINK@ 50%
        notify-send "Audio" "🔉 Volume set to 50%"
        ;;
    "🔊 75% Volume")
        pactl set-sink-volume @DEFAULT_SINK@ 75%
        notify-send "Audio" "🔊 Volume set to 75%"
        ;;
    "🔊 100% Volume")
        pactl set-sink-volume @DEFAULT_SINK@ 100%
        notify-send "Audio" "🔊 Volume set to 100%"
        ;;
    "➕ Volume +5%")
        pactl set-sink-volume @DEFAULT_SINK@ +5%
        new_vol=$(pactl get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print $5}' | sed 's/%//')
        notify-send "Audio" "🔊 Volume: ${new_vol}%"
        ;;
    "➖ Volume -5%")
        pactl set-sink-volume @DEFAULT_SINK@ -5%
        new_vol=$(pactl get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print $5}' | sed 's/%//')
        notify-send "Audio" "🔉 Volume: ${new_vol}%"
        ;;
    "➕ Volume +1%")
        pactl set-sink-volume @DEFAULT_SINK@ +1%
        new_vol=$(pactl get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print $5}' | sed 's/%//')
        notify-send "Audio" "🔊 Volume: ${new_vol}%"
        ;;
    "➖ Volume -1%")
        pactl set-sink-volume @DEFAULT_SINK@ -1%
        new_vol=$(pactl get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print $5}' | sed 's/%//')
        notify-send "Audio" "🔉 Volume: ${new_vol}%"
        ;;
    "🎚️ Audio Settings")
        pavucontrol &
        ;;
    "──────────────────────────"|"🔊 Volume: "*|"🔇 Volume: "*)
        ;;
esac