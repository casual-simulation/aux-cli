import RPi.GPIO as GPIO
import pn532.pn532 as nfc
from pn532 import *

pn532 = PN532_SPI(debug=False, reset=20, cs=4)
#pn532 = PN532_I2C(debug=False, reset=20, req=16)
#pn532 = PN532_UART(debug=False, reset=20)

ic, ver, rev, support = pn532.get_firmware_version()
print('Found PN532 with firmware version: {0}.{1}'.format(ver, rev))
print("ic: " + ic)
print("ver: " + ver)
print("rev: " + rev)
print("support: " + support)
# Configure PN532 to communicate with NTAG215 cards
pn532.SAM_configuration()

# Cleans up hex numbers to look pretty
def clean_hex(hex_byte):
    return hex(hex_byte)[2:].zfill(2).strip()

# Start trying to read NFC/Get Serial Number
print('Waiting for RFID/NFC card to read!')
while True:
    # Check if a card is available to read
    uid = pn532.read_passive_target(timeout=0.5)
    print('.', end="")
    # Try again if no card is available.
    if uid is not None:
        break
print()

SERIAL = "UNKNOWN"             # The first 9 bytes minus the 2 check bytes (Page 00, Byte 03 and Page 02, Byte 00)

# IC INFO
IC_MAN = "UNKNOWN"                     # Based on the first byte of the serial number
IC_TYPE = "UNKNOWN"                    # Based on Byte 6 from the GET_VERSION command
NFC_FORUM_NDEF_COMPLIANT = "UNKNOWN"   # Always "Type 2 Tag" until I port this to different hardware, or get new tags of some kind. This thing can only read Type 2 afaik

# NDEF
MSG_RECORD_COUNT = "UNKNOWN"   # 
MSG_LEN_CUR = "UNKNOWN"        # Based on Page 04, Byte 01. Example: 58 hex is 88 dec. Total length of all headers/payloads in the message.
MSG_LEN_MAX = "UNKNOWN"        # Based on Page 03, Byte 02. Example: 3E hex is 62 dec. 62*8=496
DATA_LOCK = "UNKNOWN"          # Based on Page 02, Bytes 02/03. Both Bytes need to be set to: 00h is False (Read/Write), FFh is True (Read Only)
DATA_LOCKABLE = "UNKNOWN"      # 

# RECORDS
RECORD_HEADING = []
RECORD_TNF = []
RECORD_ID = []
RECORD_TYPE = []
PAYLOAD_INFO = []
PAYLOAD_LEN = []
# Record #1: WiFi Simple Configuration Record
# Type Name Format: MIME Type (RFC 2046)
# ID: 1
# Type: application/vnd.wfa.wsc
# Credential
    # network index: 1
    # SSID: The Mayles 5G
    # Authentication Type: Open
    # Encryption: None
    # Network Key: Cari2008
    # MAC Address: FF:FF:FF:FF:FF:FF
    # non-specific MAC Address
# Payload Length: 60 Bytes

# NDEF CC
CC_VER = "UNKNOWN"              # Based on Page 03, Byte 01.
CC_LOCK = "UNKNOWN"             # Based on Page 03, Byte 03. 00h is False (Read/Write), FFh is True (Read Only)

# EXTRA
MEM_BYTES = "UNKNOWN"           # Based on Byte 6 from the GET_VERSION command
MEM_PAGES = "UNKNOWN"           # MEM_BYTES divided by 4

# IC Detailed Information
FULL_NAME = "UNKNOWN"           # Based on 
CAPACITANCE = "UNKNOWN"         # Based on Byte 3 from the GET_VERSION command
           
# Version Information
VENDOR_ID = "UNKNOWN"           # Based on Byte 1 from the GET_VERSION command
PRODUCT_TYPE = "UNKNOWN"        # Based on Byte 2 from the GET_VERSION command
PRODUCT_SUBTYPE = "UNKNOWN"     # Based on Byte 3 from the GET_VERSION command
MAJOR_PRODUCT_VER = "UNKNOWN"   # Based on Byte 4 from the GET_VERSION command
MINOR_PRODUCT_VER = "UNKNOWN"   # Based on Byte 5 from the GET_VERSION command
STORAGE_SIZE = "UNKNOWN"        # Based on Byte 6 from the GET_VERSION command
PROTOCOL_TYPE = "UNKNOWN"       # Based on Byte 7 from the GET_VERSION command

