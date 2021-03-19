


device=$(hcitool scan | grep RNBT)
device_mac=$(echo $device | awk '{print $1}')
device_name=$(echo $device | awk '{print $2}')

# If it finds UART, make sure it's on
sudo sed -i "s/^#enable_uart=1/enable_uart=1/g" /boot/config.txt
sudo sed -i "s/^#enable_uart=0/enable_uart=1/g" /boot/config.txt
sudo sed -i "s/^enable_uart=0/enable_uart=1/g" /boot/config.txt

if ! sudo grep "enable_uart=1" "/boot/config.txt"; then
    printf "\n# Enable UART\nenable_uart=1\n" | sudo tee -a /boot/config.txt
fi

# Disable Serial Console from tying up the process
sudo sed -i "s/console=serial0,115200 //g" /boot/cmdline.txt


sudo hcitool cc 00:06:66:B9:08:36
sudo hcitool auth 00:06:66:B9:08:36


#######################################################

sudo apt-get update -y
sudo apt-get upgrade -y


device_mac=$(hcitool scan | grep RNBT | awk '{print $1}')

sudo tee -a /etc/bluetooth/rfcomm.conf > /dev/null <<EOF
rfcomm0 {
    # Automatically bind the device at startup
    bind yes;

   # Bluetooth address of the device
    device $device_mac;

    # RFCOMM channel for the connection
    channel 1;

    # Description of the connection
    comment "Toothbrush";
}
EOF

sudo rfcomm connect /dev/rfcomm0 00:06:66:B9:08:36 1 &

sudo cat -ns /dev/rfcomm0 > brush.log





#######################################################


sudo apt-get update -y
sudo apt-get upgrade -y
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs

mkdir serialtests
cd serialtests

npm install serialport
  or
npm install johnny-five raspi-io



#######################################################

hcitool scan | grep RNBT | awk '{print $1}' | sudo rfcomm connect hci0 1 


# PIPELINE TESTING STUFF
#######################################################

# test.js
# const execSync = require('child_process').execSync;
# let device = "/dev/rfcomm0";
# let mac = "00:06:66:B9:08:47";
# let channel = 1;

# console.log(device);
# console.log(mac);
# console.log(channel);

# let jsond = '{"command":"connect","device":"' + device + '", "mac":"' + mac + '", "channel":"' + channel + '"}';
# console.log(jsond);
# let curl_command = 'curl -H "Content-Type: application/json" -X POST -d \'' + jsond + '\' http://192.168.1.18:8090/post';
# console.log(curl_command);

# execSync(curl_command);

# console.log("done");



# test.py
# import subprocess
# import json


# mdata = '{"command":"connect","device":"/dev/rfcomm0","mac":"00:06:66:B9:08:47","channel":"1"}'
# data = json.loads(mdata)

# command = (data['command'])
# # command = "connect"
# device = (data['device'])
# # device = "/dev/rfcomm0"
# mac = (data['mac'])
# # mac = "00:06:66:B9:08:20"
# channel = (data['channel'])
# # channel = "1"

# if command == "connect":
#     # device_c = (data['device'])
#     # mac = (data['mac'])
#     # channel = (data['channel'])
#     subprocess.call(['/usr/bin/timeout', '60s', '/lib/auxcli/commands/helper/bt-serial-connect', device, mac, channel])



#btscan.sh

#!/bin/bash

# readarray -t current_devices < <(jq -r '.[].mac' /home/pi/test.json)
# # echo ${current_devices[@]}

# scan_devices(){
#     readarray -t discovered_devices < <(hcitool scan)
#     echo ${discovered_devices[@]}
#     for ((i = 1; i < ${#discovered_devices[@]}; i++)); do
#             device_mac=$(echo ${discovered_devices[i]} | awk '{print $1}')
#             device_name=$(echo ${discovered_devices[i]} | awk '{print $2}')
#             if [[ ! ${current_devices[*]} =~ $device_mac ]]; then
#                 # Add a new device
#                 jq --arg mac "$device_mac" --arg name "$device_name" --arg desc "$device_desc" '. += [{"mac": $mac, "name": $name, "desc": $desc}]' /home/pi/test.json | sudo tee /home/pi/test.$
#                 sudo mv -f /home/pi/test.json.tmp /home/pi/test.json
#             fi
#             readarray -t current_devices < <(jq -r '.[].mac' /home/pi/test.json)
#             if [ ! $device_name == n/a ]; then
#                 if [[ ! ${current_devices[*]} =~ $device_name ]]; then
#                     jq --arg mac "$device_mac" --arg name "$device_name" '(.[] | select (.mac == $mac) | .name) = $name' /home/pi/test.json | sudo tee /home/pi/test.json.tmp 1> /dev/null
#                     sudo mv -f /home/pi/test.json.tmp /home/pi/test.json
#                 fi
#             fi
#     done
# }

# first_scan(){
#     while [ ${#current_devices[@]} -eq 0 ]; do
#         echo "Empty!"
#         scan_devices
#         readarray -t current_devices < <(jq -r '.[].mac' /home/pi/test.json)
#     done
# }

# first_scan
# scan_devices


