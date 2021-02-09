#!/bin/bash
set -e

if [ -f /etc/auxcli/config.json ]; then
    debug=$(jq -r '.debug' /etc/auxcli/config.json) 
else
    debug=true
fi

install_deps() {
    if $debug; then printf "DEBUG (install.sh): Installing dependencies.\n"; fi
    sudo apt-get install -y git jq
}

backup() {
    if $debug; then printf "DEBUG (install.sh): Backing up install.\n"; fi
    sudo mv -f /bin/auxcli /bin/auxcli-bkp
    sudo mv -f /lib/auxcli /lib/auxcli-bkp
    sudo mv -f /etc/auxcli /etc/auxcli-bkp
}

clone_repo() {
    if $debug; then printf "DEBUG (install.sh): Cloning repo.\n"; fi
    git clone --single-branch --branch 2.0.0 https://github.com/casual-simulation/aux-cli.git /home/pi/auxcli
    # git clone https://github.com/casual-simulation/aux-cli.git /home/pi/auxcli
}

deploy_files() {
    if $debug; then printf "DEBUG (install.sh): Deploying files.\n"; fi
    if [ ! -e /data/drives ]; then
        if $debug; then printf "DEBUG (install.sh): /data/drives does not exist.\n"; fi
        if $debug; then printf "DEBUG (install.sh): Creating /data/drives\n"; fi
        sudo mkdir -p /data/drives
    fi

    if [ ! -e /srv ]; then
        if $debug; then printf "DEBUG (install.sh): /srv does not exist.\n"; fi
        if $debug; then printf "DEBUG (install.sh): Creating /srv\n"; fi
        sudo mkdir /srv
    fi
    
    if $debug; then printf "DEBUG (install.sh): Copying files into /data\n"; fi
    sudo cp -rf /home/pi/auxcli/data/* /data

    if $debug; then printf "DEBUG (install.sh): Copying files into /srv\n"; fi
    sudo cp -rf /home/pi/auxcli/srv/* /srv

    if $debug; then printf "DEBUG (install.sh): Copying files into /bin\n"; fi
    sudo cp -rf /home/pi/auxcli/bin/* /bin

    if $debug; then printf "DEBUG (install.sh): Copying files into /lib\n"; fi
    sudo cp -rf /home/pi/auxcli/lib/* /lib

    if $debug; then printf "DEBUG (install.sh): Copying files into /etc\n"; fi
    sudo cp -rf /home/pi/auxcli/etc/* /etc

}

enable_services() {
    if $debug; then printf "DEBUG (install.sh): Enabling auxcli-web service.\n"; fi
    sudo systemctl enable auxcli-web
    
    if $debug; then printf "DEBUG (install.sh): Starting auxcli-web service.\n"; fi
    sudo systemctl start auxcli-web  
}

update_conf() {
    if $debug; then printf "DEBUG (install.sh): Updating config files.\n"; fi

    # Have a larger one-time use instead of making a process to check for installed/available

    # Find config files from these backups
    for bkp_config in $(find /lib/auxcli-bkp /etc/auxcli-bkp -name '*.json'); do 

        if $debug; then printf "\nDEBUG (install.sh): Backup config file:\t%s.\n" "${bkp_config}"; fi

        # Get the new_config from modifying the bkp_config
        new_config="${bkp_config/auxcli-bkp/auxcli}"
        if $debug; then printf "DEBUG (install.sh): New config file:\t\t%s.\n" "${new_config}"; fi

        tmp="$new_config.tmp"
        if $debug; then printf "DEBUG (install.sh): Temp config file:\t%s.\n" "${tmp}"; fi

        if [ $new_config == "/etc/auxcli/commands.json" ]; then

            if $debug; then printf "DEBUG (install.sh): Updating commands.json\n"; fi

            # Get array of available things
            available=($(jq -r '.[] | select(.available == true) | .name' $bkp_config)) 
            if $debug; then printf "DEBUG (install.sh): Available commands from bkp_config: %s\n" "${available[*]}"; fi

            # Write those to the new config
            for command in "${available[@]}"; do
                if $debug; then printf "DEBUG (install.sh): Setting command %s to available in the new_config.\n" "${command}"; fi
                jq --arg com "$command" '(.[] | select( .name == $com ) | .available) = true' $new_config | sudo tee $tmp 1> /dev/null
                sudo mv -f $tmp $new_config
            done

        elif [ $new_config == "/etc/auxcli/components.json" ]; then

            if $debug; then printf "DEBUG (install.sh): Updating components.json\n"; fi

            # Get array of installed things
            installed=($(jq '.[] | select(.installed == true) | .name' $bkp_config)) 
            if $debug; then printf "DEBUG (install.sh): Installed components from bkp_config: %s\n" "${installed[*]}"; fi
            enabled=($(jq '.[] | select(.enabled == true) | .name' $bkp_config))  
            if $debug; then printf "DEBUG (install.sh): Enabled components from bkp_config: %s\n" "${enabled[*]}"; fi
            disabled=($(jq '.[] | select(.enabled == false) | .name' $bkp_config)) 
            if $debug; then printf "DEBUG (install.sh): Disabled components from bkp_config: %s\n" "${disabled[*]}"; fi

            # Write those to the new config
            for component in "${installed[@]}"; do
                if $debug; then printf "DEBUG (install.sh): Setting component %s to installed in the new_config.\n" "${component}"; fi
                jq --arg com "$component" '(.[] | select( .name == $com ) | .installed) = true' $new_config | sudo tee $tmp 1> /dev/null
                sudo mv -f $tmp $new_config
            done
            for component in "${enabled[@]}"; do
                if $debug; then printf "DEBUG (install.sh): Setting component %s to enabled in the new_config.\n" "${component}"; fi
                jq --arg com "$component" '(.[] | select( .name == $com ) | .enabled) = true' $new_config | sudo tee $tmp 1> /dev/null
                sudo mv -f $tmp $new_config
            done
            for component in "${disabled[@]}"; do
                if $debug; then printf "DEBUG (install.sh): Setting component %s to disabled in the new_config.\n" "${component}"; fi
                jq --arg com "$component" '(.[] | select( .name == $com ) | .enabled) = false' $new_config | sudo tee $tmp 1> /dev/null
                sudo mv -f $tmp $new_config
            done

        elif [ $new_config == "/etc/auxcli/config.json" ]; then

            if $debug; then printf "DEBUG (install.sh): Updating config.json\n"; fi

            # Get new version number
            new_ver=$(jq -r '.version' $new_config)
            if $debug; then printf "DEBUG (install.sh): New Version is %s.\n" "${new_ver}"; fi

            # Merge
            jq -s '.[0] * .[1]' $new_config $bkp_config | sudo tee $tmp 1> /dev/null
            sudo mv -f $tmp $new_config

            # Write new version back onto the new file
            jq --arg ver "$new_ver" '(.version) = $ver' $new_config | sudo tee $tmp 1> /dev/null
            sudo mv -f $tmp $new_config

        # elif [ $new_config == "/etc/auxcli/devices.json" ]; then

        #     if $debug; then printf "DEBUG (install.sh): Updating devices.json\n"

        #     jq -s '.[0] * .[1]' $new_config $bkp_config 1> /dev/null
        else 
            echo "Config: $bkp_config is not being saved at all."
        fi
    done
}

cleanup() {
    if [ -e /home/pi/auxcli ]; then
        if $debug; then printf "DEBUG (install.sh): /home/pi/auxcli exists.\n"; fi
        if $debug; then printf "DEBUG (install.sh): Removing /home/pi/auxcli\n"; fi
        sudo rm -rf /home/pi/auxcli
    fi
    if [ -e /home/pi/auxcli-bkp ]; then
        if $debug; then printf "DEBUG (install.sh): /home/pi/auxcli-bkp exists.\n"; fi
        if $debug; then printf "DEBUG (install.sh): Removing /home/pi/auxcli-bkp\n"; fi
        sudo rm -rf /home/pi/auxcli-bkp
    fi
    if [ -e /bin/auxcli-bkp ]; then
        if $debug; then printf "DEBUG (install.sh): /bin/auxcli-bkp exists.\n"; fi
        if $debug; then printf "DEBUG (install.sh): Removing /bin/auxcli-bkp\n"; fi
        sudo rm -rf /bin/auxcli-bkp
    fi
    if [ -e /lib/auxcli-bkp ]; then
        if $debug; then printf "DEBUG (install.sh): /lib/auxcli-bkp exists.\n"; fi
        if $debug; then printf "DEBUG (install.sh): Removing /lib/auxcli-bkp\n"; fi
        sudo rm -rf /lib/auxcli-bkp
    fi
    if [ -e /etc/auxcli-bkp ]; then
        if $debug; then printf "DEBUG (install.sh): /etc/auxcli-bkp exists.\n"; fi
        if $debug; then printf "DEBUG (install.sh): Removing /etc/auxcli-bkp\n"; fi
        sudo rm -rf /etc/auxcli-bkp
    fi
}

install() {
    install_deps
    clone_repo
    deploy_files
    enable_services
    cleanup
}

update() {
    install_deps
    backup
    clone_repo
    deploy_files
    enable_services
    update_conf
    cleanup
}

revert() {
    echo "Update failed. Reverting to previous version."
    sudo rm -rf /bin/auxcli
    sudo rm -rf /lib/auxcli
    sudo rm -rf /etc/auxcli

    sudo mv /bin/auxcli-bkp /bin/auxcli
    sudo mv /lib/auxcli-bkp /lib/auxcli
    sudo mv /etc/auxcli-bkp /lib/auxcli
}

run_steps() {
    if [ -e /bin/auxcli ]; then
        trap revert ERR
        echo "AUXCLI is already installed."
        echo "Updating AUXCLI..."
        update
    else
        echo "Installing AUXCLI..."
        install
    fi
}

run_steps
