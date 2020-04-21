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


url = ''

# Pass in Argument for URL
def main(argv):
    global url
    try:
        opts, args = getopt.getopt(argv, "hu:", ["url="])
    except getopt.GetoptError:
        print('nfc_write_url.py -u <url>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print('nfc_write_url.py -u <url>')
            sys.exit()
        elif opt in ("-u", "--url"):
            url = arg


main(sys.argv[1:])

# Need to get info in reverse order, then build string in correct order
# Marks the end of configurable data.
end_marker = "fe"

# Payload in reverse order
url_prefix = ""
url_prefixs = [
    ["http://www.", "01"],
    ["https://www.", "02"],
    ["http://", "03"],
    ["https://", "04"],
    ["tel:", "05"],
    ["mailto:", "06"],
    ["ftp://anonymous:anonymous@", "07"],
    ["ftp://ftp.", "08"],
    ["ftps://", "09"],
    ["sftp://", "0A"],
    ["smb://", "0B"],
    ["nfs://", "0C"],
    ["ftp://", "0D"],
    ["dav://", "0E"],
    ["news:", "0F"],
    ["telnet://", "10"],
    ["imap:", "11"],
    ["rtsp://", "12"],
    ["urn:", "13"],
    ["pop:", "14"],
    ["sip:", "15"],
    ["sips:", "16"],
    ["tftp:", "17"],
    ["btspp://", "18"],
    ["btl2cap://", "19"],
    ["btgoep://", "1A"],
    ["tcpobex://", "1B"],
    ["irdaobex://", "1C"],
    ["file://", "1D"],
    ["urn:epc:id:", "1E"],
    ["urn:epc:tag:", "1F"],
    ["urn:epc:pat:", "20"],
    ["urn:epc:raw:", "21"],
    ["urn:epc:", "22"],
    ["urn:nfc", "23"],
    ["", "00"]
]

for i in range(len(url_prefixs)):
    if url.startswith(url_prefixs[i][0]):
        url = url.replace(url_prefixs[i][0],"",1)
        url_prefix = url_prefixs[i][1]
        break

url = ''.join(hex(ord(c))[2:].zfill(2) for c in url)
payload_type = hex(ord("U"))[2:].zfill(2) # U for URL
payload_length = hex(len(url)//2+1)[2:].zfill(2) # Length of URL plus 1
payload_type_length = hex(1)[2:].zfill(2) # Length of type "U" which is just 1
tnf_flags = hex(int('11010001', 2))[2:].zfill(2)
ndef_msg_short = "{0}{1}{2}{3}{4}{5}".format(
    tnf_flags, payload_type_length, payload_length, payload_type, url_prefix, url)
ndef_msg_short_length = hex(len(ndef_msg_short)//2)[2:].zfill(2)
tag_type = hex(3)[2:].zfill(2)
ndef_msg_long = "{0}{1}{2}{3}".format(
    tag_type, ndef_msg_short_length, ndef_msg_short, end_marker)


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

# data_end = 39   # NTAG213
data_end = 129  # NTAG215
# data_end = 225  # NTAG216

while write_end < data_end:
    write_end += 1
    if pn532.ntag2xx_read_block(write_end) != bytes([0x00, 0x00, 0x00, 0x00]):
        pn532.ntag2xx_write_block(write_end, bytes([0x00, 0x00, 0x00, 0x00]))
        print('cleared block %d successfully' % write_end)
    else:
        print('block %d already cleared' % write_end)

GPIO.cleanup()