# Configuration Information
# ASCII Mirror: disabled
# NFC Counter: disabled
# Wrong Attempt Limit: no limit on wrong password attempts
# Strong Load Modulation: enabled


### GET ALL THE INFO
getinfo = pn532.get_ntag_version()
VENDOR_IDS = [
    ["0x04", "NXP Semiconductors"]
]
PRODUCT_TYPES = [
    ["0x04", "NTAG"]
]
PRODUCT_SUBTYPES = [
    ["0x01", "17 pF"],
    ["0x02", "50 pF"]
]
MAJOR_PRODUCT_VERS = [
    ["0x01", "1"]
]
MINOR_PRODUCT_VERS = [
    ["0x00", "V0"]
]
STORAGE_SIZES = [
    ["NTAG210", "0x0B", "48"],
    ["NTAG212", "0x0E", "128"],
    ["NTAG213", "0x0F", "144"],
    ["NTAG215", "0x11", "504"],
    ["NTAG216", "0x13", "888"]
]
PROTOCOL_TYPES = [
    ["0x03", " ISO/IEC 14443-3 Compliant"]
]

# SERIAL NUMBER
SERIAL = ":".join(clean_hex(i) for i in uid)

# Integrated Circuit (IC) MANUFACTURER
ICM = [
    ["0x01", "Motorola (UK)"],
    ["0x02", "STMicroelectronics SA (FR)"],
    ["0x03", "Hitachi Ltd (JP)"],
    ["0x04", "NXP Semiconductors (DE)"],
    ["0x05", "Infineon Technologies AG (DE)"],
    ["0x06", "Cylink (US)"],
    ["0x07", "Texas Instruments (FR)"],
    ["0x08", "Fujitsu Limited (JP)"],
    ["0x09", "Matsushita Electronics Corporation, Semiconductor Company (JP)"],
    ["0x0A", "NEC (JP)"],
    ["0x0B", "Oki Electric Industry Co Ltd (JP)"],
    ["0x0C", "Toshiba Corp (JP)"],
    ["0x0D", "Mitsubishi Electric Corp (JP)"],
    ["0x0E", "Samsung Electronics Co Ltd (KR)"],
    ["0x0F", "Hynix (KR)"],
    ["0x10", "LG Semiconductors Co Ltd (KR)"],
    ["0x11", "Emosyn-EM Microelectronics (US)"],
    ["0x12", "INSIDE Technology (FR)"],
    ["0x13", "ORGA Kartensysteme GmbH (DE)"],
    ["0x14", "Sharp Corporation (JP)"],
    ["0x15", "ATMEL (FR)"],
    ["0x16", "EM Microelectronic-Marin (CH)"],
    ["0x17", "SMARTRAC TECHNOLOGY GmbH (DE)"],
    ["0x18", "ZMD AG (DE)"],
    ["0x19", "XICOR Inc (US)"],
    ["0x1A", "Sony Corporation (JP)"],
    ["0x1B", "Malaysia Microelectronic Solutions Sdn Bhd (MY)"],
    ["0x1C", "Emosyn (US)"],
    ["0x1D", "Shanghai Fudan Microelectronics Co Ltd (CN)"],
    ["0x1E", "Magellan Technology Pty Limited (AU)"],
    ["0x1F", "Melexis NV BO (CH)"],
    ["0x20", "Renesas Technology Corp (JP)"],
    ["0x21", "TAGSYS (FR)"],
    ["0x22", "Transcore (US)"],
    ["0x23", "Shanghai Belling Corp Ltd (CN)"],
    ["0x24", "Masktech Germany GmbH (DE)"],
    ["0x25", "Innovision Research and Technology Plc (UK)"],
    ["0x26", "Hitachi ULSI Systems Co Ltd (JP)"],
    ["0x27", "Yubico AB (SE)"],
    ["0x28", "Ricoh (JP)"],
    ["0x29", "ASK (FR)"],
    ["0x2A", "Unicore Microsystems LLC (RU)"],
    ["0x2B", "Dallas semiconductor / Maxim (US)"],
    ["0x2C", "Impinj Inc (US)"],
    ["0x2D", "RightPlug Alliance (US)"],
    ["0x2E", "Broadcom Corporation (US)"],
    ["0x2F", "MStar Semiconductor Inc (TW)"],
    ["0x30", "BeeDar Technology Inc (US)"],
    ["0x31", "RFIDsec (DK)"],
    ["0x32", "Schweizer Electronic AG (DE)"],
    ["0x33", "AMIC Technology Corp (TW)"],
    ["0x34", "Mikron JSC (RU)"],
    ["0x35", "Fraunhofer Institute for Photonic Microsystems (DE)"],
    ["0x36", "IDS Microship AG (CH)"],
    ["0x37", "Kovio (US)"],
    ["0x38", "HMT Microelectronic Ltd (CH)"],
    ["0x39", "Silicon Craft Technology (TH)"],
    ["0x3A", "Advanced Film Device Inc. (JP)"],
    ["0x3B", "Nitecrest Ltd (UK)"],
    ["0x3C", "Verayo Inc. (US)"],
    ["0x3D", "HID Global (US)"],
    ["0x3E", "Productivity Engineering Gmbh (DE)"],
    ["0x3F", "Austriamicrosystems AG (reserved) (AT)"],
    ["0x40", "Gemalto SA (FR)"],
    ["0x41", "Renesas Electronics Corporation (JP)"],
    ["0x42", "3Alogics Inc (KR)"],
    ["0x43", "Top TroniQ Asia Limited (Hong Kong)"],
    ["0x44", "Gentag Inc (USA)"],
    ["0x45", "Invengo Information Technology Co.Ltd (CN)"],
    ["0x46", "Guangzhou Sysur Microelectronics, Inc (CN)"],
    ["0x47", "CEITEC SA (BR)"],
    ["0x48", "Shanghai Quanray Electronics Co. Ltd. (CN)"],
    ["0x49", "MediaTek Inc (TW)"],
    ["0x4A", "Angstrem PJSC (RU)"],
    ["0x4B", "Celisic Semiconductor (Hong Kong) Limited (CN)"],
    ["0x4C", "LEGIC Identsystems AG (CH)"],
    ["0x4D", "Balluff GmbH (DE)"],
    ["0x4E", "Oberthur Technologies (FR)"],
    ["0x4F", "Silterra Malaysia Sdn. Bhd. (MY)"],
    ["0x50", "DELTA Danish Electronics, Light & Acoustics (DK)"],
    ["0x51", "Giesecke & Devrient GmbH (DE)"],
    ["0x52", "Shenzhen China Vision Microelectronics Co., Ltd. (CN)"],
    ["0x53", "Shanghai Feiju Microelectronics Co. Ltd. (CN)"],
    ["0x54", "Intel Corporation (US)"],
    ["0x55", "Microsensys GmbH (DE)"],
    ["0x56", "Sonix Technology Co., Ltd. (TW)"],
    ["0x57", "Qualcomm Technologies Inc (US)"],
    ["0x58", "Realtek Semiconductor Corp (TW)"],
    ["0x59", "Freevision Technologies Co. Ltd (CN)"],
    ["0x5A", "Giantec Semiconductor Inc. (CN)"],
    ["0x5B", "JSC Angstrem-T (RU)"],
    ["0x5C", "STARCHIP France"],
    ["0x5D", "SPIRTECH (FR)"],
    ["0x5E", "GANTNER Electronic GmbH (AT)"],
    ["0x5F", "Nordic Semiconductor (NO)"],
    ["0x60", "Verisiti Inc (US)"],
    ["0x61", "Wearlinks Technology Inc. (CN)"],
    ["0x62", "Userstar Information Systems Co., Ltd (TW)"],
    ["0x63", "Pragmatic Printing Ltd. (UK)"],
    ["0x64", "Associação do Laboratório de Sistemas Integráveis ​​Tecnológico - LSI-TEC (BR)"],
    ["0x65", "Tendyron Corporation (CN)"],
    ["0x66", "MUTO Smart Co., Ltd. (KR)"],
    ["0x67", "ON Semiconductor (US)"],
    ["0x68", "TÜBİTAK BİLGEM (TR)"],
    ["0x69", "Huada Semiconductor Co., Ltd (CN)"],
    ["0x6A", "SEVENEY (FR)"],
    ["0x6B", "ISSM (FR)"],
    ["0x6C", "Wisesec Ltd (IL)"],
    ["0x7E", "Holtek (TW)"]
]
for i in range(len(ICM)):
    if ICM[i][0].lower() == hex(pn532.ntag2xx_read_block(0)[0]):
        IC_MAN = ICM[i][1]

