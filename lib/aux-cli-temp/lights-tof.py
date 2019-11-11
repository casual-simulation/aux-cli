import time
from time import sleep
import RPi.GPIO as GPIO
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

IsOn = True
ScaleNumToF = 0;

pixel_pin = board.D18
num_pixels = 300
ORDER = neopixel.RGB
pixels = neopixel.NeoPixel(pixel_pin, num_pixels, brightness=0.2, auto_write=False, pixel_order=ORDER)


def tofChange():
    global ScaleNumToF

    # Read the range in millimeters and print it.
    ScaleNumToF = sensor.range
    print('Range: {0}mm'.format(ScaleNumToF))

    # Read the light, note this requires specifying a gain
    # light_lux = sensor.read_lux(adafruit_vl6180x.ALS_GAIN_1)
    # print('Light (1x gain): {0}lux'.format(light_lux))
    
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

# Main Loop that does stuff
print('Press Ctrl-C to quit.')
try:
    while True:
        # Comment/Uncomment both lines to use the Time of Flight Sensor to control the lights
        tofChange()
        ScaleToF()
        
except KeyboardInterrupt:
    if args.clear:
        print('done')


