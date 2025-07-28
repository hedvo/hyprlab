#!/bin/bash

current_time=$(date '+%I:%M %p')
current_date=$(date '+%A, %B %d, %Y')
current_timezone=$(date '+%Z %z')
current_week=$(date '+Week %V')
current_day_of_year=$(date '+Day %j of %Y')
current_unix=$(date '+%s')

current_month_cal=$(cal -m | sed 's/^/    /')

create_clock_menu() {
    menu_options=""
    
    menu_options+="󰥔 Time: $current_time\n"
    menu_options+="󰃅 Date: $current_date\n"
    menu_options+="󰗐 Timezone: $current_timezone\n"
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    
    menu_options+="󰆊 Time Information:\n"
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    menu_options+="󰃆 $current_week\n"
    menu_options+="󰄺 $current_day_of_year\n"
    menu_options+="󰤱 Unix Timestamp: $current_unix\n"
    
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    menu_options+="󰃅 Calendar View:\n"
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"

    current_day=$(date '+%d' | sed 's/^0//')
    calendar_with_highlight=$(cal -m | sed "s/\b$current_day\b/►$current_day◄/g" | sed 's/^/    /')
    menu_options+="$calendar_with_highlight\n"
    
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    menu_options+="󰏐 Time & Date Settings:\n"
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    menu_options+="󰔄 Refresh Time\n"
    menu_options+="󰤰 Set Timezone\n"
    menu_options+="󰔱 Open Calendar App\n"
    menu_options+="󰤲 Timer & Stopwatch\n"
    menu_options+="󰗐 World Clock\n"
    
    echo -e "$menu_options"
}

show_timezone_menu() {
    timezone_options=""
    timezone_options+="󰗺 America/New_York (EST/EDT)\n"
    timezone_options+="󰗺 America/Chicago (CST/CDT)\n"
    timezone_options+="󰗺 America/Denver (MST/MDT)\n"
    timezone_options+="󰗺 America/Los_Angeles (PST/PDT)\n"
    timezone_options+="󰗺 Europe/London (GMT/BST)\n"
    timezone_options+="󰗺 Europe/Paris (CET/CEST)\n"
    timezone_options+="󰗺 Europe/Berlin (CET/CEST)\n"
    timezone_options+="󰗺 Asia/Kolkata (IST)\n"
    timezone_options+="󰗺 Asia/Tokyo (JST)\n"
    timezone_options+="󰗺 Asia/Shanghai (CST)\n"
    timezone_options+="󰗺 Australia/Sydney (AEST/AEDT)\n"
    timezone_options+="󰆕 Back to Clock Menu\n"
    
    echo -e "$timezone_options"
}

show_world_clock() {
    world_options=""
    world_options+="󰗐 World Clock:\n"
    world_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    world_options+="󰗺 New York: $(TZ='America/New_York' date '+%I:%M %p')\n"
    world_options+="󰗺 Los Angeles: $(TZ='America/Los_Angeles' date '+%I:%M %p')\n"
    world_options+="󰗺 London: $(TZ='Europe/London' date '+%I:%M %p')\n"
    world_options+="󰗺 Paris: $(TZ='Europe/Paris' date '+%I:%M %p')\n"
    world_options+="󰗺 Berlin: $(TZ='Europe/Berlin' date '+%I:%M %p')\n"
    world_options+="󰗺 Mumbai: $(TZ='Asia/Kolkata' date '+%I:%M %p')\n"
    world_options+="󰗺 Tokyo: $(TZ='Asia/Tokyo' date '+%I:%M %p')\n"
    world_options+="󰗺 Shanghai: $(TZ='Asia/Shanghai' date '+%I:%M %p')\n"
    world_options+="󰗺 Sydney: $(TZ='Australia/Sydney' date '+%I:%M %p')\n"
    world_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    world_options+="󰆕 Back to Clock Menu\n"
    
    echo -e "$world_options"
}

handle_selection() {
    case "$1" in
        "󰔄 Refresh Time")
            notify-send "Clock" "󰔄 Time refreshed: $(date '+%I:%M %p')"
            ;;
        "󰤰 Set Timezone")
            chosen_tz=$(show_timezone_menu | rofi -dmenu -p "🌍 Timezone" -theme "$HOME/.config/rofi/clock-menu.rasi" -i -no-custom)
            case "$chosen_tz" in
                *"America/New_York"*)
                    notify-send "Timezone" "Note: Use system settings to change timezone permanently"
                    ;;
                *"America/Chicago"*)
                    notify-send "Timezone" "Note: Use system settings to change timezone permanently"
                    ;;
                "󰆕 Back to Clock Menu")
                    $0
                    ;;
            esac
            ;;
        "󰔱 Open Calendar App")
            if command -v gnome-calendar &> /dev/null; then
                gnome-calendar &
            elif command -v kcalc &> /dev/null; then
                kcalc &
            else
                notify-send "Calendar" "No calendar application found"
            fi
            ;;
        "󰤲 Timer & Stopwatch")
            if command -v gnome-clocks &> /dev/null; then
                gnome-clocks &
            else
                notify-send "Timer" "No timer application found"
            fi
            ;;
        "󰗐 World Clock")
            chosen_world=$(show_world_clock | rofi -dmenu -p "🌍 World Clock" -theme "$HOME/.config/rofi/clock-menu.rasi" -i -no-custom)
            if [[ "$chosen_world" == "󰆕 Back to Clock Menu" ]]; then
                $0
            fi
            ;;
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"|"󰆊 Time Information:"|"󰃅 Calendar View:"|"󰏐 Time & Date Settings:"|"󰗐 World Clock:"|*"Time: "*|*"Date: "*|*"Timezone: "*|*"Week "*|*"Day "*|*"Unix Timestamp: "*)
            ;;
    esac
}

chosen=$(create_clock_menu | rofi -dmenu -p "🕐 Clock" -theme "$HOME/.config/rofi/clock-menu.rasi" -i -no-custom)

handle_selection "$chosen"