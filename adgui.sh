#!/usr/bin/env bash
# -------------------------------------------------------------
#  Adguard Interactive Menu (colored)
#
#  Requires: adguard-cli to be installed
#  Usage:    ./adgui.sh
# -------------------------------------------------------------

# ---- Check that adguard is available ---------------------------------
if ! command -v adguard-cli &>/dev/null; then
    echo "❌  'Adguard-cli' was not found. Please install it first."
    echo "⚠️ Adguard will be installed when pressing ENTER, In case you do not want too install, use the key combo: CTRL+C"
    read -p $'\nPress ENTER to install...'
    curl -fsSL https://raw.githubusercontent.com/AdguardTeam/AdGuardCLI/release/install.sh | sh -s -- -v
    exit 1
fi
# ---- VARIABLES ------------------------------

VERSION=$(adguard-cli --version)
USER=$(whoami)

# ---- ANSI color definitions ---------------------------------------
RESET='\e[0m'
HEADER_COLOR='\e[1;36m'   # bold cyan
OPTION_COLOR='\e[1;33m'   # bold yellow
PROMPT_COLOR='\e[1;32m'   # bold green
ERROR_COLOR='\e[1;31m'    # bold red
SUCCESS_COLOR='\e[1;32m'  # bold green

# ---- Helper functions -------------------------------------------------
show_menu() {
    clear
    echo -e "${HEADER_COLOR}+-------------------------+${RESET}"
    echo -e "${HEADER_COLOR}|   $VERSION   |${RESET}"          
    echo -e "${HEADER_COLOR}+-------------------------+${RESET}"
    echo -e "${HEADER_COLOR}| ${OPTION_COLOR}1) Show status          ${HEADER_COLOR}|${RESET}"
    echo -e "${HEADER_COLOR}| ${OPTION_COLOR}2) Update Adguard       ${HEADER_COLOR}|${RESET}"
    echo -e "${HEADER_COLOR}| ${OPTION_COLOR}3) Start Adguard        ${HEADER_COLOR}|${RESET}"
    echo -e "${HEADER_COLOR}| ${ERROR_COLOR}4) Stop Adguard         ${HEADER_COLOR}|${RESET}"
    echo -e "${HEADER_COLOR}| ${OPTION_COLOR}5) Filters menu         ${HEADER_COLOR}|${RESET}"
    echo -e "${HEADER_COLOR}| ${SUCCESS_COLOR}6) Export settings      ${HEADER_COLOR}|${RESET}"
    echo -e "${HEADER_COLOR}| ${SUCCESS_COLOR}7) Import settings      ${HEADER_COLOR}|${RESET}"
    echo -e "${HEADER_COLOR}| ${OPTION_COLOR}8) Generate certificate ${HEADER_COLOR}|${RESET}"
    echo -e "${HEADER_COLOR}| ${OPTION_COLOR}q) Quit                 ${HEADER_COLOR}|${RESET}"
    echo -e "${HEADER_COLOR}+-------------------------+${RESET}"
    echo -n -e "${PROMPT_COLOR}\nPlease choose an option (1‑9): ${RESET}"
   
    }

show_status() {
    echo -e "\n${SUCCESS_COLOR}Show adguard status...${RESET}"
    adguard-cli status
    read -p $'\nPress Enter to continue...'
}

update_adguard() {
    echo -e "\n${SUCCESS_COLOR}Updating Adguard...${RESET}"
    adguard-cli stop
    adguard-cli update
    adguard-cli start
    read -p $'\nPress Enter to continue...'
}

start_adguard() {
    echo -e "\n${SUCCESS_COLOR}Starting Adguard... ${RESET}"
    adguard-cli start    
    read -p $'\nPress Enter to continue...'
}

stop_adguard() {
    echo -e "${SUCCESS_COLOR}✅ Stopping Adguard... ${RESET}"
    adguard-cli stop
    read -p $'\nPress Enter to continue...'
}

