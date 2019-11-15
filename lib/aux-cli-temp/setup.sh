#!/usr/bin/bash
set -e

#######################################################
##### Global
#######################################################
sudo apt-get install -y python3-pip python3-dev

#######################################################
##### Rotary Encoder - KY040
#######################################################
sudo apt-get install -y pigpio python-pigpio python3-pigpio
sudo pip install pigpio_encoder
sudo systemctl enable pigpiod
sudo systemctl start pigpiod

#######################################################
##### Time of Flight Sensor - VL6180X
#######################################################
sudo pip3 install adafruit-circuitpython-vl6180x
sudo sed -i "s/#dtparam=i2c_arm=on/dtparam=i2c_arm=on/g" /boot/config.txt

if ! sudo grep "i2c-dev" "/etc/modules"; then
    echo "i2c-dev" | sudo tee -a /etc/modules
fi

#######################################################
##### NeoPixel - WS281X LEDS
##### 74AHCT125 - Quad Level Shifter
#######################################################
sudo pip3 install rpi_ws281x adafruit-circuitpython-neopixel




