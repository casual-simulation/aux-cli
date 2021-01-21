


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
