import time
from time import sleep
import RPi.GPIO as GPIO
from ky040.KY040 import KY040
from rpi_ws281x import PixelStrip, Color
import argparse
import board
import neopixel

# LED strip configuration:
LED_COUNT = 300        # Number of LED pixels.
LED_PIN = 18          # GPIO pin connected to the pixels (18 uses PWM!).
# LED_PIN = 10        # GPIO pin connected to the pixels (10 uses SPI /dev/spid$
LED_FREQ_HZ = 800000  # LED signal frequency in hertz (usually 800khz)
LED_DMA = 10          # DMA channel to use for generating signal (try 10)
LED_BRIGHTNESS = 255  # Set to 0 for darkest and 255 for brightest
LED_INVERT = False    # True to invert the signal (when using NPN transistor le$
LED_CHANNEL = 0       # set to '1' for GPIOs 13, 19, 41, 45 or 53

IsOn = True
ScaleNumRotary = 0;

# Define your pins
CLOCKPIN = 5
DATAPIN = 6
SWITCHPIN = 13


pixel_pin = board.D18
num_pixels = 300
ORDER = neopixel.RGB
pixels = neopixel.NeoPixel(pixel_pin, num_pixels, brightness=0.2, auto_write=False, pixel_order=ORDER)

def rotaryChange(direction):
    global ScaleNumRotary
    if ( direction == 0 ):
        direction = direction + -1
    mod = ScaleNumRotary + (direction)
    if ( mod > num_pixels):
        mod = num_pixels
    if ( mod < 0):
        mod = 0
    ScaleNumRotary = mod
    print (ScaleNumRotary)

def switchPressed():
    global IsOn
    IsOn = not IsOn
    print ("button pressed")

def ScaleRotary():
    for i in range(num_pixels):
        pixels[i] = (0, 0, 255)
        if(i > ScaleNumRotary):
            pixels[i] = (0, 0, 0)
    pixels.show()
    time.sleep(0.1)

# Process arguments for the LEDs
parser = argparse.ArgumentParser()
parser.add_argument('-c', '--clear', action='store_true', help='clear the display on exit')
args = parser.parse_args()

# Rotary Encoder stuff
GPIO.setmode(GPIO.BCM)
ky040 = KY040(CLOCKPIN, DATAPIN, SWITCHPIN, rotaryChange, switchPressed)
ky040.start()


# Main Loop that does stuff
print('Press Ctrl-C to quit.')
try:
    while True:
        # Comment/Uncomment to use the Rotary Encoder to control the lights
        ScaleRotary()
        
except KeyboardInterrupt:
    if args.clear:
        print('done')