# Integrated Circuit (IC) TYPE
if getinfo is not None:
    for i in range(len(STORAGE_SIZES)):
        if STORAGE_SIZES[i][1].lower() == hex(getinfo[6]):
            IC_TYPE = STORAGE_SIZES[i][0]


# NFC Forum NDEF-Compliant Tag
NFC_FORUM_NDEF_COMPLIANT = "Type 2 Tag" # Staying hardcoded until there's a reason not to

# MSG_RECORD_COUNT
bits = bin(pn532.ntag2xx_read_block(4)[2])[2:].zfill(8) # TNF byte to bits
if bits[0] == "1" and bits[1] == "1": # if MB and ME are both set, there's only 1 record
    MSG_RECORD_COUNT == "1" # not sure how to check for more than 1 record

# Message Length
MSG_LEN_CUR = str(pn532.ntag2xx_read_block(4)[1])
MSG_LEN_MAX = str(pn532.ntag2xx_read_block(4)[1])

# Data Read/Write
if hex(pn532.ntag2xx_read_block(2)[3]) == "0x0":
    DATA_LOCK = "Read and Write"
    DATA_LOCKABLE = "True"
elif hex(pn532.ntag2xx_read_block(2)[3]) == "0x0F":
    DATA_LOCK = "Read Only"
    DATA_LOCKABLE = "False"


