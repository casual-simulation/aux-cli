import time
from time import sleep
import RPi.GPIO as GPIO
from ky040.KY040 import KY040
from rpi_ws281x import PixelStrip, Color
import argparse
import board
import neopixel

#ToF Sensor
import busio 
import adafruit_vl6180x
 
# Create I2C bus. #ToF Sensor
i2c = busio.I2C(board.SCL, board.SDA)
 
# Create sensor instance. #ToF Sensor
sensor = adafruit_vl6180x.VL6180X(i2c)

# LED strip configuration:
LED_COUNT = 300        # Number of LED pixels.
LED_PIN = 18          # GPIO pin connected to the pixels (18 uses PWM!).
# LED_PIN = 10        # GPIO pin connected to the pixels (10 uses SPI /dev/spid$
LED_FREQ_HZ = 800000  # LED signal frequency in hertz (usually 800khz)
LED_DMA = 10          # DMA channel to use for generating signal (try 10)
LED_BRIGHTNESS = 255  # Set to 0 for darkest and 255 for brightest
LED_INVERT = False    # True to invert the signal (when using NPN transistor le$
LED_CHANNEL = 0       # set to '1' for GPIOs 13, 19, 41, 45 or 53
ColorChangeVar = 255
IsOn = True
Speed = 0.5
ScaleNumRotary = 0;
ScaleNumToF = 0;
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

def colorWipe(strip, color, wait_ms=50):
    """Wipe color across display a pixel at a time."""
    for i in range(strip.numPixels()):
        strip.setPixelColor(i, color)
        strip.show()
        time.sleep(0.005)

def tofChange():
    global ScaleNumToF

    # Read the range in millimeters and print it.
    ScaleNumToF = sensor.range
    print('Range: {0}mm'.format(ScaleNumToF))

    # Read the light, note this requires specifying a gain
    # light_lux = sensor.read_lux(adafruit_vl6180x.ALS_GAIN_1)
    # print('Light (1x gain): {0}lux'.format(light_lux))
    

def ScaleRotary():
    for i in range(num_pixels):
        pixels[i] = (0, 0, 255)
        if(i > ScaleNumRotary):
            pixels[i] = (0, 0, 0)
    pixels.show()
    time.sleep(0.1)

def ScaleToF():
    for i in range(num_pixels):
        pixels[i] = (0, 0, 255)
        if(i > ScaleNumToF):
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
        # ScaleRotary()

        # Comment/Uncomment both lines to use the Time of Flight Sensor to control the lights
        tofChange()
        ScaleToF()
        
except KeyboardInterrupt:
    if args.clear:
        print('done')


