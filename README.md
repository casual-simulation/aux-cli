# aux-cli
AUX-CLI is a collection of tools to help expedite and control your environment on your RaspberryPi that's running AUX. Some tools won't work at all unless you have AUX installed.

## Installing AUX-CLI
All you need to do is curl the install.sh file and run it.  

```bash
curl https://raw.githubusercontent.com/casual-simulation/aux-cli/master/install.sh --output install.sh && sudo bash install.sh
```

If you are installing this independantly of AUX, make sure to install any/every components you need. A breakdown of the available commands are below.  

## AUX-CLI
```
Usage:        aux-cli [COMMAND]  

Command line tools for AUX dealing more with the hardware/server than auxplayer itself.  

COMMANDS:  
install           Install pods/modules/packages to your pi that you can utilize with auxplayer. 
uninstall         Uninstall pods/modules/packages to your pi that you can utilize with auxplayer. 
reinstall         Alias for the uninstall and install commands.
start             Start the docker processes for the aux server. 
stop              Stop the docker processes for the aux server. 
restart           Restart docker processes for the aux server. 
update            Update to the latest version of aux server. 
changehost        Change the hostname of your pi. Applies after restart. 
dhcpcd            Wrapper for setting and unsetting dhcpcd settings. 
hotspot           Tool for managing hotspot mode. 
backup            Creates a backup img of your pi. 
help      -h      Displays this help information.
version   -v      Displays the aux-cli version.
Run 'aux-cli COMMAND --help' for more information on a command. 
```


### install
```
Usage:    install [OPTIONS]

A tool install modules/pods/packages for your pi.

Options:
pishrink      Installs a tool for shrinking pi images.
raspiwifi     Installs a tool to enable/disable hotspot mode.
rfid          Installs a collection of tools to work with RFID a reader/writer.
zerotier      Installs a tool to do stuff.
tethering     Installs a collection of tools to allow tethering via usb or bluetooth.
everything    Installs everything available
```

### uninstall 
```
Usage:    uninstall [OPTIONS]

A tool install modules/pods/packages for your pi.

Options:
pishrink      Uninstalls a tool for shrinking pi images.
raspiwifi     Uninstalls a tool to enable/disable hotspot mode.
rfid          Uninstalls a collection of tools to work with RFID a reader/writer.
zerotier      Uninstalls a tool to do stuff.
tethering     Uninstalls a collection of tools to allow tethering via usb or bluetooth.
everything    Uninstalls everything available
```
### reinstall
```
Usage:    reinstall [OPTIONS]

A tool to reinstall modules/pods/packages for your pi.

Options:
pishrink      Reinstalls a tool for shrinking pi images.
raspiwifi     Reinstalls a tool to enable/disable hotspot mode.
rfid          Reinstalls a collection of tools to work with RFID a reader/writer.
zerotier      Reinstalls a tool to do stuff.
tethering     Reinstalls a collection of tools to allow tethering via usb or bluetooth.
everything    Reinstalls everything available
```

### start
```
Usage:    start [OPTIONS]

A command that starts up your AUX Docker images.
```

### stop
```
Usage:    stop [OPTIONS]

A command that stops your AUX Docker images.
```

### restart
```
Usage:    stop [OPTIONS]

A command that stops your AUX Docker images.
```

### update
```
Usage:    update [OPTIONS]

A tool that wraps the commands for updating AUX and software installed via apt-get.

Options:
-a    --aux           Updates AUX to the latest version.
-A    --aux_auto      Toggle automatic updates on or off for AUX.
-c    --cli           Updates CLI to the latest version.
-C    --cli_auto      Toggle automatic updates on or off for CLI.
-p    --pi            Updates the software for your RaspberryPi (apt-get).
-P    --pi_auto       Toggle automatic updates on or off for your RaspberryPi (apt-get).
-h    --help          Displays this help information.
```

### changehost
```
Usage:    changehost [OPTIONS]

A tool that wraps the commands for changing the hostname permanently and temporarily.

Options:
-n    --hostname STRING   Takes a string to set as the new hostname.
-r    --reboot            Automatically reboot after hostname change.
-h    --help              Displays this help information.
```

### dhcpcd
```
Usage:    dhcpcd [OPTIONS]

A tool that wraps the commands for allowing internet to passthrough a wired connection if available.

Options:
-s    --set           Allows internet passthrough.
-u    --unset         Stops the internet passthrough.
-h    --help          Displays this help information.
```

### hotspot
```
Usage:    hotspot [OPTIONS]

A tool that wraps the commands for allowing internet to passthrough a wired connection if available.

Options:
-c    --check         Checks if you're in hotspot mode.
-e    --enable        Enables hotspot mode.
-d    --disable       Disables hotspot mode.
-h    --help          Displays this help information.
```

### backup
```
Usage:    backup.sh [OPTIONS]

A tool that creates a complete backup image of your RaspberryPi with options to Shrink/Zip/Move/Upload it wherever you choose.

OPTIONS:
-f    --filename STRING       Specify a filename to use. Default: ${hostn}-bkp.img
-m    --mountpoint STRING     Specify a mount point for your local storage device. Default: /mnt/usbstorage
-s    --storage STRING        Specify a local storage device to backup to. The script will try to find one if unspecified.
-l    --log STRING            Specify a location to output the log to. Default: /var/log/pi.backup.log
-S    --shrink STRING         Enable shrinking. Optional: Specify a string to append to the filename. Default: "-shrunk" Shrinking requires a device with at least 2x the storage space as your boot drive. NOTE: Sometimes drives are labeled incorrectly so double check. Actual storage might be slightly over or under the storage advertised. So 2x 4GB might not fit on an 8GB USB.
-Z    --zip                   Enable zipping the backup before moving it to its final destination. For simplicity's sake, it follows the storage requirements for shrinking.
-o    --overwrite             Overwrite any files as needed.
-y                            Bypass prompt to install dependencies.
-h    --help                  Displays this help information.
```