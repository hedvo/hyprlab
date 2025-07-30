#!/bin/bash

create_volume_theme() {
    cat > "$HOME/hyprlab/config/rofi/volume-control.rasi" << 'EOF'
* {
    bg-col:             rgba(30, 30, 46, 100%);
    bg-col-light:       rgba(49, 50, 68, 100%);
    border-col:         rgba(245, 194, 231, 100%);
    selected-col:       rgba(245, 194, 231, 100%);
    fg-col:             rgba(205, 214, 244, 100%);
    
    font: "JetBrainsMono Nerd Font 12";
    background-color: transparent;
}

window {
    transparency: "real";
    location: northeast;
    anchor: northeast;
    width: 420px;
    height: 400px;
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
    lines: 15;
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

if [[ ! -f "$HOME/hyprlab/config/rofi/volume-control.rasi" ]]; then
    create_volume_theme
fi

chosen=$(create_volume_menu "$current_volume" "$is_muted" | rofi -dmenu -p "🎵 Volume" -theme "$HOME/hyprlab/config/rofi/volume-control.rasi" -i -no-custom)

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