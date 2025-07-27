#!/bin/bash

GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
PURPLE=$(tput setaf 5)
RESET=$(tput sgr0)

update_system() {
    echo "${BLUE}Updating system...${RESET}"
    kitty -e sudo pacman -Syu
    echo "${GREEN}System updated successfully!${RESET}"
    press_enter_to_exit
}

display_orphans() {
    echo "${BLUE}Displaying orphaned packages...${RESET}"
    orphans=$(pacman -Qdt 2>/dev/null)
    if [ -z "$orphans" ]; then
        echo "${YELLOW}No orphaned packages found.${RESET}"
    else
        echo "$orphans"
    fi
    press_enter_to_exit
}

remove_orphans() {
    echo "${BLUE}Removing orphaned packages...${RESET}"
    orphans=$(pacman -Qdtq)
    if [ -z "$orphans" ]; then
        echo "${YELLOW}No orphaned packages to remove.${RESET}"
    else
        sudo pacman -Rns $orphans
        echo "${GREEN}Orphaned packages removed successfully!${RESET}"
    fi
    press_enter_to_exit
}

clean_cache() {
    echo "${BLUE}Cleaning package cache...${RESET}"
    sudo paccache -r
    echo "${GREEN}Package cache cleaned successfully!${RESET}"
    press_enter_to_exit
}

check_dependencies() {
    echo "${BLUE}Checking for broken dependencies...${RESET}"
    pacman -Dk
    press_enter_to_exit
}

automated_maintenance() {
    echo "${BLUE}Starting automated maintenance...${RESET}"
    timeshift_backup
    update_system
    clean_cache
    remove_orphans
    check_dependencies
    echo "${GREEN}Automated maintenance completed successfully!${RESET}"
    press_enter_to_exit
}

search_package() {
    read -p "${YELLOW}Enter the package name to search for: ${RESET}" package_name
    echo "${BLUE}Searching for $package_name in Pacman...${RESET}"
    pacman_results=$(pacman -Ss "$package_name")

    echo "${BLUE}Searching for $package_name in Yay...${RESET}"
    yay_results=$(yay -Ss "$package_name")

    echo ""
    echo "${PURPLE}--- Pacman Results ---${RESET}"
    echo "$pacman_results" | head -n 10
    echo ""
    echo "${PURPLE}--- Yay Results ---${RESET}"
    echo "$yay_results" | head -n 10
    echo ""
}

install_package() {
    search_package

    read -p "${YELLOW}Enter the package name to install: ${RESET}" package_name
    echo "${YELLOW}Select package manager (pacman/yay): ${RESET}"
    
    while true; do
        read -p "Enter your choice (pacman/yay): " pkg_manager
        if [[ "$pkg_manager" == "pacman" ]]; then
            echo "${BLUE}Installing $package_name with Pacman...${RESET}"
            if sudo pacman -S "$package_name"; then
                echo "${GREEN}$package_name installed successfully!${RESET}"
            else
                echo "${RED}Failed to install $package_name.${RESET}"
            fi
            break
        elif [[ "$pkg_manager" == "yay" ]]; then
            echo "${BLUE}Installing $package_name with Yay...${RESET}"
            if yay -S "$package_name"; then
                echo "${GREEN}$package_name installed successfully!${RESET}"
            else
                echo "${RED}Failed to install $package_name.${RESET}"
            fi
            break
        else
            echo "${RED}Invalid package manager. Please choose 'pacman' or 'yay'.${RESET}"
        fi
    done
    press_enter_to_exit
}

uninstall_package() {
    read -p "${YELLOW}Enter the package name to uninstall: ${RESET}" package_name
    
    if pacman -Q "$package_name" &>/dev/null; then
        echo "${PURPLE}$package_name is installed via Pacman.${RESET}"
        pkg_manager="pacman"
    elif yay -Q "$package_name" &>/dev/null; then
        echo "${PURPLE}$package_name is installed via Yay.${RESET}"
        pkg_manager="yay"
    else
        echo "${RED}$package_name is not installed.${RESET}"
        press_enter_to_exit
        return
    fi

    read -p "${YELLOW}Are you sure you want to uninstall $package_name? (y/n): ${RESET}" confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo "${BLUE}Uninstalling $package_name with $pkg_manager...${RESET}"
        if [[ "$pkg_manager" == "pacman" ]]; then
            if sudo pacman -Rns "$package_name"; then
                echo "${GREEN}$package_name uninstalled successfully!${RESET}"
            else
                echo "${RED}Failed to uninstall $package_name.${RESET}"
            fi
        elif [[ "$pkg_manager" == "yay" ]]; then
            if yay -Rns "$package_name"; then
                echo "${GREEN}$package_name uninstalled successfully!${RESET}"
            else
                echo "${RED}Failed to uninstall $package_name.${RESET}"
            fi
        fi
    else
        echo "${YELLOW}Uninstallation of $package_name canceled.${RESET}"
    fi
    press_enter_to_exit
}

list_installed_packages() {
    echo "${BLUE}Listing installed packages...${RESET}"
    pacman -Q
    press_enter_to_exit
}

