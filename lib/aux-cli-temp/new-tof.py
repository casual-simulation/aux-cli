import time 
import board
import busio
import adafruit_vl6180x

# Create I2C bus.
i2c = busio.I2C(board.SCL, board.SDA)
# Create sensor instance.
sensor = adafruit_vl6180x.VL6180X(i2c)
 

# Main loop prints the range and lux every second:
while True:
    # Read the range in millimeters and print it.
    range_mm = sensor.range
    print('Range: {0}mm'.format(range_mm))

    # Read the light, note this requires specifying a gain value
    # light_lux = sensor.read_lux(adafruit_vl6180x.ALS_GAIN_1)
    # print('Light (1x gain): {0}lux'.format(light_lux))

    # Delay for a second.
    time.sleep(0.1)