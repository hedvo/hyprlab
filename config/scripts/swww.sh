#!/bin/bash

WALLPAPER_DIR="$HOME/hyprlab/config/assets/wallpapers"

STATE_FILE="/tmp/current_wallpaper_index"
TYPE_FILE="/tmp/current_wallpaper_type"
FLAG_FILE="/tmp/wallpaper_cycle_flag"

TYPES=("Anime" "Nature")

swww query &> /dev/null
if [ $? -ne 0 ]; then
    swww-daemon --format xrgb &
    sleep 1
    swww query && swww restore
fi

if [ ! -f "$FLAG_FILE" ]; then
    touch "$FLAG_FILE"
    exit 0
fi

if [ ! -f "$TYPE_FILE" ]; then
    echo "${TYPES[0]}" > "$TYPE_FILE"
fi

CURRENT_TYPE=$(cat "$TYPE_FILE")

WALLPAPER_COUNT=$(ls "$WALLPAPER_DIR/$CURRENT_TYPE"*.{jpg,png,jpeg} 2>/dev/null | wc -l)

if [ ! -f "$STATE_FILE" ]; then
    echo 1 > "$STATE_FILE"
fi

CURRENT_INDEX=$(cat "$STATE_FILE")

if [ "$WALLPAPER_COUNT" -eq 0 ]; then
    echo "No wallpapers found for type: $CURRENT_TYPE. Switching to default type: ${TYPES[0]}"
    echo "${TYPES[0]}" > "$TYPE_FILE"
    CURRENT_TYPE="${TYPES[0]}"
    
    WALLPAPER_COUNT=$(ls "$WALLPAPER_DIR/$CURRENT_TYPE"*.{jpg,png,jpeg} 2>/dev/null | wc -l)
    
    echo 1 > "$STATE_FILE"
    
    exit 0
fi

if [[ "$1" == "switch" ]]; then
    CURRENT_INDEX=0
    for i in "${!TYPES[@]}"; do
        if [[ "${TYPES[$i]}" == "$CURRENT_TYPE" ]]; then
            CURRENT_INDEX=$i
            break
        fi
    done

    NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#TYPES[@]} ))

    echo "${TYPES[$NEXT_INDEX]}" > "$TYPE_FILE"
    echo "Switched to type: ${TYPES[$NEXT_INDEX]}"
    
    echo 1 > "$STATE_FILE"
    exit 0
fi

NEXT_INDEX=$(( (CURRENT_INDEX % WALLPAPER_COUNT) + 1 ))

NEXT_WALLPAPER=$(ls "$WALLPAPER_DIR/$CURRENT_TYPE"*.{jpg,png,jpeg} | sed -n "${NEXT_INDEX}p")

ANIMATION_FILE="/tmp/swww_animation"
if [ -f "$ANIMATION_FILE" ]; then
    ANIMATION_TYPE=$(cat "$ANIMATION_FILE")
else
    ANIMATION_TYPE="grow"
    echo "$ANIMATION_TYPE" > "$ANIMATION_FILE"
fi

swww img "$NEXT_WALLPAPER" --transition-type "$ANIMATION_TYPE" --transition-bezier ".43,1.19,1,.4" --transition-duration 1 --transition-fps 60 --invert-y --transition-pos "$(hyprctl cursorpos | grep -E '^[0-9]' || echo "0,0")" &

echo $NEXT_INDEX > "$STATE_FILE"
