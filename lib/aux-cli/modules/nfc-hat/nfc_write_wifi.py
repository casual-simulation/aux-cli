"""
This example shows connecting to the PN532 and writing an NTAG215
type RFID tag with custom WiFi credentials
"""
import RPi.GPIO as GPIO
import pn532.pn532 as nfc
from pn532 import *
import sys
import getopt
from itertools import zip_longest


ssid = ''
password = ''

################################ PASS ARGUMENTS ################################

def main(argv):
    global ssid
    global password
    try:
        opts, args = getopt.getopt(argv, "hs:p:", ["ssid=", "password="])
    except getopt.GetoptError:
        print('example_rw_ntag2.py -s <ssid> -p <password>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print('example_rw_ntag2.py -s <ssid> -p <password>')
            sys.exit()
        elif opt in ("-s", "--ssid"):
            ssid = arg
        elif opt in ("-p", "--password"):
            password = arg


main(sys.argv[1:])

################################# NDEF BUILDER #################################

# Need to get info in reverse order, then build string in correct order
# Marks the end of configurable data.
end_marker = "fe"

# Payload in reverse order
mystery04 = "10200006ffffffffffff"
password = ''.join(hex(ord(c))[2:].zfill(2) for c in password)
password_length = hex(len(password)//2)[2:].zfill(2)
mystery03 = "100300020001100f00020001102700"
ssid = ''.join(hex(ord(c))[2:].zfill(2) for c in ssid)
ssid_length = hex(len(ssid)//2)[2:].zfill(2)
mystery02 = "1026000101104500"

payload_short = "{0}{1}{2}{3}{4}{5}{6}".format(
    mystery02, ssid_length, ssid, mystery03, password_length, password, mystery04)
payload_short_length = hex(len(payload_short)//2)[2:].zfill(2)
mystery01 = "100e00"

payload_long = "{0}{1}{2}".format(
    mystery01, payload_short_length, payload_short)

# Header in reverse order
payload_id = hex(ord("1"))[2:].zfill(2)
payload_type = ''.join(hex(ord(c))[2:].zfill(2)
                       for c in "application/vnd.wfa.wsc")
payload_id_length = hex(len(payload_id)//2)[2:].zfill(2)
payload_long_length = hex(len(payload_long)//2)[2:].zfill(2)
payload_type_length = hex(len(payload_type)//2)[2:].zfill(2)
tnf_flags = hex(int('11011010', 2))[2:].zfill(2)

ndef_msg_short = "{0}{1}{2}{3}{4}{5}{6}".format(
    tnf_flags, payload_type_length, payload_long_length, payload_id_length, payload_type, payload_id, payload_long)
ndef_msg_short_length = hex(len(ndef_msg_short)//2)[2:].zfill(2)
tag_type = hex(3)[2:].zfill(2)

ndef_msg_long = "{0}{1}{2}{3}".format(
    tag_type, ndef_msg_short_length, ndef_msg_short, end_marker)

# Break into a list of 8 character strings
pages = list(map(''.join, zip_longest(
    *[iter(ndef_msg_long)]*8, fillvalue='0')))

pages2 = []
for i in range(len(pages)):
    # Break each of those strings into a list of 2 character strings
    out = [(pages[i][j:j+2]) for j in range(0, len(pages[i]), 2)]

    # For each string in our new list, prefix it with '0x' and then convert it back to a hexadecimanl int
    for k in range(len(out)):
        out[k] = '0x' + out[k]
        out[k] = int(out[k], 16)
    # Then add those lists to a list
    pages2.append(out)

################################# PREP FOR NFC #################################

pn532 = PN532_SPI(debug=False, reset=20, cs=4)
#pn532 = PN532_I2C(debug=False, reset=20, req=16)
#pn532 = PN532_UART(debug=False, reset=20)

ic, ver, rev, support = pn532.get_firmware_version()
print('Found PN532 with firmware version: {0}.{1}'.format(ver, rev))

# Configure PN532 to communicate with NTAG215 cards
pn532.SAM_configuration()

print('Waiting for RFID/NFC card to write to!')
while True:
    # Check if a card is available to read
    uid = pn532.read_passive_target(timeout=0.5)
    print('.', end="")
    # Try again if no card is available.
    if uid is not None:
        break
print('Found card with UID:', [hex(i) for i in uid])


################################# WRITE TO NFC #################################
try:
    for i in range(len(pages2)):
        # Start writing data at page/block 4
        block_number = i + 4
        pn532.ntag2xx_write_block(block_number, bytes(pages2[i]))
        if pn532.ntag2xx_read_block(block_number) == bytes(pages2[i]):
            print('write block %d successfully' % block_number)
except nfc.PN532Error as e:
    print(e.errmsg)

# Zero out any blocks we didnt write data to
write_end = len(pages2) + 3

if b'\x12' in pn532.ntag2xx_read_block(3):
    data_end = 39
    print('This is an NTAG213 tag.')
elif b'\x3E' in pn532.ntag2xx_read_block(3):
    data_end = 129
    print('This is an NTAG215 tag.')
elif b'\x6D' in pn532.ntag2xx_read_block(3):
    data_end = 225
    print('This is an NTAG216 tag.')

while write_end < data_end:
    write_end += 1
    if pn532.ntag2xx_read_block(write_end) != bytes([0x00, 0x00, 0x00, 0x00]):
        pn532.ntag2xx_write_block(write_end, bytes([0x00, 0x00, 0x00, 0x00]))
        print('cleared block %d successfully' % write_end)
    else:
        print('block %d already cleared' % write_end)

GPIO.cleanup()