show_package_info() {
    read -p "${YELLOW}Enter the package name to get information: ${RESET}" package_name
    echo "${BLUE}Fetching information for $package_name...${RESET}"
    pacman -Qi "$package_name"
    press_enter_to_exit
}

list_user_installed_packages() {
    echo "${BLUE}Listing user-installed packages...${RESET}"
    user_installed_packages=$(pacman -Qe)
    if [ -z "$user_installed_packages" ]; then
        echo "${YELLOW}No user-installed packages found.${RESET}"
    else
        echo "$user_installed_packages"
    fi
    press_enter_to_exit
}


timeshift_backup() {
    echo "${BLUE}Starting Timeshift backup...${RESET}"
    sudo -E timeshift-gtk
    echo "${GREEN}Timeshift backup completed!${RESET}"
    press_enter_to_exit
}

show_help() {
    echo "${BLUE}Help Menu:${RESET}"
    echo "${PURPLE}[m1] Update system: Updates all packages."
    echo "${PURPLE}[m2] Display orphaned packages: Lists packages that were installed as dependencies but are no longer needed."
    echo "${PURPLE}[m3] Remove orphaned packages: Deletes orphaned packages."
    echo "${PURPLE}[m4] Clean package cache: Removes old package versions from the cache."
    echo "${PURPLE}[m5] Check for broken dependencies: Verifies the integrity of installed packages."
    echo "${PURPLE}[am] Run automated maintenance: Performs system updates, cleans cache, and removes orphaned packages."
    echo "${PURPLE}[p1] Install a package: Installs a package using Pacman or Yay."
    echo "${PURPLE}[p2] Uninstall a package: Removes an installed package."
    echo "${PURPLE}[p3] List user-installed packages: Shows packages installed manually by the user."
    echo "${PURPLE}[p4] List installed packages: Displays all installed packages."
    echo "${PURPLE}[p5] Show package information: Provides details about a specific package."
    echo "${PURPLE}[b1] Run Timeshift backup: Initiates a backup using Timeshift."
    echo "${PURPLE}[h]  Help: Displays this help menu."
    echo "${PURPLE}[q]  Exit: Exits the script."
    echo ""
    echo "${PURPLE}~ Author: Hedverse (https://github.com/hedversecorp)${RESET}"
    press_enter_to_exit
}

press_enter_to_exit() {
    echo "${YELLOW}Press Enter to return to the menu...${RESET}"
    read
}

while true; do
    clear
    echo "${PURPLE}"
    echo "
█▀▄▀█ ▄▀█ █ █▄░█ ▀█▀ █▀▀ █▄░█ ▄▀█ █▄░█ █▀▀ █▀▀   █▀▄▀█ █▀▀ █▄░█ █░█
█░▀░█ █▀█ █ █░▀█ ░█░ ██▄ █░▀█ █▀█ █░▀█ █▄▄ ██▄   █░▀░█ ██▄ █░▀█ █▄█"
    echo ""
    echo "~ Author: Hedverse (https://github.com/hedversecorp)"
    echo "${RESET}"

    # System Maintenance category
    echo "${YELLOW}System Maintenance${RESET}"
    echo "${BLUE}[m1] Update system${RESET}"
    echo "${BLUE}[m2] Display unused (orphaned) packages${RESET}"
    echo "${BLUE}[m3] Remove unused (orphaned) packages${RESET}"
    echo "${BLUE}[m4] Clean package cache${RESET}"
    echo "${BLUE}[m5] Check for broken dependencies"
    echo "${PURPLE}[am] Run automated maintenance${RESET}"

    echo ""
    
    echo "${YELLOW}Package Management${RESET}"
    echo "${BLUE}[p1] Install a package${RESET}"
    echo "${BLUE}[p2] Uninstall a package${RESET}"
    echo "${BLUE}[p3] List user-installed packages${RESET}"
    echo "${BLUE}[p4] List installed packages${RESET}"
    echo "${BLUE}[p5] Show package information${RESET}"

    echo ""
    
    echo "${YELLOW}Backup${RESET}"
    echo "${BLUE}[b1] Run Timeshift backup${RESET}"

    echo ""

    echo "${PURPLE}[h] Help${RESET}"
    echo "${RED}[q] Exit${RESET}"
    
    echo ""

    read -p "Enter your choice [1-10]: " choice
    
    case $choice in
        m1) update_system ;;
        m2) display_orphans ;;
        m3) remove_orphans ;;
        m4) clean_cache ;;
        m5) check_dependencies ;;
        am) automated_maintenance;;
        p1) install_package ;;
        p2) uninstall_package ;;
        p3) list_user_installed_packages ;;
        p4) list_installed_packages ;;
        p5) show_package_info ;;
        b1) timeshift_backup ;;
        h) show_help ;;
        q) echo "${GREEN}Exiting...${RESET}"; exit 0 ;;
        *) echo "${RED}Invalid choice. Please select a valid option.${RESET}"; press_enter_to_exit ;;    esac
done

