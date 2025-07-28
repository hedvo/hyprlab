#!/bin/bash

is_spotify_running() {
    pgrep -x spotify > /dev/null
}

get_detailed_track_info() {
    if ! is_spotify_running || ! command -v playerctl &> /dev/null; then
        return
    fi
    
    local artist=$(playerctl -p spotify metadata artist 2>/dev/null)
    local title=$(playerctl -p spotify metadata title 2>/dev/null)
    local album=$(playerctl -p spotify metadata album 2>/dev/null)
    local status=$(playerctl -p spotify status 2>/dev/null)
    local position=$(playerctl -p spotify position --format '{{ duration(position) }}' 2>/dev/null)
    local length=$(playerctl -p spotify metadata --format '{{ duration(mpris:length) }}' 2>/dev/null)
    
    echo -e "Artist\t$artist"
    echo -e "Title\t$title"
    echo -e "Album\t$album"
    echo -e "Status\t$status"
    echo -e "Position\t$position / $length"
}

get_spotify_volume() {
    if command -v playerctl &> /dev/null; then
        playerctl -p spotify volume 2>/dev/null | awk '{printf "%.0f", $1 * 100}'
    fi
}

create_volume_bar() {
    local volume=$1
    local bar_length=20
    local filled=$((volume * bar_length / 100))
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

create_spotify_menu() {
    menu_options=""
    
    if ! is_spotify_running; then
        menu_options+="󰓈 Spotify is not running\n"
        menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        menu_options+="󰐊 Start Spotify\n"
        menu_options+="󰏗 Open Spotify Web Player\n"
        echo -e "$menu_options"
        return
    fi
    
    local track_info=$(get_detailed_track_info)
    local artist=$(echo "$track_info" | grep "Artist" | cut -f2)
    local title=$(echo "$track_info" | grep "Title" | cut -f2)
    local album=$(echo "$track_info" | grep "Album" | cut -f2)
    local status=$(echo "$track_info" | grep "Status" | cut -f2)
    local position=$(echo "$track_info" | grep "Position" | cut -f2)
    
    if [[ -n "$title" && -n "$artist" ]]; then
        menu_options+="󰎇 Now Playing:\n"
        menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        menu_options+="󰽰 $title\n"
        menu_options+="󰠃 $artist\n"
        if [[ -n "$album" ]]; then
            menu_options+="󰀥 $album\n"
        fi
        menu_options+="󰥔 $position\n"
        menu_options+="󰆊 Status: $status\n"
    else
        menu_options+="󰓈 No track information available\n"
    fi
    
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    menu_options+="🎵 Playback Controls:\n"
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    
    if [[ "$status" == "Playing" ]]; then
        menu_options+="󰏤 Pause\n"
    else
        menu_options+="󰐊 Play\n"
    fi
    
    menu_options+="󰒮 Previous Track\n"
    menu_options+="󰒭 Next Track\n"
    menu_options+="󰓛 Stop\n"
    
    local volume=$(get_spotify_volume)
    if [[ -n "$volume" ]]; then
        local volume_bar=$(create_volume_bar "$volume")
        menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        menu_options+="󰕾 Volume Control:\n"
        menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        menu_options+="󰕾 Volume: ${volume}% [$volume_bar]\n"
        menu_options+="󰝝 Volume Up (+10%)\n"
        menu_options+="󰝞 Volume Down (-10%)\n"
    fi
    
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    menu_options+="󰏗 Spotify Options:\n"
    menu_options+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    menu_options+="󰖟 Open Spotify App\n"
    menu_options+="󰖟 Spotify Web Player\n"
    menu_options+="󰿃 Shuffle Toggle\n"
    menu_options+="󰑐 Repeat Toggle\n"
    
    echo -e "$menu_options"
}

handle_selection() {
    case "$1" in
        "󰐊 Start Spotify"|"󰖟 Open Spotify App")
            spotify &
            ;;
        "󰏗 Open Spotify Web Player"|"󰖟 Spotify Web Player")
            xdg-open "https://open.spotify.com" &
            ;;
        "󰐊 Play"|"󰏤 Pause")
            playerctl -p spotify play-pause
            notify-send "Spotify" "Toggled play/pause"
            ;;
        "󰒮 Previous Track")
            playerctl -p spotify previous
            notify-send "Spotify" "󰒮 Previous track"
            ;;
        "󰒭 Next Track")
            playerctl -p spotify next  
            notify-send "Spotify" "󰒭 Next track"
            ;;
        "󰓛 Stop")
            playerctl -p spotify stop
            notify-send "Spotify" "󰓛 Stopped playback"
            ;;
        "󰝝 Volume Up (+10%)")
            if command -v playerctl &> /dev/null; then
                current_volume=$(playerctl -p spotify volume)
                new_volume=$(echo "$current_volume + 0.1" | bc -l)
                if (( $(echo "$new_volume <= 1.0" | bc -l) )); then
                    playerctl -p spotify volume "$new_volume"
                    notify-send "Spotify Volume" "󰝝 Volume: $(echo "$new_volume * 100" | bc -l | cut -d. -f1)%"
                fi
            fi
            ;;
        "󰝞 Volume Down (-10%)")
            if command -v playerctl &> /dev/null; then
                current_volume=$(playerctl -p spotify volume)
                new_volume=$(echo "$current_volume - 0.1" | bc -l)
                if (( $(echo "$new_volume >= 0.0" | bc -l) )); then
                    playerctl -p spotify volume "$new_volume"
                    notify-send "Spotify Volume" "󰝞 Volume: $(echo "$new_volume * 100" | bc -l | cut -d. -f1)%"
                fi
            fi
            ;;
        "󰿃 Shuffle Toggle")
            if command -v playerctl &> /dev/null; then
                playerctl -p spotify shuffle toggle
                shuffle_status=$(playerctl -p spotify shuffle)
                notify-send "Spotify" "󰿃 Shuffle: $shuffle_status"
            fi
            ;;
        "󰑐 Repeat Toggle")
            if command -v playerctl &> /dev/null; then
                current_loop=$(playerctl -p spotify loop)
                case "$current_loop" in
                    "None")
                        playerctl -p spotify loop Track
                        notify-send "Spotify" "󰑐 Repeat: Track"
                        ;;
                    "Track")
                        playerctl -p spotify loop Playlist
                        notify-send "Spotify" "󰑐 Repeat: Playlist"
                        ;;
                    "Playlist")
                        playerctl -p spotify loop None
                        notify-send "Spotify" "󰑐 Repeat: Off"
                        ;;
                esac
            fi
            ;;
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"|"󰎇 Now Playing:"|"🎵 Playback Controls:"|"󰕾 Volume Control:"|"󰏗 Spotify Options:"|*"󰓈 Spotify is not running"*|*"󰽰 "*|*"󰠃 "*|*"󰀥 "*|*"󰥔 "*|*"󰆊 Status:"*|*"󰕾 Volume:"*)
            ;;
    esac
}

chosen=$(create_spotify_menu | rofi -dmenu -p "󰎇 Spotify" -theme "$HOME/.config/rofi/spotify-menu.rasi" -i -no-custom)

handle_selection "$chosen"