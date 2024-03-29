# auxcli
auxcli is a collection of tools to help expedite and control your environment on your RaspberryPi that's running casualOS. Some tools won't work at all unless you have casualOS installed.

## Required Hardware:
- 1 Raspberry Pi 4 Model B+  
- 1 5.1V 2.5A USB-C Power Supply (Search Raspberry PI 4 B+ power supply)  
- 1 8GB or larger MicroSD card 

## Hardware Prep:
1. Flash Raspberry Pi OS Lite  
   * Download the 32-bit Raspberry Pi OS Lite image from [ here. ](https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2022-09-26/2022-09-22-raspios-bullseye-armhf-lite.img.xz)  
   * Flash onto the MicroSD card using Balena Etcher.  
      * On macOS - You can install Etcher with Homebrew `brew cask install balenaetcher`
      * On Win10 - You can install Etcher with Chocolatey `choco install etcher -y`
2. Create Network Files
   * Unplug the MicroSD card and replug it into your computer. It should now appear as a volume called "boot"
   * Create an empty file named "ssh" and put it in the root of the MicroSD card
   * Create another file named "wpa_supplicant.conf" with your wifi information and put it in the root of the MicroSD card

            ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
            update_config=1
            country=US

            network={
                ssid="YOUR_WIFI_NAME"
                psk="YOUR_WIFI_PASSWORD"
                key_mgmt=WPA-PSK
            }

   * Modify the values of "ssid" and "psk" to a local network name and it's password. Make sure to save the file.
   * Create another file named "userconf" if you want the default user `pi` and default password `raspberry` and put it in the root of the MicroSD 
            pi:$6$ZqM3kgIcLwgAE9./$q4H1ifcn3V2wvzoRPBXxw7/ghLzFCkyWh7LTjuL0R8tJwAleBe6KSyf4mPn.hKdKBRkUWueaKMK/3rMILclDP0

3. Setup the Raspberry Pi  
   * Put the MicroSD card into the Raspberry Pi 
   * Plug the Power Supply into the outlet and then into the Raspberry Pi 

## Installing auxcli
Once your pi is setup and powered on, connect to it via ssh. 
1. Open up the command line tool on the computer you are working from.
    * On macOS - Terminal
    * On Win10 - Command Prompt (If you have issues, run as Administrator)
2. Make sure it's on the network by running `ping raspberrypi.local`
3. You can  stop the command with `ctrl+c` or `cmd+c`
4. Once you have verified it's on the network, run the command `ssh pi@YOUR_IP_ADDRESS_FROM_THE_PING_COMMAND`
    * Example: `ssh pi@192.168.0.1`
5. If you get a security popup, just reply `yes`
6. When it asks for a password, it should be `raspberry` by default
7. Once you're in, run this `curl` command to grab the install file and execute it. There are some optional flags you can run that are listed above the "vanilla" install command.

            casualOS+auxcli install:
            OPTIONS:
            -n    --hostname      Change the hostname during the setup.
            -f    --full          Do a full install instead of just the core requirements.
            -y    --yes           Auto skips 'Are you sure?'
            -h    --help          Displays this help information.
    
            curl https://raw.githubusercontent.com/casual-simulation/casualos/master/install.sh --output install.sh && sudo bash install.sh

            curl https://raw.githubusercontent.com/casual-simulation/casualos/master/install.sh --output install.sh && sudo bash install.sh --full --yes --hostname auxplayer



            auxcli-only install:
            curl https://raw.githubusercontent.com/casual-simulation/aux-cli/master/install.sh --output install-cli.sh && sudo bash install-cli.sh  

8. Once it completes, restart the pi.
9. You maybe have to wait 10-15 minutes for casualOS to finish pulling/installing in the background after the reboot.
10. OPTIONAL: If you opted for the full install, it will boot back in AP Mode, which means it won't be on your network anymore unless you are hard wired. This lets you connect directly to the pi if you don't want it on your network and would rather have it isolated. You should see the pi broadcasting a wifi signal with its hostname and last 4 digits of its MAC address. Example: auxplayer_A1B2
    * Connect to the pi wifi
    * Open a web browser with whatever device you connected with
    * Go to 10.0.0.1 or raspiwifisetup.com
    * Follow the prompts to connect the pi to your wifi and it will reboot back on the network

## Authors
Created & Maintained by [ Wesley Mayle ](mailto:wesley@yeticgi.com)
