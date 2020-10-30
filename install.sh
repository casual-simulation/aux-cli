#!/bin/bash
set -e

install_deps() {

    if git --version >/dev/null 2>&1; then
        echo "GIT is already installed."
    else
        sudo apt-get install -y git
    fi

    # TODO: Not sure where to throw this for now. 
    # Gives errors if we don't install with base install for some reason.
    sudo mkdir -p /data
    sudo mkdir -p /data/drives
}

clone_repo() {
    # git clone --single-branch --branch develop https://github.com/casual-simulation/aux-cli.git /home/pi/aux-cli
    git clone https://github.com/casual-simulation/aux-cli.git /home/pi/aux-cli
}

update_conf() {
    declare -A ary1
    declare -A ary2

    while IFS='=' read -r key value; do
        ary1[$key]=$value
    done <<<$(grep -v '^$\|^\s*\#' /etc/aux-cli.conf)

    while IFS='=' read -r key value; do
        ary2[$key]=$value
    done <<<$(grep -v '^$\|^\s*\#' /home/pi/aux-cli/etc/aux-cli.conf)

    for i in "${!ary2[@]}"; do
        if [[ ${ary1[$i]} ]]; then
            if [ "$i" == "version" ]; then
                sed -i "s/^version=\".*\"/version=${ary2[$i]}/g" /etc/aux-cli.conf
            fi
        fi

        if [[ ! ${ary1[$i]} ]]; then
            line_number=$(grep -n "$i" /home/pi/aux-cli/etc/aux-cli.conf | grep -Eo '^[^:]+')
            sed -i "${line_number}i ${i}=${ary2[$i]}" /etc/aux-cli.conf
        fi
    done
}

make_executable() {
    for filename in $(find /home/pi/aux-cli -type f ! -name "*.*"); do
        chmod +x "${filename}"
    done
}

deploy_files() {
    sudo cp -rf /home/pi/aux-cli/bin /
    sudo cp -rf /home/pi/aux-cli/data /
    if [ ! -e /etc/aux-cli.conf ]; then
        sudo cp -rf /home/pi/aux-cli/etc /
    fi
    sudo cp -rf /home/pi/aux-cli/lib /
    sudo cp -rf /home/pi/aux-cli/srv /
}

enable_gpio() {
    sudo sed -i "s/^#dtoverlay=gpio-no-irq/dtoverlay=gpio-no-irq/g" /boot/config.txt
    if ! sudo grep "dtoverlay=gpio-no-irq" "/boot/config.txt"; then
        echo "dtoverlay=gpio-no-irq" | sudo tee -a /boot/config.txt
    fi
    if ! sudo grep "SUBSYSTEM==\"bcm2835-gpiomem\", KERNEL==\"gpiomem\", GROUP=\"gpio\", MODE=\"0660\"" "/etc/udev/rules.d/20-gpiomem.rules"; then
        echo "SUBSYSTEM==\"bcm2835-gpiomem\", KERNEL==\"gpiomem\", GROUP=\"gpio\", MODE=\"0660\"" | sudo tee -a /etc/udev/rules.d/20-gpiomem.rules
    fi
}

enable_uart(){
    # If it finds UART, make sure it's on
    sudo sed -i "s/^#enable_uart=1/enable_uart=1/g" /boot/config.txt
    sudo sed -i "s/^#enable_uart=0/enable_uart=1/g" /boot/config.txt
    sudo sed -i "s/^enable_uart=0/enable_uart=1/g" /boot/config.txt

    if ! sudo grep "enable_uart=1" "/boot/config.txt"; then
        printf "\n# Enable UART\nenable_uart=1\n" | sudo tee -a /boot/config.txt
    fi

    # Disable Serial Console from tying up the process
    sudo sed -i "s/console=serial0,115200 //g" /boot/cmdline.txt
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
    make_executable
    deploy_files
    enable_gpio
    enable_uart
    cleanup
}

update() {
    install_deps
    backup
    clone_repo
    make_executable
    deploy_files
    enable_gpio
    enable_uart
    update_conf
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
