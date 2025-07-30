#!/bin/bash

create_wifi_theme() {
    cat > "$HOME/hyprlab/config/rofi/wifi-menu.rasi" << 'EOF'
* {
    bg-col:             rgba(30, 30, 46, 100%);
    bg-col-light:       rgba(49, 50, 68, 100%);
    border-col:         rgba(166, 227, 161, 100%);
    selected-col:       rgba(166, 227, 161, 100%);
    fg-col:             rgba(205, 214, 244, 100%);
    
    font: "JetBrainsMono Nerd Font 12";
    background-color: transparent;
}

window {
    transparency: "real";
    location: northeast;
    anchor: northeast;
    width: 400px;
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

if [[ ! -f "$HOME/hyprlab/config/rofi/wifi-menu.rasi" ]]; then
    create_wifi_theme
fi

chosen=$(echo -e "$menu_options" | rofi -dmenu -p "📶 WiFi" -theme "$HOME/hyprlab/config/rofi/wifi-menu.rasi" -i -no-custom)

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
                password=$(echo "" | rofi -dmenu -password -p "🔐 $ssid" -theme "$HOME/hyprlab/config/rofi/password.rasi")
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