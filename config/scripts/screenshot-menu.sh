#!/bin/bash

create_screenshot_theme() {
    cat > "$HOME/hyprlab/config/rofi/screenshot-menu.rasi" << 'EOF'
* {
    bg-col:             rgba(30, 30, 46, 100%);
    bg-col-light:       rgba(49, 50, 68, 100%);
    border-col:         rgba(249, 226, 175, 100%);
    selected-col:       rgba(249, 226, 175, 100%);
    fg-col:             rgba(205, 214, 244, 100%);
    
    font: "JetBrainsMono Nerd Font 12";
    background-color: transparent;
}

window {
    transparency: "real";
    location: northeast;
    anchor: northeast;
    width: 320px;
    height: 280px;
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
    lines: 8;
    spacing: 2px;
    background-color: transparent;
}

element {
    padding: 8px 12px;
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

create_screenshot_menu() {
    echo "📸 Capture Screen"
    echo "🖼️ Capture Window"
    echo "✂️ Capture Selection"
    echo "🎥 Record Screen"
    echo "⏹️ Stop Recording"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📁 Open Screenshots Folder"
    echo "⚙️ Screenshot Settings"
}

handle_selection() {
    local screenshots_dir="$HOME/Pictures/Screenshots"
    mkdir -p "$screenshots_dir"
    
    case "$1" in
        "📸 Capture Screen")
            if command -v grimblast &> /dev/null; then
                grimblast --notify copysave screen "$screenshots_dir/screenshot_$(date +%Y%m%d_%H%M%S).png"
            elif command -v grim &> /dev/null; then
                grim "$screenshots_dir/screenshot_$(date +%Y%m%d_%H%M%S).png"
                notify-send "Screenshot" "📸 Screen captured"
            else
                notify-send "Screenshot" "❌ No screenshot tool found"
            fi
            ;;
        "🖼️ Capture Window")
            if command -v grimblast &> /dev/null; then
                grimblast --notify copysave active "$screenshots_dir/window_$(date +%Y%m%d_%H%M%S).png"
            elif command -v grim &> /dev/null && command -v slurp &> /dev/null; then
                grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" "$screenshots_dir/window_$(date +%Y%m%d_%H%M%S).png"
                notify-send "Screenshot" "🖼️ Window captured"
            else
                notify-send "Screenshot" "❌ No screenshot tool found"
            fi
            ;;
        "✂️ Capture Selection")
            if command -v grimblast &> /dev/null; then
                grimblast --notify copysave area "$screenshots_dir/selection_$(date +%Y%m%d_%H%M%S).png"
            elif command -v grim &> /dev/null && command -v slurp &> /dev/null; then
                grim -g "$(slurp)" "$screenshots_dir/selection_$(date +%Y%m%d_%H%M%S).png"
                notify-send "Screenshot" "✂️ Selection captured"
            else
                notify-send "Screenshot" "❌ No screenshot tool found"
            fi
            ;;
        "🎥 Record Screen")
            if command -v wf-recorder &> /dev/null; then
                pkill wf-recorder 2>/dev/null
                wf-recorder -f "$screenshots_dir/recording_$(date +%Y%m%d_%H%M%S).mp4" &
                notify-send "Screen Recorder" "🎥 Recording started"
            else
                notify-send "Screen Recorder" "❌ wf-recorder not found"
            fi
            ;;
        "⏹️ Stop Recording")
            if pgrep wf-recorder > /dev/null; then
                pkill wf-recorder
                notify-send "Screen Recorder" "⏹️ Recording stopped"
            else
                notify-send "Screen Recorder" "❌ No recording in progress"
            fi
            ;;
        "📁 Open Screenshots Folder")
            if command -v nautilus &> /dev/null; then
                nautilus "$screenshots_dir" &
            elif command -v dolphin &> /dev/null; then
                dolphin "$screenshots_dir" &
            elif command -v thunar &> /dev/null; then
                thunar "$screenshots_dir" &
            else
                notify-send "File Manager" "Screenshots saved to: $screenshots_dir"
            fi
            ;;
        "⚙️ Screenshot Settings")
            # Open screenshot settings if available
            notify-send "Settings" "Screenshot settings menu"
            ;;
    esac
}

# Create theme if it doesn't exist
if [[ ! -f "$HOME/hyprlab/config/rofi/screenshot-menu.rasi" ]]; then
    create_screenshot_theme
fi

# Show menu
chosen=$(create_screenshot_menu | rofi -dmenu -p "📸 Screenshot" -theme "$HOME/hyprlab/config/rofi/screenshot-menu.rasi" -i -no-custom)

# Handle selection
if [[ -n "$chosen" ]]; then
    handle_selection "$chosen"
fi