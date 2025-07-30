#!/bin/bash

create_date_theme() {
    cat > "$HOME/hyprlab/config/rofi/date-menu.rasi" << 'EOF'
* {
    bg-col:             rgba(30, 30, 46, 100%);
    bg-col-light:       rgba(49, 50, 68, 100%);
    border-col:         rgba(137, 220, 235, 100%);
    selected-col:       rgba(137, 220, 235, 100%);
    fg-col:             rgba(205, 214, 244, 100%);
    
    font: "JetBrainsMono Nerd Font 12";
    background-color: transparent;
}

window {
    transparency: "real";
    location: northeast;
    anchor: northeast;
    width: 350px;
    height: 300px;
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
    lines: 10;
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

create_date_menu() {
    local current_time=$(date '+%I:%M %p')
    local current_date=$(date '+%A, %B %d, %Y')
    local current_timezone=$(date '+%Z %z')
    local current_week=$(date '+Week %V')
    
    echo "󰥔 Time: $current_time"
    echo "󰃅 Date: $current_date"
    echo "󰗐 Timezone: $current_timezone"
    echo "󰃆 $current_week"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "󰔄 Refresh Time"
    echo "󰔱 Open Calendar"
    echo "󰗐 World Clock"
}

show_world_clock() {
    echo "🌍 World Clock:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🗽 New York: $(TZ='America/New_York' date '+%I:%M %p')"
    echo "🌉 Los Angeles: $(TZ='America/Los_Angeles' date '+%I:%M %p')"
    echo "🏰 London: $(TZ='Europe/London' date '+%I:%M %p')"
    echo "🗼 Paris: $(TZ='Europe/Paris' date '+%I:%M %p')"
    echo "🍜 Tokyo: $(TZ='Asia/Tokyo' date '+%I:%M %p')"
    echo "🕌 Mumbai: $(TZ='Asia/Kolkata' date '+%I:%M %p')"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "󰆕 Back to Clock Menu"
}

handle_selection() {
    case "$1" in
        "󰔄 Refresh Time")
            notify-send "Clock" "󰔄 Time refreshed: $(date '+%I:%M %p')"
            ;;
        "󰔱 Open Calendar")
            if command -v gnome-calendar &> /dev/null; then
                gnome-calendar &
            elif command -v korganizer &> /dev/null; then
                korganizer &
            else
                notify-send "Calendar" "No calendar application found"
            fi
            ;;
        "󰗐 World Clock")
            chosen_world=$(show_world_clock | rofi -dmenu -p "🌍 World Clock" -theme "$HOME/hyprlab/config/rofi/date-menu.rasi" -i -no-custom)
            if [[ "$chosen_world" == "󰆕 Back to Clock Menu" ]]; then
                $0
            fi
            ;;
    esac
}

if [[ ! -f "$HOME/hyprlab/config/rofi/date-menu.rasi" ]]; then
    create_date_theme
fi

chosen=$(create_date_menu | rofi -dmenu -p "🕐 Date & Time" -theme "$HOME/hyprlab/config/rofi/date-menu.rasi" -i -no-custom)

if [[ -n "$chosen" ]]; then
    handle_selection "$chosen"
fi