
Image sd card with the medcart Image
unplug/replug
download latest NOOBS LITE
unzip it
Copy all of the files except recovery.cmdline onto the RECOVERY partition of the sd card


Boot known pi
Plug in MedCabinet sdcard

ssha raspberrypi
    raspberry

sudo fdisk -l
    make note of linux device (mine is /dev/sdb7)

sudo mkdir -p /mnt/mydisk
sudo mount /dev/sdb7 /mnt/mydisk
sudo mkdir /mnt/mydisk/home/medserve/.ssh
sudo nano /mnt/mydisk/home/medserve/.ssh/authorized_keys
    paste in your public key from your computer

sudo nano /mnt/mydisk/etc/wpa_supplicant/wpa_supplicant.conf
    Add your network

sudo umount /mnt/mydisk
exit

Plug MedCabinet sdcard into it's own Pi W
Boot it up

From your Computer (default hostname is MedCabinet(hosts) or Cliomed(hostname), but I changed mine to medcart)
ssh -i ~/.ssh/id_rsa medserve@medcart.local


Update locales
    # Change Keyboard Layout
    echo "DEBUG: Changing Keyboard Layout..."
    sudo sed -i 's/^XKBLAYOUT=".*\?"/XKBLAYOUT="us"/g' /etc/default/keyboard

    # Modify locale.gen file
    echo "DEBUG: Changing Locales..."
    sudo sed -i 's/^# en_US/en_US/g' /etc/locale.gen
    sudo sed -i 's/^en_GB/# en_GB/g' /etc/locale.gen

    # Generate Locales
    echo "DEBUG: Generating Locales..."
    sudo locale-gen

    # Change Locale
    echo "DEBUG: Updating Locales..."
    sudo update-locale LANG=en_US.UTF-8
    sudo update-locale LANGUAGE=en_US.UTF-8
    . /etc/default/locale


sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y

sudo sed -i 's/jessie/stretch/g' /etc/apt/sources.list
sudo sed -i 's/jessie/stretch/g' /etc/apt/sources.list.d/raspi.list

sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get autoremove -y && sudo apt-get autoclean


sudo rpi-update




# Stretch to Buster
sudo apt-get update && sudo apt-get upgrade -y

sudo sed -i 's/stretch/buster/g' /etc/apt/sources.list
sudo sed -i 's/stretch/buster/g' /etc/apt/sources.list.d/raspi.list

sudo apt-get update && sudo apt-get full-upgrade -y
sudo apt-get autoremove -y && sudo apt-get autoclean


# Might need to install a missing dependency
sudo apt-get install firmware-misc-nonfree

sudo rpi-update


sudo apt-get install -y exfat-fuse exfat-utils 
sudo mkdir -p /mnt/mydisk
sudo mount /dev/sda2 /mnt/mydisk


wget https://code.lewman.com/andrew/PiShrink/raw/master/pishrink.sh
chmod +x pishrink.sh
sudo mv pishrink.sh /usr/local/bin


sudo /mnt/mydisk/aux-cli/lib/aux-cli/util/backup -S -o -y -m /mnt/mydisk
