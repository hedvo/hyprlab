#!/bin/bash

is_spotify_running() {
    pgrep -x spotify > /dev/null
}

get_spotify_status() {
    if ! is_spotify_running; then
        echo "Not running"
        return
    fi
    
    if command -v playerctl &> /dev/null; then
        playerctl -p spotify status 2>/dev/null || echo "Not playing"
    else
        echo "No playerctl"
    fi
}

get_track_info() {
    if ! is_spotify_running; then
        return
    fi
    
    if command -v playerctl &> /dev/null; then
        local artist=$(playerctl -p spotify metadata artist 2>/dev/null)
        local title=$(playerctl -p spotify metadata title 2>/dev/null)
        
        if [[ -n "$artist" && -n "$title" ]]; then
            if [[ ${#title} -gt 20 ]]; then
                title="${title:0:17}..."
            fi
            if [[ ${#artist} -gt 15 ]]; then
                artist="${artist:0:12}..."
            fi
            echo "$artist - $title"
        fi
    fi
}

get_spotify_icon() {
    local status=$(get_spotify_status)
    case "$status" in
        "Playing")
            echo "󰓇"
            ;;
        "Paused")
            echo "󰏤"
            ;;
        "Not running"|"Not playing")
            echo "󰓈"
            ;;
        *)
            echo "󰎇"
            ;;
    esac
}

spotify_control() {
    case "$1" in
        "play-pause")
            if is_spotify_running && command -v playerctl &> /dev/null; then
                playerctl -p spotify play-pause
            else
                spotify &
            fi
            ;;
        "next")
            if is_spotify_running && command -v playerctl &> /dev/null; then
                playerctl -p spotify next
            fi
            ;;
        "previous")
            if is_spotify_running && command -v playerctl &> /dev/null; then
                playerctl -p spotify previous
            fi
            ;;
        "stop")
            if is_spotify_running && command -v playerctl &> /dev/null; then
                playerctl -p spotify stop
            fi
            ;;
    esac
}

waybar_output() {
    local status=$(get_spotify_status)
    local icon=$(get_spotify_icon)
    local track=$(get_track_info)
    
    if [[ "$status" == "Not running" ]]; then
        echo "{\"text\": \"<span color='#6c7086'>$icon</span>  Offline\", \"class\": \"offline\", \"tooltip\": \"Spotify is not running\"}"
    elif [[ "$status" == "Playing" && -n "$track" ]]; then
        echo "{\"text\": \"<span color='#a6e3a1'>$icon</span>  $track\", \"class\": \"playing\", \"tooltip\": \"Now Playing: $track\"}"
    elif [[ "$status" == "Paused" && -n "$track" ]]; then
        echo "{\"text\": \"<span color='#f9e2af'>$icon</span>  $track\", \"class\": \"paused\", \"tooltip\": \"Paused: $track\"}"
    else
        echo "{\"text\": \"<span color='#89b4fa'>$icon</span>  Spotify\", \"class\": \"idle\", \"tooltip\": \"Spotify ready\"}"
    fi
}

case "${1:-waybar}" in
    "waybar")
        waybar_output
        ;;
    "play-pause"|"next"|"previous"|"stop")
        spotify_control "$1"
        ;;
    "menu")
        exec "$HOME/hyprlab/config/scripts/spotify-menu.sh"
        ;;
    *)
        echo "Usage: $0 [waybar|play-pause|next|previous|stop|menu]"
        ;;
esac