#!/usr/bin/python

import os
import time
from pybtooth import BluetoothManager

devices = BluetoothManager().getConnectedDevices(no_name=True)

print "Found " + str(len(devices)) + " devices."

for device in devices:
    addr = device.get("Address")
    os.system("sudo sh check-and-connect-pt-pan.sh " + addr)
    time.sleep(3)
