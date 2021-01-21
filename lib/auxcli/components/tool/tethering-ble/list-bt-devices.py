#!/usr/bin/python

import os
import time
from pybtooth import BluetoothManager

SCRIPT = os.path.abspath(__file__)
SCRIPTPATH = os.path.dirname(SCRIPT)
devices = BluetoothManager().getConnectedDevices(no_name=True)

print "Found " + str(len(devices)) + " devices."

for device in devices:
    addr = device.get("Address")
    os.system("sudo sh " + SCRIPTPATH + "/check-and-connect-pt-pan.sh " + addr)
    time.sleep(3)
