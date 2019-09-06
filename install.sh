#!/bin/bash
set -e

install_deps() {

    if git --version >/dev/null 2>&1; then
        echo "GIT is already installed."
    else
        sudo apt-get install -y git
    fi
}

clone_repo() {
    git clone --single-branch --branch develop https://github.com/casual-simulation/aux-cli.git /home/pi/aux-cli
    # git clone https://github.com/casual-simulation/aux-cli.git /home/pi/aux-cli
}

deploy_files() { 
    sudo cp -rf /home/pi/aux-cli/bin /
    sudo cp -rf /home/pi/aux-cli/etc /
    sudo cp -rf /home/pi/aux-cli/lib /
}

make_executable() { # TODO: make this less bad
    chmod +x /bin/aux-cli
    chmod +x /lib/aux-cli/startup
    chmod +x /lib/aux-cli/modules/install
    chmod +x /lib/aux-cli/modules/uninstall
    chmod +x /lib/aux-cli/modules/pishrink
    chmod +x /lib/aux-cli/modules/raspiwifi
    chmod +x /lib/aux-cli/modules/rfid
    chmod +x /lib/aux-cli/modules/zerotier
    chmod +x /lib/aux-cli/modules/tethering
    chmod +x /lib/aux-cli/util/backup
    chmod +x /lib/aux-cli/util/changehost
    chmod +x /lib/aux-cli/util/restart
    chmod +x /lib/aux-cli/util/start
    chmod +x /lib/aux-cli/util/stop
    chmod +x /lib/aux-cli/util/update
    chmod +x /lib/aux-cli/util/dhcpcd
    chmod +x /lib/aux-cli/util/hotspot
}

cleanup() {
    if [ -e /home/pi/aux-cli ]; then
        sudo rm -rf /home/pi/aux-cli
    fi
    if [ -e /home/pi/aux-cli-bkp ]; then
        sudo rm -rf /home/pi/aux-cli-bkp
    fi
    if [ -e /bin/aux-cli-bkp ]; then
        sudo rm -rf /bin/aux-cli-bkp
    fi
    if [ -e /lib/aux-cli-bkp ]; then
        sudo rm -rf /lib/aux-cli-bkp
    fi
}

backup() {
    if [ -e /home/pi/aux-cli ]; then
        sudo mv /home/pi/aux-cli /home/pi/aux-cli-bkp
    fi
    sudo mv /bin/aux-cli /bin/aux-cli-bkp
    sudo mv /lib/aux-cli /lib/aux-cli-bkp
}

install() { 
    install_deps
    clone_repo
    deploy_files
    make_executable
    cleanup
}

update() {
    install_deps
    backup
    clone_repo
    deploy_files
    make_executable
    cleanup
}

revert() {
    echo "Update failed. Reverting to previous version."
    sudo rm -rf /home/pi/aux-cli
    sudo rm -rf /bin/aux-cli
    sudo rm -rf /lib/aux-cli

    sudo mv /home/pi/aux-cli-bkp /home/pi/aux-cli
    sudo mv /bin/aux-cli-bkp /bin/aux-cli
    sudo mv /lib/aux-cli-bkp /lib/aux-cli
}

run_steps() {
    if [ -e /bin/aux-cli ]; then
        trap revert ERR
        echo "AUX-CLI is already installed."
        echo "Updating AUX-CLI..."
        update
    else
        echo "Installing AUX-CLI..."
        install
    fi
}

run_steps
