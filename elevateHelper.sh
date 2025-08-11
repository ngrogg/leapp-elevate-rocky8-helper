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
    #### Default required disk space is around 10 GB, adjust as needed
    requiredSpace=10

    #### Get available disk space
    availableSpace=$(df / -h | awk 'NR==2 {print $4}' | rev | cut -c2- | rev)

    #### Parse out space type (Should be G or T)
    spaceType=$(df / -h | awk 'NR==2 {print $4}' | sed -E 's/.*(.)/\1/')

    #### If available disk space < size constraint, exit w/ error
    if [[ $(bc <<< "$availableSpace < $requiredSpace") == "1" && "$spaceType" == "G" ]]; then

        printf "%s\n" \
        "${red}ISSUE DETECTED - INSUFFICIENT DISK SPACE!" \
        "----------------------------------------------------" \
        "Disk Space Required " "$requiredSpace" \
        "Disk Space Available " "$availableSpace" \
        "Free up or add more disk space." \
        "Exiting!${normal}"
        exit 1
    fi

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
    ### Update system
    sudo dnf update -y && sudo dnf upgrade -y && sudo dnf autoremove -y

    ### If previous command fails, exit w/ error message
    if [[ $? != 0 ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - DNF RETURNED NON-0 VALUE!" \
        "----------------------------------------------------" \
        "Review any errors detailed above, exiting!${normal}"
        exit 1

    else
        printf "%s\n" \
        "${green}Yum Updates Applied" \
        "----------------------------------------------------" \
        "Proceeding${normal}"
    fi

    ### Install required packages
    #### yum-utils for package-cleanup command
    sudo dnf install -y \
        yum-utils

    ## Check for fail conditions
    ### Check if loaded kernel is the newest kernel
    printf "%s\n" \
    "Checking if currently loaded kernel is newest kernel" \
    "----------------------------------------------------" \
    " "

    ## Check if running kernel matches newest installed kernel
    newestKernel=$(find /boot/vmlinuz-* | sort -V | tail -n 1 | sed 's|.*vmlinuz-||')
    runningKernel=$(uname -r)
    if [[ "$newestKernel" != "$runningKernel" ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Newest kernel not loaded!" \
        "----------------------------------------------------" \
        "Currently loaded Kernel: " "$runningKernel" \
        "Newest installed Kernel: " "$newestKernel" \
        "Reboot server to load newest installed kernel" \
        "After reboot re-run script ${normal}"
        exit 1
    else
        printf "%s\n" \
        "${green}Newest Installed Kernel running" \
        "----------------------------------------------------" \
        "Proceeding${normal}"
    fi

    ### Check for chattr'd dnf files
    if [[ $(lsattr /etc/dnf/dnf.conf | grep "\-i\-") || $(lsattr /etc/yum.repos.d/* | grep "\-i\-") ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - chattrd dnf files found!" \
        "----------------------------------------------------" \
        "Review and unchattr the files listed below" \
        "Re-run script once review complete!${normal}"
        lsattr /etc/yum.conf | grep "\-i\-"
        lsattr /etc/yum.repos.d/* | grep "\-i\-"
        exit 1
    else
        printf "%s\n" \
        "${green}No Chattrd yum files found" \
        "----------------------------------------------------" \
        "Proceeding${normal}"
    fi

    ### Remove duplicate packages
    sudo package-cleanup --cleandupes -y

    #TODO
    ### Check for NFS

    #TODO
    ### Check for Samba

    ## Check for potential fail conditions or problem areas
    ### Check for /opt and /home processes
    printf "%s\n" \
    "Checking for /opt and /home processes" \
    "----------------------------------------------------" \
    " "

    ### Check for processes in /opt and /home folders. Update grep filter as needed
    if [[ $(ps aux | grep -i -E "/opt|/home" | grep -v -i "grep") ]]; then
        printf "%s\n" \
        "${yellow}IMPORTANT: /opt or /home processes found "\
        "----------------------------------------------------" \
        "These may be important non-standard processes" \
        " " \
        "Note the following processes below${normal}" \
        " "

        #### List processes running out of /home or /opt. Update grep filter as needed as needed
        ps aux | grep -i -E "/opt|/home" | grep -v -i "grep"

        printf "%s\n" \
        " " \
        "${yellow}IMPORTANT: Press Enter when ready to proceed${normal}" \
        " "
        read junkInput
    else
        printf "%s\n" \
        "${green}No /opt or /home processes found "\
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    fi

    ### Remove packages that caused conflicts
    #### rocky-logos causes a package conflict on upgrade
    if [[ $(dnf list installed | grep rocky-logos) ]]; then
            dnf remove rocky-logos -y
    fi

    #### bash-completion causes a package conflig on upgade
    if [[ $(dnf list installed | grep bash-completion) ]]; then
            dnf remove bash-completion -y
    fi

    ## Install ELevate repo and leapp tool
    sudo dnf install -y http://repo.almalinux.org/elevate/elevate-release-latest-el$(rpm --eval %rhel).noarch.rpm
    sudo dnf install -y leapp-upgrade leapp-data-rocky

    ## Leapp tests
    ### Populate leapp log
    sudo leapp preupgrade

    ### Remote login w/ root account
    if [[ $(grep PermitRootLogin /etc/ssh/sshd_config) ]]; then
            sed -i "s/PermitRootLogin\ yes/PermitRootLogin\ no/g" /etc/ssh/sshd_config
            sudo systemctl restart sshd
    fi

    ### Firewalld AllowZoneDrifting, make adjustment if firewalld conf exists
    if [[ -f /etc/firewalld/firewalld.conf ]]; then
            if [[ $(grep "AllowZoneDrifting=yes" /etc/firewalld/firewalld.conf ) ]]; then
                    sed -i "s/AllowZoneDrifting=yes/AllowZoneDrifting=no/g" /etc/firewalld/firewalld.conf
                    firewall-cmd --reload
            fi
    fi


    ## Repo adjustments, fill out as needed
    ### Adjusted EPEL to Rocky 9
    if [[ $(grep "enabled=1" /etc/yum.repos.d/epel.repo) ]]; then
            #### Update repo name
            sed -i "s/Linux\ 8/Linux\ 9/g" /etc/yum.repos.d/epel.repo
            #### Update repo URL
            sed -i "s/epel\/8/epel\/9/g" /etc/yum.repos.d/epel.repo
            #### Disable GPG check, needed for upgrade
            sed -i "s/gpgcheck=1/gpgcheck=0/g" /etc/yum.repos.d/epel.repo
    fi

    ## Re-perform Leapp test
    sudo leapp preupgrade

    ## Are there still inhibitors in the logs?
    if [[ $(grep inhibitor /var/log/leapp/leapp-report.txt -l) ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Inhibitor level errors found "\
        "----------------------------------------------------" \
        "Review/resolve manually " \
        "See /var/log/leapp/leapp-report.txt " \
        "Run sudo leapp preupgrade when complete to re-check " \
        "Snippet of errors below for review${normal}"
        grep inhibitor /var/log/leapp/leapp-report.txt -C 5

        printf "%s\n" \
        "${red}Once review complete run: leapp preupgrade"\
        "If clear, run script with upgrade flags${normal}"

    #### Else no critical errors found, tell use to run upgrade function
    else
        printf "%s\n" \
        "${green}No Inhibitor level errors found "\
        "----------------------------------------------------" \
        "Re-run script with upgrade flags${normal}"
    fi
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
        "${red}ISSUE DETECTED - User is NOT root!"\
        "----------------------------------------------------" \
        "Re-run script as root or with sudo permissions!${normal}"
        exit 1
    fi

    ## Confirmation
    printf "%s\n" \
    "${yellow}IMPORTANT: Value Confirmation" \
    "----------------------------------------------------" \
    "Hostname: " "$(hostname)" \
    "Before proceeding confirm the following:" \
    "1. In screen session" \
    "2. Running script as root" \
    " " \
    "If all clear, press enter to proceed or ctrl-c to cancel${normal}"

    ## Press enter to proceed, control + c to cancel
    read junkInput

    ## Run upgrade function
    ### Truncate upgrade log in case function has been run before
    echo "" > /var/log/leapp/leapp-upgrade.log

    ### Upgrade to Rocky 9
    leapp upgrade

    ## If function fails check for and output errors in the logs
    if [[ $(grep "Error Summary" /var/log/leapp/leapp-upgrade.log) || $(grep "ERRORS" /var/log/leapp/leapp-upgrade.log | grep -v '/') ]]; then
        #### Message that errors were found in the log
        printf "%s\n" \
        "${red}ISSUE DETECTED - Error in leapp-upgrade.log" \
        "----------------------------------------------------" \
        "Review /var/log/leapp/leapp-upgrade.log" \
        "Snippet of error listed below" \
        "After resolving re-run script with upgrade function${normal}" \
        " "

        #### Output error messages
        grep -E "Error Summary|ERRORS" /var/log/leapp/leapp-upgrade.log -C 7

        #### Error message for disk space
        printf "%s\n" \
        " " \
        "${red}IMPORTANT" \
        "----------------------------------------------------" \
        "If error related to X MB needed on / filesystem" \
        "Run the following: export 'LEAPP_OVL_SIZE=11264'" \
        "Then upgrade manually: 'leapp upgrade'" \
        "If check clears, reboot to complete upgrade" \
        "If error persists, re-run export with larger value for LEAPP_OVL_SIZE"\
        "Be aware of available disk space before doing this!${normal}"

        exit 1
    fi

    ## If function fails check for inhibitor messages in the logs
    if [[ $(grep inhibitor /var/log/leapp/leapp-report.txt -l) ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Inhibitor level errors found "\
        "----------------------------------------------------" \
        "Review/resolve manually " \
        "See /var/log/leapp/leapp-report.txt " \
        "Run 'sudo leapp preupgrade' when complete to re-check " \
        "Snippet of errors below for review${normal}" \
        " "

        grep inhibitor /var/log/leapp/leapp-report.txt -C 5

        printf "%s\n" \
        "${red}Once review complete run 'leapp preupgrade'"\
        "If clear, run script with upgrade flags${normal}"

        exit 1
    fi

    ## Otherwise function succeeded, prompt user that server will reboot
    printf "%s\n" \
    "${yellow}IMPORTANT: Upgrade checks complete" \
    "----------------------------------------------------" \
    "Server ready to upgrade" \
    " " \
    "Press Enter to begin upgrade${normal}"

    read junkInput

    ## Reboot to begin upgrade
    sudo reboot

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
    printf "%s\n" \
    "${yellow}IMPORTANT: Value Confirmation" \
    "----------------------------------------------------" \
    "Hostname: " "$(hostname)" \
    "Before proceeding confirm the following:" \
    "1. In screen session" \
    "2. Running script as root" \
    "If all clear, press enter to proceed or ctrl-c to cancel${normal}" \
    " "

    ## Press enter to proceed, control + c to cancel
    read junkInput

    ## Configure DNF for parallel downloads if setting not present
    if [[ ! $(grep max_parallel_downloads /etc/dnf/dnf.conf) ]]; then
        echo "max_parallel_downloads=10" >> /etc/dnf/dnf.conf
    fi

    ## Re-install conflicting software, expand as needed from prep step
    sudo dnf install -y \
        rocky-logos \
        bash-completion

    ## Re-install repos, expand as needed
    #### Re-install EPEL
    if [[ $(grep "enabled=1" /etc/yum.repos.d/epel.repo) ]]; then
            ##### Remove EL8 version
            sudo dnf remove epel-release -y

            ##### Enable CodeReady Build Repo, replacement for PowerTools in RL9?
            sudo dnf config-manager --set-enabled crb

            ##### Install Rocky Linux 9 EPEL
            sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
    fi

    ## Remove/re-install el8 packages not upgraded by leapp, expand as needed
    ### Remove statement
    sudo dnf remove -y \
        elevate-release \
        kernel \
        kernel-modules \
        leapp-data-rocky

    ### Re-install statement
    sudo dnf install -y \
        kernel

    ## Update server
    sudo dnf update -y && sudo dnf upgrade -y && sudo dnf autoremove -y

    ## List failed services (if any)
    printf "%s\n" \
    "Checking for failed services"\
    "----------------------------------------------------" \
    "Review any errors returned"
    systemctl list-units --failed

    printf "%s\n" \
    "${yellow}IMPORTANT: Resolve any failed services if any"\
    "----------------------------------------------------" \
    "If necessary, open a new session" \
    "Resolve any failed services if listed above" \
    " " \
    "Press Enter when ready to proceed${normal}"

    ### Populate junk input
    read junkInput

    ## List remaining el8 packages to remove/re-install (if any)
    printf "%s\n" \
    "Checking for Rocky 8 packages"\
    "----------------------------------------------------" \
    "Remove/Reinstall any packages returned"

    if [[ $(yum list installed | grep el8) ]]; then
            yum list installed | grep el8
            printf "%s\n" \
            "${yellow}IMPORTANT: Rocky 8 packages found"\
            "----------------------------------------------------" \
            "Open a separate session" \
            "Remove/re-install packages listed above" \
            "Press Enter when ready to proceed${normal}"
            read junkInput
    fi

    ## Regenerate GRUB menu
    printf "%s\n" \
    "Regenerating GRUB menu"\
    "----------------------------------------------------" \
    " "

    grub2-mkconfig -o /boot/grub2/grub.cfg

    ## Final steps, expand as needed
    printf "%s\n" \
    "${green}Final Steps"\
    "----------------------------------------------------" \
    "Upgrade complete!" \
    " " \
    "Fill in based on server configuration needs${normal}"

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
