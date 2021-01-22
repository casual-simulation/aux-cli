#!/bin/bash
set -e

install_deps() {
    sudo apt-get install -y git jq
}

clone_repo() {
    git clone --single-branch --branch 2.0.0 https://github.com/casual-simulation/aux-cli.git /home/pi/auxcli
    # git clone https://github.com/casual-simulation/aux-cli.git /home/pi/auxcli
}

update_conf() {
    # Have a larger one-time use instead of making a process to check for installed/available

    # Find config files from these backups
    for bkp_config in $(find /lib/auxcli-bkp /etc/auxcli-bkp -name '*.json'); do 

        # Get the new_config from modifying the bkp_config
        new_config="${bkp_config/auxcli-bkp/auxcli}"
        tmp="$new_config.tmp"

        if [ $new_config == "/etc/auxcli/commands.json" ]; then
            # Get array of available things
            available=($(jq '.[] | select(.available == true) | .name' $bkp_config)) 

            # Write those to the new config
            for command in "${available[@]}"; do
                jq --arg com "$command" '(.[] | select( .name == $com ) | .available) = true' $new_config | sudo tee $tmp
                sudo mv -f $tmp $new_config
            done

        elif [ $new_config == "/etc/auxcli/components.json" ]; then
            # Get array of installed things
            installed=($(jq '.[] | select(.installed == true) | .name' $bkp_config)) 
            enabled=($(jq '.[] | select(.enabled == true) | .name' $bkp_config))  
            disabled=($(jq '.[] | select(.enabled == false) | .name' $bkp_config)) 

            # Write those to the new config
            for component in "${installed[@]}"; do
                jq --arg com "$component" '(.[] | select( .name == $com ) | .installed) = true' $new_config | sudo tee $tmp
                sudo mv -f $tmp $new_config
            done
            for component in "${enabled[@]}"; do
                jq --arg com "$component" '(.[] | select( .name == $com ) | .enabled) = true' $new_config | sudo tee $tmp
                sudo mv -f $tmp $new_config
            done
            for component in "${disabled[@]}"; do
                jq --arg com "$component" '(.[] | select( .name == $com ) | .enabled) = false' $new_config | sudo tee $tmp
                sudo mv -f $tmp $new_config
            done

        elif [ $new_config == "/etc/auxcli/config.json" ]; then
            # Get new version number
            new_ver=$(jq '.version' $new_config)

            # Merge
            jq -s '.[0] * .[1]' $new_config $bkp_config | sudo tee $tmp
            sudo mv -f $tmp $new_config

            # Write new version back onto the new file
            jq --arg ver "$new_ver" '(.version) = "$ver"' $new_config | sudo tee $tmp
            sudo mv -f $tmp $new_config

        # elif [ $new_config == "/etc/auxcli/devices.json" ]; then
        #     jq -s '.[0] * .[1]' $new_config $bkp_config
        else 
            echo "Config: $bkp_config is not being saved at all."
        fi
    done
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

backup() {
    sudo mv -f /bin/auxcli /bin/auxcli-bkp
    sudo mv -f /lib/auxcli /lib/auxcli-bkp
    sudo mv -f /etc/auxcli /etc/auxcli-bkp
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
