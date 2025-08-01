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

}

# Function to
function upgradeFunction(){
    printf "%s\n" \
    "Upgrade" \
    "----------------------------------------------------"

    ## Validation

}

# Function to
function postFunction(){
    printf "%s\n" \
    "Post-Upgrade" \
    "----------------------------------------------------"

    ## Validation

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
