#!/usr/bin/bash

# ELevate Helper
# BASH script to help upgrade Rocky Linux 8 servers with Alma Linux ELevate tool
# ELevate Documentation: https://almalinux.org/elevate/
# By Nicholas Grogg

# Color variables
## Errors
red=$(tput setaf 1)
## Clear checks
green=$(tput setaf 2)
## User input required
yellow=$(tput setaf 3)
## Set text back to standard terminal font
normal=$(tput sgr0)

# Help function
function helpFunction(){
    printf "%s\n" \
    "Help" \
    "----------------------------------------------------" \
    "Script to upgrade Rocky Linux 8 servers to Rocky 9" \
    "Uses the Alma Linux ELevate tool" \
    "Each step is guided, run script as root" \
    " " \
    "help/Help" \
    "* Display this help message and exit" \
    " " \
    "prep/Prep " \
    "* Prep server for upgrade to Rocky 9" \
    " " \
    "Usage: ./elevateHelper.sh prep" \
    " " \
    "upgrade/Upgrade" \
    "* Upgrade server to Rocky 9" \
    " " \
    "Usage: ./elevateHelper.sh upgrade" \
    " " \
    "post/Post" \
    "* Run post-upgrade checks to ensure upgrade was successful" \
    " " \
    "Usage: ./elevateHelper.sh post"
}

# Function to Prep server
function prepFunction(){
    printf "%s\n" \
    "Pre-Upgrade" \
    "----------------------------------------------------"

    ## Validation
    ### Check if user is root
    printf "%s\n" \
    "Checking if user is root "\
    "----------------------------------------------------" \
    " "
    if [[ "$EUID" -eq 0 ]]; then
        printf "%s\n" \
        "${green}User is root "\
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    else
        printf "%s\n" \
        "${red}ISSUE DETECTED - User is NOT root "\
        "----------------------------------------------------" \
        "Re-run script as root${normal}"
        exit 1
    fi

    ### Check available disk space

    ## Value Confirmation
    printf "%s\n" \
    "${yellow}IMPORTANT: Value Confirmation" \
    "----------------------------------------------------" \
    "Hostname: " "$(hostname)" \
    "Before proceeding confirm the following:" \
    "1. In screen session" \
    "2. Snapshots taken first" \
    "3. Running script as root" \
        "4. Server rebooted to ensure newest kernel in use"\
        "5. At least 10 GB of disk space is available" \
        " " \
    "If all clear, press enter to proceed or ctrl-c to cancel${normal}" \
    " "

    ## Update

    ## Check for fail conditions
    ### Check if loaded kernel is the newest kernel
    ### Check for chattr'd files
    ### Check for NFS
    ### Check for Samba

    ## Check for potential fail conditions
    ### Check for /opt and /home processes
    ### Check for packages that cause conflicts

    ## Leapp test
    #TODO: Adjustments based on test

    ## Repo adjustments

    ## Re-perform Leapp test
    ### Are there still inhibitors in the logs?

}

# Function to
function upgradeFunction(){
    printf "%s\n" \
    "Upgrade" \
    "----------------------------------------------------"

    ## Variables
    ### Set ELevate Leapp container size, adjust as needed
    export LEAPP_OVL_SIZE=10240

    ## Validation
    ### Check if user is root
    printf "%s\n" \
    "Checking if user is root "\
    "----------------------------------------------------" \
    " "
    if [[ "$EUID" -eq 0 ]]; then
        printf "%s\n" \
        "${green}User is root "\
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    else
        printf "%s\n" \
        "${red}ISSUE DETECTED - User is NOT root "\
        "----------------------------------------------------" \
        "Re-run script as root${normal}"
        exit 1
    fi

    ## Confirmation

    ## Run upgrade function

    ## If function fails check for and output errors in the logs

    ## If function fails check for inhibitor messages in the logs

    ## Otherwise function succeeded, prompt user that server will reboot

    ## Reboot to begin upgrade

}

# Function to
function postFunction(){
    printf "%s\n" \
    "Post-Upgrade" \
    "----------------------------------------------------"

    ## Validation
    ### Check if user is root
    printf "%s\n" \
    "Checking if user is root "\
    "----------------------------------------------------" \
    " "
    if [[ "$EUID" -eq 0 ]]; then
        printf "%s\n" \
        "${green}User is root "\
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    else
        printf "%s\n" \
        "${red}ISSUE DETECTED - User is NOT root "\
        "----------------------------------------------------" \
        "Re-run script as root${normal}"
        exit 1
    fi

    ## Value Confirmation

    ## Configure DNF if settings not present

    ## Re-install conflicting software, expand as needed from prep step

    ## Enable repos, expand as needed

    ## Update server

    ## Remove/re-install el8 packages not upgraded by leapp

    ## List failed services (if any)

    ## List remaining el8 packages to remove/re-install (if any)

    ## Regenerate GRUB menu

    ## Final steps, expand as needed

}

# Main, read passed flags
printf "%s\n" \
"Elevate Helper" \
"----------------------------------------------------" \
" " \
"Checking flags passed" \
"----------------------------------------------------"

# Check passed flags
case "$1" in
[Hh]elp)
    printf "%s\n" \
    "Running Help function" \
    "----------------------------------------------------"
    helpFunction
    exit 0
    ;;
[Pp]rep)
    printf "%s\n" \
    "Running Pre-Upgrade function" \
    "----------------------------------------------------"
    prepFunction
    ;;
[Uu]pgrade)
    printf "%s\n" \
    "Running Upgrade Function" \
    "----------------------------------------------------"
    upgradeFunction
    ;;
[Pp]ost)
    printf "%s\n" \
    "Running Post-Upgrade Function" \
    "----------------------------------------------------"
    postFunction
    ;;
*)
    printf "%s\n" \
    "${red}ISSUE DETECTED - Invalid input detected!" \
    "----------------------------------------------------" \
    "Running help script and exiting." \
    "Re-run script with valid input${normal}"
    helpFunction
    exit
    ;;
esac
