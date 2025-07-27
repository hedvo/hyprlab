#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

animate() {
  echo -ne "$1"
  for i in {1..3}; do
    echo -ne "."
    sleep 0.2
  done
  echo ""
}

profile_file="$HOME/.ssh/.git_profiles"
declare -A git_profiles

if [ ! -d "$HOME/.ssh" ]; then
  echo -e "${YELLOW}Creating .ssh directory...${NC}"
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
fi

if [ ! -f "$profile_file" ]; then
  echo -e "${YELLOW}Creating .git_profiles file...${NC}"
  touch "$profile_file"
  chmod 600 "$profile_file"
fi

if [[ -f "$profile_file" ]]; then
  while IFS=":" read -r profile_name user_name user_email; do
    git_profiles["$profile_name"]="$user_name:$user_email"
  done < "$profile_file"
else
  touch "$profile_file"
fi

save_profiles() {
  > "$profile_file"
  for profile in "${!git_profiles[@]}"; do
    IFS=":" read -r user_name user_email <<< "${git_profiles[$profile]}"
    echo "$profile:$user_name:$user_email" >> "$profile_file"
  done
}

echo -e "${YELLOW}What would you like to do?${NC}"
echo -e "1) ${GREEN}Show Profiles${NC}"
echo -e "2) ${GREEN}Create New Profile${NC}"

echo -n "Enter your choice [1-2]: "
read choice

if [ "$choice" -eq 1 ]; then
  if [ ${#git_profiles[@]} -eq 0 ]; then
    echo -e "${RED}No profiles available. Please create a new profile.${NC}"
  else
    echo -e "${YELLOW}Available Git profiles:${NC}"
    index=1
    for profile in "${!git_profiles[@]}"; do
      IFS=":" read -r user_name user_email <<< "${git_profiles[$profile]}"
      echo -e "$index) ${GREEN}$profile${NC} - Username: $user_name, Email: $user_email"
      ((index++))
    done
    echo -n "Enter the number of the profile to switch to: "
    read profile_choice
    if [ "$profile_choice" -ge 1 ] && [ "$profile_choice" -le "${#git_profiles[@]}" ]; then
      selected_profile=$(echo "${!git_profiles[@]}" | cut -d ' ' -f "$profile_choice")
      IFS=":" read -r user_name user_email <<< "${git_profiles[$selected_profile]}"
      animate "Switching to $selected_profile profile"
      git config --global user.name "$user_name"
      git config --global user.email "$user_email"
      echo -e "${GREEN}Switched to $selected_profile profile.${NC}"
    else
      echo -e "${RED}Invalid choice! Please select a valid profile.${NC}"
    fi
  fi
elif [ "$choice" -eq 2 ]; then
  echo -n "Enter a name for your new Git profile: "
  read new_profile_name
  echo -n "Enter your Git username: "
  read new_user_name
  echo -n "Enter your Git email: "
  read new_user_email

  ssh_key_path="$HOME/.ssh/id_rsa_$new_profile_name"
  ssh-keygen -t rsa -b 4096 -C "$new_user_email" -f "$ssh_key_path"

  eval "$(ssh-agent -s)"

  ssh-add "$ssh_key_path"

  git_profiles["$new_profile_name"]="$new_user_name:$new_user_email"
  save_profiles

  animate "Creating and switching to new Git profile"
  git config --global user.name "$new_user_name"
  git config --global user.email "$new_user_email"
  echo -e "${GREEN}New Git profile created and switched to:${NC}"
  echo -e "${GREEN}Profile Name: $new_profile_name${NC}"
  echo -e "${GREEN}Username: $new_user_name${NC}"
  echo -e "${GREEN}Email: $new_user_email${NC}"
  echo -e "${GREEN}SSH Key generated at: $ssh_key_path${NC}"
  echo -e "${GREEN}SSH Key added to the ssh-agent.${NC}"

  echo -e "${YELLOW}Here is your public SSH key:${NC}"
  cat "${ssh_key_path}.pub"

  echo -e "\n${YELLOW}To add this SSH key to GitHub:${NC}"
  echo -e "1. Copy the entire SSH key displayed above."
  echo -e "2. Go to GitHub and sign in to your account."
  echo -e "3. Click on your profile picture in the top-right corner, then go to ${GREEN}Settings${NC}."
  echo -e "4. In the ${GREEN}Access${NC} section of the left sidebar, click on ${GREEN}SSH and GPG keys${NC}."
  echo -e "5. Click the ${GREEN}New SSH key${NC} button."
  echo -e "6. Give your SSH key a title and paste the key into the 'Key' field."
  echo -e "7. Click ${GREEN}Add SSH key${NC} to save."

  echo -e "\n${YELLOW}Enter 'yes' when you've added the SSH key to GitHub, and I'll test the connection for you:${NC}"
  read added_key_response

  if [[ "$added_key_response" == "yes" ]]; then
    echo -e "${GREEN}Testing SSH connection to GitHub...${NC}"
    ssh -T git@github.com
  else
    echo -e "${RED}Please add the SSH key to GitHub and then run the test manually with: ssh -T git@github.com${NC}"
  fi
else
  echo -e "${RED}Invalid choice! Please select a valid option.${NC}"
fi