# Records


# Capability Container - Version
if hex(pn532.ntag2xx_read_block(3)[1]) == "0x10":
    CC_VER = "1.0V"

# Capability Container - Lock
if hex(pn532.ntag2xx_read_block(3)[3]) == "0x0":
    CC_LOCK = "Read and Write"
elif hex(pn532.ntag2xx_read_block(3)[3]) == "0x0F":
    CC_LOCK = "Read Only"

# MEM_BYTES
if getinfo is not None:
    for i in range(len(STORAGE_SIZES)):
        if STORAGE_SIZES[i][1].lower() == hex(getinfo[6]):
            MEM_BYTES = STORAGE_SIZES[i][2]

# MEM_PAGES
MEM_PAGES = int(MEM_BYTES) / 4

# FULL_NAME - # NT2H1511G0DUx
# FULL_NAME = ""

# CAPACITANCE
if getinfo is not None:
    for i in range(len(PRODUCT_SUBTYPES)):
        if PRODUCT_SUBTYPES[i][0].lower() == hex(getinfo[3]):
            CAPACITANCE = PRODUCT_SUBTYPES[i][1]

# VENDOR_ID
if getinfo is not None:
    for i in range(len(VENDOR_IDS)):
        if VENDOR_IDS[i][0].lower() == hex(getinfo[1]):
            VENDOR_ID = VENDOR_IDS[i][1]

# PRODUCT_TYPE
if getinfo is not None:
    for i in range(len(PRODUCT_TYPES)):
        if PRODUCT_TYPES[i][0].lower() == hex(getinfo[1]):
            PRODUCT_TYPE = PRODUCT_TYPES[i][1]

