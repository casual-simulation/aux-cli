#!/bin/bash
set -e

if [ -f /etc/auxcli/config.json ]; then
    verbose=$(jq -r '.verbose' /etc/auxcli/config.json) 
else
    verbose=false
fi

install_deps() {
    sudo apt-get install -y git jq
}

backup() {
    sudo mv -f /bin/auxcli /bin/auxcli-bkp
    sudo mv -f /lib/auxcli /lib/auxcli-bkp
    sudo mv -f /etc/auxcli /etc/auxcli-bkp
}

clone_repo() {
    git clone --single-branch --branch 2.0.0 https://github.com/casual-simulation/aux-cli.git /home/pi/auxcli
    # git clone https://github.com/casual-simulation/aux-cli.git /home/pi/auxcli
}

deploy_files() {
    if [ ! -e /data/drives ]; then
        sudo mkdir -p /data/drives
    fi

    if [ ! -e /srv ]; then
        sudo mkdir /srv
    fi
    
    sudo cp -rf /home/pi/auxcli/data/* /data
    sudo cp -rf /home/pi/auxcli/srv/* /srv

    sudo cp -rf /home/pi/auxcli/bin/* /bin
    sudo cp -rf /home/pi/auxcli/lib/* /lib
    sudo cp -rf /home/pi/auxcli/etc/* /etc

}

enable_services(){
    sudo systemctl enable auxcli-web
    sudo systemctl start auxcli-web  
}

    jq '(.version) = "1.2.2"' 1.json | sudo tee 3.json 1> /dev/null


update_conf() {
    # Have a larger one-time use instead of making a process to check for installed/available

    # Find config files from these backups
    for bkp_config in $(find /lib/auxcli-bkp /etc/auxcli-bkp -name '*.json'); do 

        if $verbose; then printf "\nDEBUG (install.sh): Backup config file:\t%s.\n" "${bkp_config}"; fi

        # Get the new_config from modifying the bkp_config
        new_config="${bkp_config/auxcli-bkp/auxcli}"
        if $verbose; then printf "DEBUG (install.sh): New config file:\t\t%s.\n" "${new_config}"; fi

        tmp="$new_config.tmp"
        if $verbose; then printf "DEBUG (install.sh): Temp config file:\t%s.\n" "${tmp}"; fi

        if [ $new_config == "/etc/auxcli/commands.json" ]; then

            if $verbose; then printf "DEBUG (install.sh): Updating commands.json\n"; fi

            # Get array of available things
            available=($(jq -r '.[] | select(.available == true) | .name' $bkp_config)) 
            if $verbose; then printf "DEBUG (install.sh): Available commands from bkp_config: %s\n" "${available[*]}"; fi

            # Write those to the new config
            for command in "${available[@]}"; do
                if $verbose; then printf "DEBUG (install.sh): Setting command %s to available in the new_config.\n" "${command}"; fi
                jq --arg com "$command" '(.[] | select( .name == $com ) | .available) = true' $new_config | sudo tee $tmp 1> /dev/null
                sudo mv -f $tmp $new_config
            done

        elif [ $new_config == "/etc/auxcli/components.json" ]; then

            if $verbose; then printf "DEBUG (install.sh): Updating components.json\n"; fi

            # Get array of installed things
            installed=($(jq '.[] | select(.installed == true) | .name' $bkp_config)) 
            if $verbose; then printf "DEBUG (install.sh): Installed components from bkp_config: %s\n" "${installed[*]}"; fi
            enabled=($(jq '.[] | select(.enabled == true) | .name' $bkp_config))  
            if $verbose; then printf "DEBUG (install.sh): Enabled components from bkp_config: %s\n" "${enabled[*]}"; fi
            disabled=($(jq '.[] | select(.enabled == false) | .name' $bkp_config)) 
            if $verbose; then printf "DEBUG (install.sh): Disabled components from bkp_config: %s\n" "${disabled[*]}"; fi

            # Write those to the new config
            for component in "${installed[@]}"; do
                if $verbose; then printf "DEBUG (install.sh): Setting component %s to installed in the new_config.\n" "${component}"; fi
                jq --arg com "$component" '(.[] | select( .name == $com ) | .installed) = true' $new_config | sudo tee $tmp 1> /dev/null
                sudo mv -f $tmp $new_config
            done
            for component in "${enabled[@]}"; do
                if $verbose; then printf "DEBUG (install.sh): Setting component %s to enabled in the new_config.\n" "${component}"; fi
                jq --arg com "$component" '(.[] | select( .name == $com ) | .enabled) = true' $new_config | sudo tee $tmp 1> /dev/null
                sudo mv -f $tmp $new_config
            done
            for component in "${disabled[@]}"; do
                if $verbose; then printf "DEBUG (install.sh): Setting component %s to disabled in the new_config.\n" "${component}"; fi
                jq --arg com "$component" '(.[] | select( .name == $com ) | .enabled) = false' $new_config | sudo tee $tmp 1> /dev/null
                sudo mv -f $tmp $new_config
            done

        elif [ $new_config == "/etc/auxcli/config.json" ]; then

            if $verbose; then printf "DEBUG (install.sh): Updating config.json\n"; fi

            # Get new version number
            new_ver=$(jq -r '.version' $new_config)
            if $verbose; then printf "DEBUG (install.sh): New Version is %s.\n" "${new_ver}"; fi

            # Merge
            jq -s '.[0] * .[1]' $new_config $bkp_config | sudo tee $tmp 1> /dev/null
            sudo mv -f $tmp $new_config

            # Write new version back onto the new file
            jq --arg ver "$new_ver" '(.version) = $ver' $new_config | sudo tee $tmp 1> /dev/null
            sudo mv -f $tmp $new_config

        # elif [ $new_config == "/etc/auxcli/devices.json" ]; then

        #     if $verbose; then printf "DEBUG (install.sh): Updating devices.json\n"

        #     jq -s '.[0] * .[1]' $new_config $bkp_config 1> /dev/null
        else 
            echo "Config: $bkp_config is not being saved at all."
        fi
    done
}

cleanup() {
    if [ -e /home/pi/auxcli ]; then
        sudo rm -rf /home/pi/auxcli
    fi
    if [ -e /home/pi/auxcli-bkp ]; then
        sudo rm -rf /home/pi/auxcli-bkp
    fi
    if [ -e /bin/auxcli-bkp ]; then
        sudo rm -rf /bin/auxcli-bkp
    fi
    if [ -e /lib/auxcli-bkp ]; then
        sudo rm -rf /lib/auxcli-bkp
    fi
    if [ -e /etc/auxcli-bkp ]; then
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
