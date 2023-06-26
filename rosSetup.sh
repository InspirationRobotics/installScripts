#!/bin/bash

DISTRO="Temp"
version=`lsb_release -sc`

sudo apt-get install python-pip python-dev -y
sudo apt-get install libxml2-dev libxslt-dev python-dev -y
sudo apt-get install python3-lxml python-lxml -y

echo "------------------------------------"
echo "** Detecting Version to Install"
echo "------------------------------------"

sudo add-apt-repository universe
sudo add-apt-repository restricted
sudo add-apt-repository multiverse

sudo apt update
sudo apt upgrade -y

sudo apt-get install jq -y

PRODUCT=$(sudo lshw -json | jq '.product') || PRODUCT=$(sudo lshw -json | jq '.[].product')

if [[ $PRODUCT == *"Xavier"* ]]; then
  echo "Detected $PRODUCT setting to Xavier Installation"
  DISTRO="noetic"
fi
if [[ $PRODUCT == *"Nano"* ]]; then
  echo "Detected $PRODUCT setting to Nano Installation"
  DISTRO="melodic"
fi

sudo sh -c "echo \"deb http://packages.ros.org/ros/ubuntu ${version} main\" > /etc/apt/sources.list.d/ros-latest.list"

sudo apt install curl -y
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -

echo "------------------------------------"
echo "** Beginning Installation of ROS ${DISTRO}"
echo "------------------------------------"

sudo apt update
sudo apt install ros-${DISTRO}-desktop-full

echo "source /opt/ros/"${DISTRO}"/setup.bash" >> ~/.bashrc
source ~/.bashrc

if [[ "$DISTRO" == "melodic" ]]; then
    sudo apt install python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential
    sudo apt install python-rosdep
    sudo rosdep init
    rosdep update
fi
if [[ "$DISTRO" == "noetic" ]]; then
    sudo apt install python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential
    sudo apt install python3-rosdep
    sudo rosdep init
    rosdep update
fi

echo "------------------------------------"
echo "** Finished installing ROS, now instaling mavros"
echo "------------------------------------"

pip3 install cython
pip3 install MAVProxy

echo "export PATH=$PATH:$HOME/.local/bin" >> ~/.bashrc

sudo apt-get install ros-${DISTRO}-mavros ros-${DISTRO}-mavros-extras -y

wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh
chmod a+x install_geographiclib_datasets.sh
sudo ./install_geographiclib_datasets.sh

echo "------------------------------------"
echo "** Finished installing mavros"
echo "------------------------------------"
echo "Done"




