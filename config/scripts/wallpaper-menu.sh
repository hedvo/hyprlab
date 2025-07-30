#!/bin/bash

create_wallpaper_rasi() {
    cat > "$HOME/hyprlab/config/rofi/wallpaper-menu.rasi" << 'EOF'
@import "common-menu.rasi"

* {
    wallpaper-bg: #2E3440AA;
    wallpaper-fg: #88C0D0;
    wallpaper-accent: #5E81AC;
    wallpaper-urgent: #BF616A;
    wallpaper-selected: #81A1C1;
}

window {
    background-color: @wallpaper-bg;
    border-color: @wallpaper-accent;
    width: 400px;
}

inputbar {
    background-color: @wallpaper-accent;
    text-color: #ECEFF4;
}

listview {
    background-color: transparent;
    scrollbar: false;
    lines: 8;
}

element {
    background-color: transparent;
    text-color: @wallpaper-fg;
}

element selected {
    background-color: @wallpaper-selected;
    text-color: #2E3440;
}
EOF
}

show_wallpaper_selector() {
    local wallpaper_dir="$HOME/Pictures/Wallpapers"
    
    if [[ ! -d "$wallpaper_dir" ]]; then
        wallpaper_dir="$HOME/Pictures"
    fi
    
    if [[ -d "$wallpaper_dir" ]]; then
        find "$wallpaper_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.webp" \) | 
        while read -r file; do
            basename "$file"
        done | sort
    else
        echo "🔍 Browse Files"
    fi
}

show_animation_selector() {
    echo "🎬 none"
    echo "🌅 simple" 
    echo "🌫️ fade"
    echo "⬅️ left"
    echo "➡️ right"
    echo "⬆️ top"
    echo "⬇️ bottom"
    echo "🧹 wipe"
    echo "🌊 wave"
    echo "🌱 grow"
    echo "🎯 center"
    echo "🎲 any"
    echo "🔄 outer"
    echo "🎰 random"
}

create_wallpaper_menu() {
    local current_wallpaper=$(swww query 2>/dev/null | grep -o 'image: .*' | cut -d' ' -f2- | head -1)
    local current_name=""
    
    if [[ -n "$current_wallpaper" ]]; then
        current_name=$(basename "$current_wallpaper")
    fi
    
    echo "🖼️ Change Wallpaper"
    echo "🎬 Animation Effects"
    echo "🔄 Refresh Current"
    echo "📁 Browse Files"
    echo "ℹ️ Current Info"
    
    if [[ -n "$current_name" ]]; then
        echo "📍 Current: $current_name"
    fi
}

browse_files() {
    local selected_file=$(find "$HOME" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.webp" \) 2>/dev/null | 
        head -50 | rofi -dmenu -p "🔍 Select Wallpaper" -theme "$HOME/hyprlab/config/rofi/wallpaper-menu.rasi" -i)
    
    if [[ -n "$selected_file" && -f "$selected_file" ]]; then
        set_wallpaper "$selected_file"
    fi
}

set_wallpaper() {
    local wallpaper_path="$1"
    local animation="fade"
    
    if [[ -f "/tmp/swww_animation" ]]; then
        animation=$(cat /tmp/swww_animation)
    fi
    
    if [[ -f "$wallpaper_path" ]]; then
        swww img "$wallpaper_path" --transition-type="$animation" --transition-duration=2
        notify-send "Wallpaper Changed" "$(basename "$wallpaper_path")" -t 2000
    else
        notify-send "Error" "Wallpaper file not found" -t 2000
    fi
}

show_current_info() {
    local current_wallpaper=$(swww query 2>/dev/null | grep -o 'image: .*' | cut -d' ' -f2- | head -1)
    local animation="none"
    
    if [[ -f "/tmp/swww_animation" ]]; then
        animation=$(cat /tmp/swww_animation)
    fi
    
    if [[ -n "$current_wallpaper" ]]; then
        local filename=$(basename "$current_wallpaper")
        local filesize=$(du -h "$current_wallpaper" 2>/dev/null | cut -f1)
        local dimensions=""
        
        if command -v identify >/dev/null 2>&1; then
            dimensions=$(identify "$current_wallpaper" 2>/dev/null | cut -d' ' -f3)
        fi
        
        local info="📄 File: $filename\n📁 Path: $current_wallpaper\n🎬 Animation: $animation"
        
        if [[ -n "$filesize" ]]; then
            info="$info\n📦 Size: $filesize"
        fi
        
        if [[ -n "$dimensions" ]]; then
            info="$info\n📐 Dimensions: $dimensions"
        fi
        
        notify-send "Current Wallpaper Info" "$info" -t 5000
    else
        notify-send "No Wallpaper" "No wallpaper currently set" -t 2000
    fi
}

if [[ ! -f "$HOME/hyprlab/config/rofi/wallpaper-menu.rasi" ]]; then
    create_wallpaper_rasi
fi

chosen=$(create_wallpaper_menu | rofi -dmenu -p "🖼️ Wallpaper" -theme "$HOME/hyprlab/config/rofi/wallpaper-menu.rasi" -i -no-custom)

case "$chosen" in
    "🖼️ Change Wallpaper")
        wallpaper_selected=$(show_wallpaper_selector | rofi -dmenu -p "🖼️ Select Wallpaper" -theme "$HOME/hyprlab/config/rofi/wallpaper-menu.rasi" -i)
        
        if [[ -n "$wallpaper_selected" ]]; then
            if [[ "$wallpaper_selected" == "🔍 Browse Files" ]]; then
                browse_files
            else
                local wallpaper_dir="$HOME/Pictures/Wallpapers"
                if [[ ! -d "$wallpaper_dir" ]]; then
                    wallpaper_dir="$HOME/Pictures"
                fi
                
                local full_path=$(find "$wallpaper_dir" -name "$wallpaper_selected" -type f | head -1)
                if [[ -n "$full_path" ]]; then
                    set_wallpaper "$full_path"
                fi
            fi
        fi
        ;;
    "🎬 Animation Effects")
        animation_selected=$(show_animation_selector | rofi -dmenu -p "🎬 Animation" -theme "$HOME/hyprlab/config/rofi/wallpaper-menu.rasi" -i)
        
        if [[ -n "$animation_selected" ]]; then
            animation_name=$(echo "$animation_selected" | sed 's/^[^ ]* //')
            echo "$animation_name" > /tmp/swww_animation
            
            local current_wallpaper=$(swww query 2>/dev/null | grep -o 'image: .*' | cut -d' ' -f2- | head -1)
            if [[ -n "$current_wallpaper" ]]; then
                swww img "$current_wallpaper" --transition-type="$animation_name" --transition-duration=2
                notify-send "Animation Set" "$animation_name" -t 2000
            else
                notify-send "Animation Saved" "Will apply to next wallpaper change" -t 2000
            fi
        fi
        ;;
    "🔄 Refresh Current")
        local current_wallpaper=$(swww query 2>/dev/null | grep -o 'image: .*' | cut -d' ' -f2- | head -1)
        if [[ -n "$current_wallpaper" ]]; then
            set_wallpaper "$current_wallpaper"
        else
            notify-send "Error" "No current wallpaper to refresh" -t 2000
        fi
        ;;
    "📁 Browse Files")
        browse_files
        ;;
    "ℹ️ Current Info")
        show_current_info
        ;;
    "📍 Current:"*)
        show_current_info
        ;;
esac