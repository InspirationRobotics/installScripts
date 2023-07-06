#!/bin/bash

for (( ; ; ))
do
    echo "Make sure you run this script with a GUI interface attached (i.e. noMachine or a monitor)"
    echo "Do you wish to proceed? (y/n)"
    read question

    if [ "$question" = "y" ]; then
        echo "** Proceeding..."
	break
    elif [ "$question" = "n" ]; then
	exit
    fi
done

wget https://www.pjrc.com/teensy/00-teensy.rules
sudo mv 00-teensy.rules /etc/udev/rules.d/

echo "** Rules have been added to udev"

cd /home/inspiration/Downloads/

wget https://downloads.arduino.cc/arduino-1.8.19-linuxaarch64.tar.xz
tar -xvf arduino-1.8.19-linuxaarch64.tar.xz
cd arduino-1.8.19
sudo sh install.sh

echo "** Arduino 1.8.19 has been installed"

cd /home/inspiration/Downloads/
wget https://www.pjrc.com/teensy/td_158/TeensyduinoInstall.linuxaarch64
sudo chmod 755 TeensyduinoInstall.linuxaarch64

echo "** Follow the prompts and then reboot..."

./TeensyduinoInstall.linuxaarch64