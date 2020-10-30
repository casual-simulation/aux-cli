#!/bin/bash

# Read the bt-serial.conf file 
. /etc/bt-serial.conf


# If there are no known brushes
if [ $brush01_mac == "" ]; then

    # Discover Brushes
    while [[ $(hcitool scan | grep RNBT) == "" ]]; do
        echo "No Brush Found!"
    done

    # Save brush info to config
    brush=$(hcitool scan | grep RNBT)
    brush_mac=$(echo $brush | awk '{print $1}')
    brush_name=$(echo $brush | awk '{print $2}')
    sudo sed -i "s/brush01_mac=\"\"/brush01_mac=\"$brush_mac\"/g" /etc/bt-serial.conf
    sudo sed -i "s/brush01_name=\"\"/brush01_name=\"$brush_name\"/g" /etc/bt-serial.conf

    echo "Brush Found: $brush"
fi

# Stop service once we have one?


# DEPRECATED
# If there are no brushes in rfcomm, add one
# if [ -n "$brush01_mac" ] && [ "$brush01_mac" != " " ] && ! sudo grep $brush01_mac /etc/bluetooth/rfcomm.conf; then
#     sudo tee -a /etc/bluetooth/rfcomm.conf > /dev/null <<EOF
# rfcomm0 {
#     # Automatically bind the device at startup
#     bind yes;

#    # Bluetooth address of the device
#     device $brush01_mac;

#     # RFCOMM channel for the connection
#     channel 1;

#     # Description of the connection
#     comment "Toothbrush";
# }
# EOF
# else
#     return
# fi



