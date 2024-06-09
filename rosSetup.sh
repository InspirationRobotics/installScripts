#!/bin/bash

DISTRO="Temp"
version=`lsb_release -sc`

sudo adduser $USER dialout

sudo apt-get install python-pip python-dev -y
sudo apt-get install libxml2-dev libxslt-dev python-dev -y
sudo apt-get install python3-lxml python-lxml -y
pip3 install simple-pid
pip3 install python-dotenv
pip install python-dotenv

sudo apt install software-properties-common -y
sudo add-apt-repository universe -y
sudo add-apt-repository restricted -y
sudo add-apt-repository multiverse -y

sudo apt update
sudo apt upgrade -y

clear >$(tty)
install_mavros_bool=false
# Ask if user wants to install mavros
for (( ; ; ))
do
    echo "Do you want to install MAVROS (yes/no)?"
    read inst_mavros

    if [ "$inst_mavros" = "yes" ]; then
        echo "** Configuration set to install mavros"
        install_mavros_bool=true
	break
    elif [ "$inst_mavros" = "no" ]; then
	break
    fi
done

function install_mavros {
  if [ "$install_mavros_bool" = false ]; then
    echo "------------------------------------"
    echo "** Skipping MAVROS Installation"
    echo "------------------------------------"
    return
  fi
  sleep 5
  echo "------------------------------------"
  echo "** Beginning Installation of MAVROS"
  echo "------------------------------------"

  pip3 install cython
  pip3 install MAVProxy

  sudo apt-get install ros-${DISTRO}-mavros ros-${DISTRO}-mavros-extras -y

  wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh
  chmod a+x install_geographiclib_datasets.sh
  sudo ./install_geographiclib_datasets.sh

  sudo apt-get install ros-${DISTRO}-cv-bridge -y

  echo "------------------------------------"
  echo "** Finished installing mavros"
  echo "------------------------------------"
}

function source_ros {
  echo "------------------------------------"
  echo "** Sourcing ROS"
  echo "------------------------------------"

  echo "export PATH=$PATH:$HOME/.local/bin" >> ~/.bashrc
  echo "source /opt/ros/"${DISTRO}"/setup.bash" >> ~/.bashrc
  source ~/.bashrc

  echo "------------------------------------"
  echo "** Finished sourcing ROS"
  echo "------------------------------------"
}

function install_ros1 {
  sleep 5
  echo "------------------------------------"
  echo "** Beginning Installation of ROS1 ${DISTRO}"
  echo "------------------------------------"

  sudo sh -c "echo \"deb http://packages.ros.org/ros/ubuntu ${version} main\" > /etc/apt/sources.list.d/ros-latest.list"

  sudo apt install curl -y
  curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -

  sudo apt update
  sudo apt install ros-${DISTRO}-desktop-full -y

  source /opt/ros/"${DISTRO}"/setup.bash

  if [[ "$DISTRO" == "melodic" ]]; then
      sudo apt install python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential -y
      sudo apt install python-rosdep -y
      sudo rosdep init
      rosdep update
  fi
  if [[ "$DISTRO" == "noetic" ]]; then
      sudo apt install python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential -y
      sudo apt install python3-rosdep -y
      sudo rosdep init
      rosdep update
  fi

  echo "------------------------------------"
  echo "** Finished installing ROS1 ${DISTRO}"
  echo "------------------------------------"
  source_ros
  install_mavros
}

function install_ros2 {
  sleep 5
  echo "------------------------------------"
  echo "** Beginning Installation of ROS2 ${DISTRO}"
  echo "------------------------------------"

  sudo apt update && sudo apt install curl -y
  sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
  sudo apt update
  sudo apt upgrade -y

  sudo apt install ros-${DISTRO}-desktop -y
  sudo apt install ros-dev-tools -y
  source /opt/ros/"${DISTRO}"/setup.bash

  echo "------------------------------------"
  echo "** Finished installing ROS2 ${DISTRO}"
  echo "------------------------------------"
  source_ros
  install_mavros
}


# ------------------- Main -------------------
sudo apt-get install jq -y

echo "------------------------------------"
echo "** Detecting Version to Install"
echo "------------------------------------"

PRODUCT=$(sudo lshw -json | jq '.product') || PRODUCT=$(sudo lshw -json | jq '.[].product')
clear >$(tty)
if [[ $PRODUCT == *"Orin"* ]]; then
  echo "Detected $PRODUCT setting to Orin Installation (ROS2 HUMBLE)"
  DISTRO="humble"
  install_ros2
elif [[ $PRODUCT == *"Xavier"* ]]; then
  echo "Detected $PRODUCT setting to Xavier Installation (ROS1 NOETIC)"
  DISTRO="noetic"
  install_ros1
elif [[ $PRODUCT == *"Nano"* ]]; then
  echo "Detected $PRODUCT setting to Nano Installation (ROS1 MELODIC)"
  DISTRO="melodic"
  install_ros1
else
  echo "No configuration for product: $PRODUCT. Exiting installation..."
  exit
fi
echo "Done"
exit




