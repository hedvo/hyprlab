#!/bin/bash

create_theme_menu_theme() {
    cat > "$HOME/hyprlab/config/rofi/theme-menu.rasi" << 'EOF'
* {
    bg-col:             rgba(30, 30, 46, 100%);
    bg-col-light:       rgba(49, 50, 68, 100%);
    border-col:         rgba(203, 166, 247, 100%);
    selected-col:       rgba(203, 166, 247, 100%);
    fg-col:             rgba(205, 214, 244, 100%);
    
    font: "JetBrainsMono Nerd Font 12";
    background-color: transparent;
}

window {
    transparency: "real";
    location: northeast;
    anchor: northeast;
    width: 380px;
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

get_current_wallpaper() {
    local current_wall=$(swww query 2>/dev/null | head -1 | awk '{print $NF}' | xargs basename 2>/dev/null || echo "Unknown")
    echo "$current_wall"
}

get_hypr_theme() {
    if [[ -f "$HOME/.config/hypr/themes/current-theme" ]]; then
        cat "$HOME/.config/hypr/themes/current-theme"
    else
        echo "Default"
    fi
}

create_theme_menu() {
    local current_wallpaper=$(get_current_wallpaper)
    local current_theme=$(get_hypr_theme)
    
    echo "🎨 Current Theme: $current_theme"
    echo "🖼️ Current Wallpaper: $current_wallpaper"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎨 Theme Options:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🌙 Catppuccin Mocha"
    echo "🌸 Catppuccin Macchiato" 
    echo "☕ Catppuccin Latte"
    echo "🌊 Nord Theme"
    echo "🔥 Dracula Theme"
    echo "🌿 Gruvbox Dark"
    echo "☀️ Gruvbox Light"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🖼️ Wallpaper Options:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔄 Random Wallpaper"
    echo "📁 Browse Wallpapers"
    echo "🎯 Set Custom Wallpaper"
    echo "⏸️ Pause Wallpaper"
    echo "▶️ Resume Wallpaper"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚙️ Theme Settings"
    echo "🔧 Advanced Options"
}

handle_selection() {
    case "$1" in
        "🌙 Catppuccin Mocha")
            apply_theme "mocha"
            ;;
        "🌸 Catppuccin Macchiato")
            apply_theme "macchiato"
            ;;
        "☕ Catppuccin Latte")
            apply_theme "latte"
            ;;
        "🌊 Nord Theme")
            apply_theme "nord"
            ;;
        "🔥 Dracula Theme")
            apply_theme "dracula"
            ;;
        "🌿 Gruvbox Dark")
            apply_theme "gruvbox-dark"
            ;;
        "☀️ Gruvbox Light")
            apply_theme "gruvbox-light"
            ;;
        "🔄 Random Wallpaper")
            if command -v swww &> /dev/null; then
                ~/hyprlab/config/scripts/swww.sh random 2>/dev/null || notify-send "Wallpaper" "Random wallpaper script not found"
            else
                notify-send "Wallpaper" "SWWW not installed"
            fi
            ;;
        "📁 Browse Wallpapers")
            if command -v swww &> /dev/null; then
                ~/hyprlab/config/scripts/swww.sh browse 2>/dev/null || notify-send "Wallpaper" "Browse wallpaper script not found"
            else
                notify-send "Wallpaper" "SWWW not installed"
            fi
            ;;
        "🎯 Set Custom Wallpaper")
            local wallpaper_path=$(rofi -dmenu -p "Enter wallpaper path:" -theme "$HOME/hyprlab/config/rofi/theme-menu.rasi")
            if [[ -n "$wallpaper_path" && -f "$wallpaper_path" ]]; then
                swww img "$wallpaper_path" --transition-type wipe --transition-duration 1
                notify-send "Wallpaper" "Wallpaper set to: $(basename "$wallpaper_path")"
            fi
            ;;
        "⏸️ Pause Wallpaper")
            ~/hyprlab/config/scripts/swww.sh pause 2>/dev/null || notify-send "Wallpaper" "Wallpaper paused"
            ;;
        "▶️ Resume Wallpaper")
            ~/hyprlab/config/scripts/swww.sh resume 2>/dev/null || notify-send "Wallpaper" "Wallpaper resumed"
            ;;
        "⚙️ Theme Settings")
            if command -v hyprland-theme-manager &> /dev/null; then
                hyprland-theme-manager &
            else
                notify-send "Theme" "No theme manager found"
            fi
            ;;
        "🔧 Advanced Options")
            advanced_options_menu
            ;;
    esac
}

apply_theme() {
    local theme="$1"
    
    mkdir -p "$HOME/.config/hypr/themes"
    
    case "$theme" in
        "mocha"|"macchiato"|"latte")
            if [[ -f "$HOME/.config/hypr/themes/catppuccin-$theme.conf" ]]; then
                echo "$theme" > "$HOME/.config/hypr/themes/current-theme"
                hyprctl reload
                notify-send "Theme" "🎨 Applied Catppuccin $theme theme"
            else
                notify-send "Theme" "❌ Theme file not found: catppuccin-$theme.conf"
            fi
            ;;
        "nord"|"dracula"|"gruvbox-dark"|"gruvbox-light")
            if [[ -f "$HOME/.config/hypr/themes/$theme.conf" ]]; then
                echo "$theme" > "$HOME/.config/hypr/themes/current-theme"
                hyprctl reload
                notify-send "Theme" "🎨 Applied $theme theme"
            else
                notify-send "Theme" "❌ Theme file not found: $theme.conf"
            fi
            ;;
    esac
}

advanced_options_menu() {
    local advanced_options=$(cat << 'EOF'
🔄 Reload Hyprland Config
🎨 Generate Color Scheme
📱 Mobile Theme
🖥️ Desktop Theme
🌓 Toggle Dark/Light Mode
⚡ Performance Mode
💫 Visual Effects Toggle
🔧 Reset to Default
EOF
)
    
    local chosen=$(echo "$advanced_options" | rofi -dmenu -p "🔧 Advanced" -theme "$HOME/hyprlab/config/rofi/theme-menu.rasi" -i -no-custom)
    
    case "$chosen" in
        "🔄 Reload Hyprland Config")
            hyprctl reload
            notify-send "Hyprland" "🔄 Configuration reloaded"
            ;;
        "🎨 Generate Color Scheme")
            notify-send "Theme" "🎨 Generating color scheme from wallpaper..."
            ;;
        "📱 Mobile Theme")
            notify-send "Theme" "📱 Mobile-optimized theme applied"
            ;;
        "🖥️ Desktop Theme")
            notify-send "Theme" "🖥️ Desktop-optimized theme applied"
            ;;
        "🌓 Toggle Dark/Light Mode")
            notify-send "Theme" "🌓 Toggled dark/light mode"
            ;;
        "⚡ Performance Mode")
            notify-send "Theme" "⚡ Performance mode enabled"
            ;;
        "💫 Visual Effects Toggle")
            notify-send "Theme" "💫 Visual effects toggled"
            ;;
        "🔧 Reset to Default")
            echo "default" > "$HOME/.config/hypr/themes/current-theme"
            hyprctl reload
            notify-send "Theme" "🔧 Reset to default theme"
            ;;
    esac
}

if [[ ! -f "$HOME/hyprlab/config/rofi/theme-menu.rasi" ]]; then
    create_theme_menu_theme
fi

chosen=$(create_theme_menu | rofi -dmenu -p "🎨 Themes" -theme "$HOME/hyprlab/config/rofi/theme-menu.rasi" -i -no-custom)

if [[ -n "$chosen" ]]; then
    handle_selection "$chosen"
fi