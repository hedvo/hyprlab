#!/bin/bash


animations=("none" "simple" "fade" "left" "right" "top" "bottom" "wipe" "wave" "grow" "center" "any" "outer" "random")

current_wallpaper=$(swww query | grep -o 'image: .*' | cut -d' ' -f2-)

if [ -z "$current_wallpaper" ]; then
    notify-send "Error" "No wallpaper currently set" -t 2000
    exit 1
fi

selected_animation=$(printf '%s\n' "${animations[@]}" | rofi -dmenu -i -p "󰽡 Animation" -theme "$HOME/hyprlab/config/rofi/wallpaper-menu.rasi")

if [ -n "$selected_animation" ]; then
    echo "$selected_animation" > /tmp/swww_animation
    
    swww img "$current_wallpaper" --transition-type="$selected_animation" --transition-duration=2
    
    notify-send "Wallpaper Animation" "Set to: $selected_animation" -t 2000
fi