# PRODUCT_SUBTYPE
if getinfo is not None:
    for i in range(len(PRODUCT_SUBTYPES)):
        if PRODUCT_SUBTYPES[i][0].lower() == hex(getinfo[1]):
            PRODUCT_SUBTYPE = PRODUCT_SUBTYPES[i][1]

# MAJOR_PRODUCT_VER
if getinfo is not None:
    for i in range(len(MAJOR_PRODUCT_VERS)):
        if MAJOR_PRODUCT_VERS[i][0].lower() == hex(getinfo[1]):
            MAJOR_PRODUCT_VER = MAJOR_PRODUCT_VERS[i][1]

# MINOR_PRODUCT_VER
if getinfo is not None:
    for i in range(len(MINOR_PRODUCT_VERS)):
        if MINOR_PRODUCT_VERS[i][0].lower() == hex(getinfo[1]):
            MINOR_PRODUCT_VER = MINOR_PRODUCT_VERS[i][1]

# STORAGE_SIZE
if getinfo is not None:
    for i in range(len(STORAGE_SIZES)):
        if STORAGE_SIZES[i][0].lower() == hex(getinfo[1]):
            STORAGE_SIZE = STORAGE_SIZES[i][1]

# PROTOCOL_TYPE
if getinfo is not None:
    for i in range(len(PROTOCOL_TYPES)):
        if PROTOCOL_TYPES[i][0].lower() == hex(getinfo[1]):
            PROTOCOL_TYPE = PROTOCOL_TYPES[i][1]


# ASCII_MIRROR dis

# NFC_COUNTER dis

# WRONG_ATTEMPT_LIMIT # no limit on wrong password attempts

# STRONG_LOAD_MODULATION en


### PRINT ALL THE INFO
print()
print("Serial: " + SERIAL)
print()
print("IC INFO")
print("IC Manufacturer: " + IC_MAN)
print("IC Type: " + IC_TYPE)
print("NFC Forum NDEF-Compliant Tag: " + NFC_FORUM_NDEF_COMPLIANT)
print()
print("NDEF")
print("NDEF Message Containing " + MSG_RECORD_COUNT + " record(s)")
print("Current Message Size: " + MSG_LEN_CUR + " bytes")
print("Max Message Size: " + MSG_LEN_MAX + " bytes")
print("NFC Data Access Set: " + DATA_LOCK)
print("Can Be Made Read-Only: " + DATA_LOCKABLE)
for i in range(len(RECORD_HEADING)):
    print()
    print("Record #" + str(i) + ": " + RECORD_HEADING[i])
    print("Type Name Format: " + RECORD_TNF[i])
    print("ID: " + RECORD_ID[i])
    print("Type: " + RECORD_TYPE[i])
    print(PAYLOAD_INFO[i])
    print("Payload Length" + PAYLOAD_LEN[i] + " bytes")
    # Option to add actual Hex?
# Option for entire NDEF Message Hex?
print()
print("NDEF Capability Container (CC)")
print("Mapping Version: " + CC_VER)
print("NDEF Maximum Data Size: " + MSG_LEN_MAX + " bytes")
print("NDEF CC Access: " + CC_LOCK)
print("NDEF Access: " + DATA_LOCK)
print()
print("EXTRA") 
print("Memory Size: " + MEM_BYTES + " bytes")
print(MEM_PAGES + " pages, with 4 bytes per page")
print()
print("IC Detailed Information")
print("Full Product Name: " + FULL_NAME) 
print("Capacitance: " + CAPACITANCE)
print()
print("Version Information")
print("Vendor ID: " + VENDOR_ID)
print("Type: " + PRODUCT_TYPE)
print("Subtype: " + PRODUCT_SUBTYPE)
print("Major Version: " + MAJOR_PRODUCT_VER)
print("Minor Version: " + MINOR_PRODUCT_VER)
print("Storage Size: " + STORAGE_SIZE)
print("Protocol: " + PROTOCOL_TYPE)
print()
print("Configuration Information")
print("ASCII Mirror: ") 
print("NFC Counter: ") 
print("Wrong Attempt Limit: ") 
print("Strong Load Modulation: ") 

GPIO.cleanup()
