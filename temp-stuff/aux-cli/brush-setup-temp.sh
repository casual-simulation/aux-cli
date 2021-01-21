#!/bin/bash
set -e

# Update, then install NodeJS
sudo apt-get update -y
sudo apt-get upgrade -y
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs


# If it finds UART, make sure it's on
sudo sed -i "s/^#enable_uart=1/enable_uart=1/g" /boot/config.txt
sudo sed -i "s/^#enable_uart=0/enable_uart=1/g" /boot/config.txt
sudo sed -i "s/^enable_uart=0/enable_uart=1/g" /boot/config.txt

if ! sudo grep "enable_uart=1" "/boot/config.txt"; then
    printf "\n# Enable UART\nenable_uart=1\n" | sudo tee -a /boot/config.txt
fi

# Disable Serial Console from tying up the process
sudo sed -i "s/console=serial0,115200 //g" /boot/cmdline.txt

# Needs reboot for changes to take effect
sudo reboot now

# Make a folder and install serialport in it
mkdir test
cd test
npm install serialport

#  or
# npm install johnny-five raspi-io


# Make a config file with your toothbrush MAC
sudo tee -a /etc/bt-serial.conf > /dev/null <<EOF
#!/bin/bash

device01_mac="00:06:66:B9:08:36"
device01_name=""
EOF


# Make sure you are in the directory you installed serialport

# This didnt work as-is, so I had to `sudo nano` create this script 
# with the contents between the EOF

sudo tee -a test.js > /dev/null <<EOF

const execSync = require('child_process').execSync;
const SerialPort = require('serialport')
const parsers = SerialPort.parsers

var macAddress = execSync(
    '. /etc/bt-serial.conf; echo $device01_mac',
    {shell: '/bin/bash'}
).toString('utf8').replace(/(\r\n|\n|\r)/gm,"");

execSync(
    'sudo rfcomm connect /dev/rfcomm0 ' + macAddress + ' 1 &',
    {shell: '/bin/bash', stdio: 'inherit'}
);

execSync(
    'while !(sudo rfcomm -a | grep "' + macAddress + '"); do sleep 1; echo "Not Connected Yet."; done',
    {shell: '/bin/bash', stdio: 'inherit'}
);

// Use a `\r\n` as a line terminator
const parser = new parsers.Readline({
  delimiter: '\r\n',
})

const port = new SerialPort('/dev/rfcomm0', {
  baudRate: 9600,
})

port.pipe(parser)
port.on('open', () => console.log('Port open'))
parser.on('data', console.log)

EOF



