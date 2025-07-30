#!/bin/bash

create_bluetooth_theme() {
    cat > "$HOME/hyprlab/config/rofi/bluetooth-menu.rasi" << 'EOF'
* {
    bg-col:             rgba(30, 30, 46, 100%);
    bg-col-light:       rgba(49, 50, 68, 100%);
    border-col:         rgba(116, 199, 236, 100%);
    selected-col:       rgba(116, 199, 236, 100%);
    fg-col:             rgba(205, 214, 244, 100%);
    
    font: "JetBrainsMono Nerd Font 12";
    background-color: transparent;
}

window {
    transparency: "real";
    location: northeast;
    anchor: northeast;
    width: 380px;
    height: 350px;
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
    lines: 12;
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

check_bluetooth_status() {
    if ! systemctl is-active --quiet bluetooth; then
        return 1
    fi
    bluetoothctl show | grep -q "Powered: yes"
}

get_bluetooth_devices() {
    local device_type="$1"
    case "$device_type" in
        "paired")
            bluetoothctl devices Paired | while read -r device; do
                local mac=$(echo "$device" | awk '{print $2}')
                local name=$(echo "$device" | cut -d' ' -f3-)
                if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
                    echo "󰂱 $name (Connected)"
                else
                    echo "󰂲 $name (Disconnected)"
                fi
            done
            ;;
        "available")
            bluetoothctl devices | grep -v "Paired" | while read -r device; do
                local name=$(echo "$device" | cut -d' ' -f3-)
                echo "󰂐 $name"
            done
            ;;
    esac
}

create_bluetooth_menu() {
    if ! check_bluetooth_status; then
        echo "󰂯 Turn On Bluetooth"
        echo "󰍉 Open Bluetooth Manager"
        return
    fi
    
    echo "󰂯 Turn Off Bluetooth"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local paired_devices=$(get_bluetooth_devices "paired")
    if [[ -n "$paired_devices" ]]; then
        echo "📱 Paired Devices:"
        echo "$paired_devices"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    fi
    
    echo "󰐲 Scan for Devices"
    
    local available_devices=$(get_bluetooth_devices "available")
    if [[ -n "$available_devices" ]]; then
        echo "🔍 Available Devices:"
        echo "$available_devices"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    fi
    
    echo "󰍉 Open Bluetooth Manager"
}

handle_selection() {
    case "$1" in
        "󰂯 Turn On Bluetooth")
            bluetoothctl power on
            notify-send "Bluetooth" "󰂯 Bluetooth turned on"
            ;;
        "󰂯 Turn Off Bluetooth")
            bluetoothctl power off
            notify-send "Bluetooth" "󰂯 Bluetooth turned off"
            ;;
        "󰐲 Scan for Devices")
            bluetoothctl --timeout=10 scan on &
            notify-send "Bluetooth" "🔍 Scanning for devices..."
            ;;
        "󰍉 Open Bluetooth Manager")
            if command -v blueman-manager &> /dev/null; then
                blueman-manager &
            else
                notify-send "Bluetooth" "No bluetooth manager found"
            fi
            ;;
        *"(Connected)")
            local device_name=$(echo "$1" | sed 's/󰂱 //' | sed 's/ (Connected)//')
            local device_mac=$(bluetoothctl devices Paired | grep -F "$device_name" | awk '{print $2}')
            if [[ -n "$device_mac" ]]; then
                bluetoothctl disconnect "$device_mac"
                notify-send "Bluetooth" "Disconnected from $device_name"
            fi
            ;;
        *"(Disconnected)")
            local device_name=$(echo "$1" | sed 's/󰂲 //' | sed 's/ (Disconnected)//')
            local device_mac=$(bluetoothctl devices Paired | grep -F "$device_name" | awk '{print $2}')
            if [[ -n "$device_mac" ]]; then
                bluetoothctl connect "$device_mac"
                notify-send "Bluetooth" "Connecting to $device_name"
            fi
            ;;
        "󰂐 "*)
            local device_name=$(echo "$1" | sed 's/󰂐 //')
            local device_mac=$(bluetoothctl devices | grep -F "$device_name" | awk '{print $2}')
            if [[ -n "$device_mac" ]]; then
                bluetoothctl pair "$device_mac" && bluetoothctl connect "$device_mac"
                notify-send "Bluetooth" "Pairing and connecting to $device_name"
            fi
            ;;
    esac
}

if [[ ! -f "$HOME/hyprlab/config/rofi/bluetooth-menu.rasi" ]]; then
    create_bluetooth_theme
fi

chosen=$(create_bluetooth_menu | rofi -dmenu -p "󰂯 Bluetooth" -theme "$HOME/hyprlab/config/rofi/bluetooth-menu.rasi" -i -no-custom)

if [[ -n "$chosen" ]]; then
    handle_selection "$chosen"
fi