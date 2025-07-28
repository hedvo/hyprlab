#!/bin/bash

wifi_status=$(nmcli radio wifi)

if [[ "$wifi_status" == "disabled" ]]; then
    menu_options="󰖩 Turn On WiFi\n󰍉 Open Network Manager"
else
    current_ssid=$(nmcli -t -f active,ssid dev wifi | egrep '^yes' | cut -d: -f2)
    
    menu_options=""
    if [[ -n "$current_ssid" ]]; then
        menu_options+="󰖪 Disconnect from $current_ssid\n"
    fi
    
    menu_options+="󰖩 Turn Off WiFi\n"
    menu_options+="󰑓 Refresh Networks\n"
    menu_options+="󰍉 Open Network Manager\n"
    menu_options+="──────────────\n"
    
    networks=$(nmcli -t -f ssid,signal,security dev wifi list | sort -t: -k2 -nr | head -10)
    
    if [[ -n "$networks" ]]; then
        while IFS=: read -r ssid signal security; do
            if [[ -n "$ssid" ]]; then
                if [[ $signal -gt 75 ]]; then
                    signal_icon="󰣺"
                elif [[ $signal -gt 50 ]]; then
                    signal_icon="󰣸"
                elif [[ $signal -gt 25 ]]; then
                    signal_icon="󰣶"
                else
                    signal_icon="󰣴"
                fi
                
                if [[ "$security" == *"WPA"* ]] || [[ "$security" == *"WEP"* ]]; then
                    security_icon="󰌾"
                else
                    security_icon="󰌿"
                fi

                if [[ "$ssid" == "$current_ssid" ]]; then
                    menu_options+="󰱇 $ssid $signal_icon ($signal%) - Connected\n"
                else
                    menu_options+="$security_icon $ssid $signal_icon ($signal%)\n"
                fi
            fi
        done <<< "$networks"
    fi
fi

chosen=$(echo -e "$menu_options" | rofi -dmenu -p "WiFi" -theme "$HOME/.config/rofi/wifi-menu.rasi")

case "$chosen" in
    "󰖩 Turn On WiFi")
        nmcli radio wifi on
        notify-send "WiFi" "WiFi turned on"
        ;;
    "󰖩 Turn Off WiFi")
        nmcli radio wifi off
        notify-send "WiFi" "WiFi turned off"
        ;;
    "󰑓 Refresh Networks")
        nmcli device wifi rescan
        notify-send "WiFi" "Refreshing network list..."
        ;;
    "󰍉 Open Network Manager")
        nm-connection-editor &
        ;;
    "󰖪 Disconnect from "*)
        ssid=$(echo "$chosen" | sed 's/󰖪 Disconnect from //')
        connection_name=$(nmcli -t -f name,type connection show | grep ":wifi$" | cut -d: -f1 | xargs -I {} sh -c 'nmcli connection show "{}" | grep -q "'"$ssid"'" && echo "{}"' | head -1)
        if [[ -n "$connection_name" ]]; then
            nmcli connection down "$connection_name"
            notify-send "WiFi" "Disconnected from $ssid"
        else
            nmcli device disconnect wlo1
            notify-send "WiFi" "Disconnected from WiFi"
        fi
        ;;
    *" - Connected")
        ;;
    "──────────────")
        ;;
    *)
        if [[ -n "$chosen" ]] && [[ "$chosen" != *"──"* ]]; then
            ssid=$(echo "$chosen" | sed 's/^[󰌾󰌿󰱇] //' | sed 's/ [󰣺󰣸󰣶󰣴] .*//')
            
            security=$(nmcli -t -f ssid,security dev wifi list | grep "^$ssid:" | cut -d: -f2)

            existing_connection=$(nmcli -t -f name connection show | grep "^$ssid$")
            
            if [[ -n "$existing_connection" ]]; then
                nmcli connection up "$ssid"
                notify-send "WiFi" "Connecting to $ssid..."
            elif [[ "$security" == *"WPA"* ]] || [[ "$security" == *"WEP"* ]]; then
                password=$(echo "" | rofi -dmenu -password -p "🔐 $ssid" -theme "$HOME/.config/rofi/password.rasi")
                if [[ -n "$password" ]]; then
                    nmcli device wifi connect "$ssid" password "$password"
                    notify-send "WiFi" "Connecting to $ssid..."
                fi
            else
                nmcli device wifi connect "$ssid"
                notify-send "WiFi" "Connecting to $ssid..."
            fi
        fi
        ;;
esac