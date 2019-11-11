#!/usr/bin/bash
set -e

#Everything
sudo apt-get install -y python3-pip python3-dev

#ToF Sensor
sudo pip3 install adafruit-circuitpython-vl6180x

#NeoPixel
sudo pip3 install rpi_ws281x adafruit-blinka adafruit-circuitpython-lis3dh adafruit-circuitpython-neopixel



##NOTES FOR SAMPLES WE USED
#Rotary Encoder
git clone https://github.com/martinohanlon/KY040

#LED
git clone https://github.com/jgarff/rpi_ws281x

#Run the led tests
sudo python rpi_ws281x-master/strandtest.py -c


##HAVEN'T TESTED YET
#Rotary Encoder
https://pypi.org/project/pigpio-encoder/
sudo apt-get install pigpio python-pigpio python3-pigpio
sudo pip3 install pigpio_encoder
sudo pigpiod
