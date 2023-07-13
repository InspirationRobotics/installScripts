#!/bin/bash

sudo apt update

python3 -m pip install depthai

mkdir ~/oak-d
cd ~/oak-d

git clone https://github.com/luxonis/depthai.git
git clone https://github.com/luxonis/depthai-python.git

cd depthai
python3 install_requirements.py

cd ..

echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="03e7", MODE="0666"' | sudo tee /etc/udev/rules.d/80-movidius.rules

echo "Successfully installed all depthai requirements"