function filters_menu() {
while true; do
        clear
        #MENU HEADER BEGIN    
        echo -e "${HEADER_COLOR}+-------------------------------------------------+${RESET}"
        echo -e "${HEADER_COLOR}|                 Adguard-cli  Menu               |${RESET}"
        echo -e "${HEADER_COLOR}|                $VERSION              |${RESET}"          
        echo -e "${HEADER_COLOR}+-------------------------------------------------+${RESET}"
        #MENU HEADER END
        
    	echo -e "${OPTION_COLOR}Bb (Show active filters)${RESET}"
        echo -e "${OPTION_COLOR}Ff (Add new intern filters)${RESET}"
        echo -e "${ERROR_COLOR}Oo (Remove an intern filter)${RESET}"
        echo -e "${OPTION_COLOR}Gg (Enable a filter)${RESET}"
        echo -e "${OPTION_COLOR}Gg (Disable a filter)${RESET}"
        echo -e "${OPTION_COLOR}Pp (View all available filters)${RESET}"
        echo -e "${HEADER_COLOR}Jj (Update filters)${RESET}"
        echo -e "${OPTION_COLOR}Qq (Back to the menu)${RESET}"
        read -p "Choose an option: " OPTMEN
    case $OPTMEN in
        [Bb]* ) adguard-cli filters list; read -p "Press ENTER " && clear;;
        [Ff]* ) echo "Enter a filter number: "; read NUMBER; adguard-cli filters add $NUMBER; read -p "Press ENTER " && clear;;
        [Oo]* ) echo "Enter a filter number: "; read NUMBER2; adguard-cli filters remove $NUMBER2; read -p "Press ENTER " && clear;;
        [Gg]* ) echo "Enter a filter number: "; read NUMBER3; adguard-cli filters enable $NUMBER3; read -p "Press ENTER " && clear;;
        [Mm]* ) echo "Enter a filter number: "; read NUMBER4; adguard-cli filters disable $NUMBER4; read -p "Press ENTER " && clear;;
        [Pp]* ) adguard-cli filters list --all; read -p "Press ENTER " && clear;;
        [Jj]* ) adguard-cli filters update; read -p "Press ENTER " && clear;;        
        [1]* )  read -p "Searching for the Easter Bunny arent ya! " && clear;;
        [Qq]* ) break && show_menu;;
        * )  notify-send 'Thats not an option' && break;;
    esac
done
}

export_settings() {
    echo -e "${SUCCESS_COLOR}✅ Exporting Settings.${RESET}"
    adguard-cli export-settings
    read -p $'\nPress Enter to continue...'
}

import_settings() {
    echo -e "${SUCCESS_COLOR}✅ Paste the path to  the .zip file down below to import.${RESET}"
    read PATHTOFILE
    adguard-cli import-settings -i "$PATHTOFILE"
    read -p $'\nPress Enter to continue...'
}

rgen_cert() {
    adguard-cli cert        
    sudo cp "/home/$USER/.local/share/adguard-cli/AdGuard CLI CA.pem" /etc/ca-certificates/trust-source/anchors/
    sudo trust extract-compat
    read -p $'\nPress Enter to continue...'
}


check_update() {
      echo -e "${HEADER_COLOR}+-------------------------------------------------+${RESET}"
      echo -e "${HEADER_COLOR}|                 Adguard-cli  Update               |${RESET}"
      echo -e "${HEADER_COLOR}|                $VERSION              |${RESET}"          
      echo -e "${HEADER_COLOR}+-------------------------------------------------+${RESET}"
            
      latest_version=$(adguard-cli --version)
      current_version=$latest_version            
          if [ "$current_version" != "AdGuard CLI x.x.x" ]; then
              echo -e "\n${SUCCESS_COLOR}* AdGuard CLI is up-to-date. No updates available.${RESET}"
              show_menu
              else
              echo -e "\n${ERROR_COLOR}⚠️  AdGuard CLI is not up-to-date. An update is available.${RESET}"
              echo -e "Current version: $current_version"
              echo -e "Update will be downloaded:"
              adguard-cli update
          fi                 
}

#Check for updates before starting mainloop (to prevent constantly checking updates after user inputs)
check_update
# ---- Main interactive loop ------------------------------------------
while true; do
    show_menu
    read choice
    case "$choice" in
        1) show_status ;;
        2) update_adguard ;;
        3) start_adguard  ;;
        4) stop_adguard  ;;
        5) filters_menu  ;;
        6) export_settings ;;
        7) import_settings ;;
        8) gen_cert ;;
        q) echo -e "${HEADER_COLOR}Thank you for using this adguard-cli script by ${ERROR_COLOR}CodingAlphaWolf!${RESET}"; exit 0 ;;
        *) echo -e "${ERROR_COLOR}⚠️  Invalid choice. Please select a number from 1 to 9.${RESET}"
           read -p $'\nPress Enter to continue...' ;;
    esac
done


