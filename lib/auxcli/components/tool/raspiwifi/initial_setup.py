import os
import sys
import setup_lib
import socket
import json

with open('config.json') as json_file:  
    data = json.load(json_file)

entered_ssid = socket.gethostname()
if entered_ssid.endswith('.local'):
    entered_ssid = entered_ssid[:-6]
wpa_enabled_choice = (data["settings"]["wpa_enabled_choice"])
wpa_entered_key = (data["settings"]["wpa_entered_key"])
auto_config_choice = (data["settings"]["auto_config_choice"])
auto_config_delay = (data["settings"]["auto_config_delay"])
server_port_choice = (data["settings"]["server_port_choice"])
ssl_enabled_choice = (data["settings"]["ssl_enabled_choice"])
install_ans = (data["settings"]["install_ans"])

if os.getuid():
    sys.exit('You need root access to install!')

print()
print()
print("###################################")
print("##### RaspiWiFi Intial Setup  #####")
print("###################################")
print()
print()
if(entered_ssid == ''):
	entered_ssid = input("Would you like to specify an SSID you'd like to use \nfor Host/Configuration mode? [default: RaspiWiFi Setup]: " or "RaspiWiFi Setup")
print()
if(wpa_enabled_choice == ''):
	wpa_enabled_choice = input("Would you like WPA encryption enabled on the hotspot \nwhile in Configuration Mode? [y/N]:")
print()
if(wpa_entered_key == ''):
	wpa_entered_key = input("What password would you like to for WPA hotspot \naccess (if enabled above, \nMust be at least 8 characters) [default: NO PASSWORD]:")
print()
if(auto_config_choice == ''):
	auto_config_choice = input("Would you like to enable \nauto-reconfiguration mode [y/N]?: ")
print()
if(auto_config_delay == ''):
	auto_config_delay = input("How long of a delay would you like without an active connection \nbefore auto-reconfiguration triggers (seconds)? [default: 300]: " or "300")
print()
if(server_port_choice == ''):
	server_port_choice = input("Which port would you like to use for the Configuration Page? [default: 80]: " or "80")
print()
if(ssl_enabled_choice == ''):
	ssl_enabled_choice = input("Would you like to enable SSL during configuration mode \n(NOTICE: you will get a certificate ID error \nwhen connecting, but traffic will be encrypted) [y/N]?: ")
print()
print()
if(install_ans == ''):
	install_ans = input("Are you ready to commit changes to the system? [y/N]: " or "N")


if(install_ans.lower() == 'y'):
	setup_lib.install_prereqs()
	setup_lib.copy_configs(wpa_enabled_choice)
	setup_lib.update_main_config_file(entered_ssid, auto_config_choice, auto_config_delay, ssl_enabled_choice, server_port_choice, wpa_enabled_choice, wpa_entered_key)
else:
	print()
	print()
	print("===================================================")
	print("---------------------------------------------------")
	print()
	print("RaspiWiFi installation cancelled. Nothing changed...")
	print()
	print("---------------------------------------------------")
	print("===================================================")
	print()
	print()
	sys.exit()

print()
print()
print("#####################################")
print("##### RaspiWiFi Setup Complete  #####")
print("#####################################")
print()
print()
print("Initial setup is complete. A reboot is required to start in WiFi configuration mode...")
