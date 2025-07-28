#!/bin/bash

bluetooth_status=$(systemctl is-active bluetooth)

if [[ "$bluetooth_status" != "active" ]]; then
    notify-send "Bluetooth" "Bluetooth service is not running"
    exit 1
fi

bt_power=$(bluetoothctl show | grep "Powered" | awk '{print $2}')

menu_options=""
if [[ "$bt_power" == "yes" ]]; then
    menu_options+="󰂯 Turn Off Bluetooth\n"

    paired_devices=$(bluetoothctl devices Paired | cut -f2 -d' ' --complement)
    
    if [[ -n "$paired_devices" ]]; then
        menu_options+="󰂱 Paired Devices\n"
        while read -r device; do
            device_mac=$(echo "$device" | awk '{print $1}')
            device_name=$(echo "$device" | cut -d' ' -f2-)
            if bluetoothctl info "$device_mac" | grep -q "Connected: yes"; then
                menu_options+="󰂱 $device_name (Connected)\n"
            else
                menu_options+="󰂲 $device_name (Disconnected)\n"
            fi
        done <<< "$paired_devices"
    fi
    
    menu_options+="󰐲 Scan for Devices\n"
    
    available_devices=$(bluetoothctl devices | grep -v "Paired" | cut -f2 -d' ' --complement)
    if [[ -n "$available_devices" ]]; then
        menu_options+="──────────────\n"
        menu_options+="📱 Available Devices\n"
        while read -r device; do
            device_mac=$(echo "$device" | awk '{print $1}')
            device_name=$(echo "$device" | cut -d' ' -f2-)
            menu_options+="󰂐 $device_name\n"
        done <<< "$available_devices"
    fi
else
    menu_options+="󰂯 Turn On Bluetooth\n"
fi

menu_options+="󰍉 Open Bluetooth Manager"

chosen=$(echo -e "$menu_options" | rofi -dmenu -p "Bluetooth" -theme "$HOME/.config/rofi/bluetooth-menu.rasi")

case "$chosen" in
    "󰂯 Turn On Bluetooth")
        bluetoothctl power on
        notify-send "Bluetooth" "Bluetooth turned on"
        ;;
    "󰂯 Turn Off Bluetooth")
        bluetoothctl power off
        notify-send "Bluetooth" "Bluetooth turned off"
        ;;
    "󰐲 Scan for Devices")
        bluetoothctl --timeout=10 scan on &
        notify-send "Bluetooth" "Scanning for devices..."
        ;;
    "󰍉 Open Bluetooth Manager")
        blueman-manager &
        ;;
    *"(Connected)")
        device_name=$(echo "$chosen" | sed 's/󰂱 //' | sed 's/ (Connected)//')
        device_mac=$(bluetoothctl devices Paired | grep "$device_name" | awk '{print $2}')
        bluetoothctl disconnect "$device_mac"
        notify-send "Bluetooth" "Disconnected from $device_name"
        ;;
    *"(Disconnected)")
        device_name=$(echo "$chosen" | sed 's/󰂲 //' | sed 's/ (Disconnected)//')
        device_mac=$(bluetoothctl devices Paired | grep "$device_name" | awk '{print $2}')
        bluetoothctl connect "$device_mac"
        notify-send "Bluetooth" "Connecting to $device_name"
        ;;
    "󰂐 "*)
        device_name=$(echo "$chosen" | sed 's/󰂐 //')
        device_mac=$(bluetoothctl devices | grep "$device_name" | awk '{print $2}')
        if [[ -n "$device_mac" ]]; then
            bluetoothctl pair "$device_mac" && bluetoothctl connect "$device_mac"
            notify-send "Bluetooth" "Pairing and connecting to $device_name"
        fi
        ;;
    "──────────────"|"📱 Available Devices"|"󰂱 Paired Devices")
        ;;
esac