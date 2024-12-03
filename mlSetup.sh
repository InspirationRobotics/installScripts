#!/bin/bash

# Clear the screen
clear >$(tty)
echo "This script will install both Ultralytics, Pytorch, and OnnxRuntime onto your Jetson device"

# Get L4T version
L4T_VERSION=$(head -n 1 /etc/nv_tegra_release | cut -f 2 -d ' ' | cut -f 1 -d '.')
echo "L4T Version: $L4T_VERSION"
sleep 2

# Remove the R
L4T_VERSION=${L4T_VERSION:1}

# Basic procedure to install
sudo apt update
sudo apt install python3-pip -y
sudo pip install -U pip
sudo pip install setuptools

clear >$(tty)

# Check if ultralytics is already installed
check=$(pip3 list | grep -F "ultralytics")
if [ -z "$check" ]; then
    echo "*******Ultralytics has not yet been installed. Installing now..."
    sleep 2
    sudo pip install ultralytics[export]
    clear >$(tty)
    echo "Initial installation complete."
    echo "======================"
    echo "Please reboot your device and then run this script again to finish installation!"
    echo "======================"
    sleep 2
    exit
fi

echo "*******Ultralytics is already installed. Now installing Pytorch..."

# Uninstall current Pytorch version
echo "*******First uninstalling current Pytorch version..."
sudo pip uninstall torch torchvision -y
sudo pip3 uninstall torch torchvision -y

# Install dependencies
echo "*******Installing dependencies..."
sudo apt intsall libopenblas-base libopenmpi-dev libomp-dev -y
sudo apt install libjpeg-dev zlib1g-dev libpython3-dev libopenblas-dev libavcodec-dev libavformat-dev libswscale-dev -y

# Init some variables
torch_url=""
torch_name=""

torch_vision_url=""
torch_vision_name=""

onnx_url=""
onnx_name=""

flag=false

# Check jetpack version
# Reference: https://docs.ultralytics.com/guides/nvidia-jetson/#install-pytorch-and-torchvision
# Reference: https://forums.developer.nvidia.com/t/pytorch-for-jetson/72048
# Reference: https://elinux.org/Jetson_Zoo#ONNX_Runtime
# Reference: https://github.com/rbonghi/jetson_stats/blob/619215f3ffa139ffcfed12eea0d19b995d7f8b17/jtop/core/jetson_variables.py#L211
# Note: Jetpack 6 is Python 3.10
# Note: Jetpack 5 is Python 3.8
# Note: Jetpack 4 is Python 3.6

if [ $L4T_VERSION -ge 36 ]; then
    echo "*******L4T version is greater or equal to 36. Installing Pytorch and Onnx for Jetpack 6..."
    # Pytorch
    torch_url="https://nvidia.box.com/shared/static/mp164asf3sceb570wvjsrezk1p4ftj8t.whl"
    torch_name="torch-2.3.0-cp310-cp310-linux_aarch64.whl"
    # Torch Vision
    torch_vision_url="https://nvidia.box.com/shared/static/xpr06qe6ql3l6rj22cu3c45tz1wzi36p.whl"
    torch_vision_name="torchvision-0.18.0a0+6043bc2-cp310-cp310-linux_aarch64.whl"
    # Onnx
    onnx_url="https://nvidia.box.com/shared/static/48dtuob7meiw6ebgfsfqakc9vse62sg4.whl"
    onnx_name="onnxruntime_gpu-1.18.0-cp310-cp310-linux_aarch64.whl"
    # Set the different installation flag to true
    flag=true

elif [ $L4T_VERSION -ge 34 ]; then
    echo "*******L4T version is greater or equal to 34. Installing Pytorch and Onnx for Jetpack 5..."
    # Pytorch
    torch_url="https://developer.download.nvidia.cn/compute/redist/jp/v512/pytorch/torch-2.1.0a0+41361538.nv23.06-cp38-cp38-linux_aarch64.whl"
    torch_name="torch-2.1.0a0+41361538.nv23.06-cp38-cp38-linux_aarch64.whl"
    # Torch Vision
    torch_vision_url="https://github.com/pytorch/vision torchvision"
    torch_vision_name="v0.16.1"
    # Onnx
    onnx_url="https://nvidia.box.com/shared/static/3fechcaiwbtblznlchl6dh8uuat3dp5r.whl"
    onnx_name="onnxruntime_gpu-1.18.0-cp38-cp38-linux_aarch64.whl"
else
    echo "*******L4T version is less than 34. Installing Pytorch and Onnx for Jetpack 4..."
    # Pytorch
    torch_url="https://nvidia.box.com/shared/static/fjtbno0vpo676a25cgvuqc1wty0fkkg6.whl"
    torch_name="torch-1.10.0-cp36-cp36m-linux_aarch64.whl"
    # Torch Vision
    torch_vision_url="https://github.com/pytorch/vision torchvision"
    torch_vision_name="v0.11.1"
    # Onnx
    onnx_url="https://nvidia.box.com/shared/static/pmsqsiaw4pg9qrbeckcbymho6c01jj4z.whl"
    onnx_name="onnxruntime_gpu-1.11.0-cp36-cp36m-linux_aarch64.whl"
fi

# Make directory for downlods
mkdir ~/torch
cd ~/torch

# Download Pytorch
echo "*******Downloading Pytorch..."
wget -q --show-progress ${torch_url} -O ${torch_name}
sudo pip3 install 'Cython<3'
sudo pip3 install ${torch_name}

# Download Torch Vision
# First check flag
if [ "$flag" = true ]; then
    echo "*******Downloading Torch Vision..."
    wget -q --show-progress ${torch_vision_url} -O ${torch_vision_name}
    sudo pip3 install ${torch_vision_name}
else
    echo "*******Downloading Torch Vision..."
    git clone --branch ${torch_vision_name} ${torch_vision_url}
    cd torchvision
    export BUILD_VERSION=${torch_vision_name:1}
    sudo python3 setup.py install --user
fi

# Go back to torch directory
cd ~/torch

# Download Onnx
echo "*******Downloading Onnx..."
wget -q --show-progress ${onnx_url} -O ${onnx_name}
sudo pip3 install ${onnx_name}

# Fix numpy
sudo pip install numpy==1.23.5

# Remove pip opencv
sudo pip uninstall opencv-python
sudo pip3 uninstall opencv-python
pip3 uninstall opencv-python


echo "*******Installation complete!"
