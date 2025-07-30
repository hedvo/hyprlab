#!/bin/bash


create_arch_wiki_theme() {
    cat > "$HOME/hyprlab/config/rofi/arch-wiki-menu.rasi" << 'EOF'
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
    width: 450px;
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

create_arch_wiki_menu() {
    echo "📖 Arch Wiki Homepage"
    echo "🔧 Installation Guide"
    echo "📦 Package Management"
    echo "🖥️ Desktop Environment"
    echo "🌐 Network Configuration" 
    echo "🔐 System Security"
    echo "⚙️ System Administration"
    echo "🎮 Gaming on Arch"
    echo "🛠️ Troubleshooting"
    echo "💻 Hardware Compatibility"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔍 Search Arch Wiki"
    echo "📚 Arch User Repository (AUR)"
    echo "💬 Arch Forums"
    echo "📰 Arch News"
    echo "🐛 Bug Reports"
}

handle_selection() {
    local browser="firefox"
    
    if command -v firefox &> /dev/null; then
        browser="firefox"
    elif command -v chromium &> /dev/null; then
        browser="chromium"
    elif command -v google-chrome &> /dev/null; then
        browser="google-chrome"
    else
        notify-send "Browser Error" "No supported browser found"
        return 1
    fi
    
    case "$1" in
        "📖 Arch Wiki Homepage")
            $browser "https://wiki.archlinux.org/" &
            ;;
        "🔧 Installation Guide")
            $browser "https://wiki.archlinux.org/title/Installation_guide" &
            ;;
        "📦 Package Management")
            $browser "https://wiki.archlinux.org/title/Pacman" &
            ;;
        "🖥️ Desktop Environment")
            $browser "https://wiki.archlinux.org/title/Desktop_environment" &
            ;;
        "🌐 Network Configuration")
            $browser "https://wiki.archlinux.org/title/Network_configuration" &
            ;;
        "🔐 System Security")
            $browser "https://wiki.archlinux.org/title/Security" &
            ;;
        "⚙️ System Administration")
            $browser "https://wiki.archlinux.org/title/System_administration" &
            ;;
        "🎮 Gaming on Arch")
            $browser "https://wiki.archlinux.org/title/Gaming" &
            ;;
        "🛠️ Troubleshooting")
            $browser "https://wiki.archlinux.org/title/General_troubleshooting" &
            ;;
        "💻 Hardware Compatibility")
            $browser "https://wiki.archlinux.org/title/Hardware" &
            ;;
        "🔍 Search Arch Wiki")
            local search_term=$(rofi -dmenu -p "Search Arch Wiki:" -theme "$HOME/hyprlab/config/rofi/arch-wiki-menu.rasi")
            if [[ -n "$search_term" ]]; then
                local encoded_search=$(echo "$search_term" | sed 's/ /%20/g')
                $browser "https://wiki.archlinux.org/index.php?search=$encoded_search" &
            fi
            ;;
        "📚 Arch User Repository (AUR)")
            $browser "https://aur.archlinux.org/" &
            ;;
        "💬 Arch Forums")
            $browser "https://bbs.archlinux.org/" &
            ;;
        "📰 Arch News")
            $browser "https://archlinux.org/news/" &
            ;;
        "🐛 Bug Reports")
            $browser "https://bugs.archlinux.org/" &
            ;;
    esac
}

if [[ ! -f "$HOME/hyprlab/config/rofi/arch-wiki-menu.rasi" ]]; then
    create_arch_wiki_theme
fi

chosen=$(create_arch_wiki_menu | rofi -dmenu -p "📖 Arch Wiki" -theme "$HOME/hyprlab/config/rofi/arch-wiki-menu.rasi" -i -no-custom)

if [[ -n "$chosen" ]]; then
    handle_selection "$chosen"
fi