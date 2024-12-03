#!/bin/bash

version="4.10.0"
folder="cvCuda"
#archBin="7.2,8.7" #for NX, for Nano change to 5.3

sudo apt-get install dphys-swapfile -y #> /dev/null
sudo apt-get install jq -y #> /dev/null
sleep 1

PRODUCT=$(sudo lshw -json | jq '.product') || PRODUCT=$(sudo lshw -json | jq '.[].product')

clear >$(tty)

if [[ $PRODUCT == *"Orin"* ]]; then
  echo "Detected $PRODUCT setting to Orin Installation"
  archBin="8.7"
elif [[ $PRODUCT == *"Xavier"* ]]; then
  echo "Detected $PRODUCT setting to Xavier Installation"
  archBin="7.2,8.7"
elif [[ $PRODUCT == *"Nano"* ]]; then
  echo "Detected $PRODUCT setting to Nano Installation"
  archBin="5.3"
  SWAP=$(free -m | grep Swap)
  SWAPtotal=${SWAP:10:15}
  echo $SWAPtotal

  if [ $SWAPtotal -gt 4096 ]; then
    echo "Swap is "${SWAPtotal}"mb which is enough"
  else
    echo "********************************************"
    echo "Swap is "${SWAPtotal}"mb which is not enough"
    echo "********************************************"
    echo "Please increase swap by completing the following procedure:"
    echo ""
    echo "sudo nano /sbin/dphys-swapfile #change to CONF_MAXSWAP=4096 add CONF_SWAPSIZE=4096"
    echo "Ctrl-X then y to save"
    echo "sudo nano /etc/dphys-swapfile #uncomment CONF_MAXSWAP and set to CONF_MAXSWAP=4096"
    echo "Ctrl-X then y to save"
    echo "Then reboot the Jetson using: sudo reboot"
    echo "Make sure to always run ./runFirst first before running this script again"
    exit
  fi
else
  echo "No configuration for product: $PRODUCT. Exiting installation..."
  exit
fi

for (( ; ; ))
do
    echo "Do you want to remove the default OpenCV (yes/no)?"
    read rm_old

    if [ "$rm_old" = "yes" ]; then
        echo "** Remove other OpenCV first"
        sudo apt -y purge *libopencv*
        pip3 uninstall opencv-contrib-python
	break
    elif [ "$rm_old" = "no" ]; then
	break
    fi
done

sudo sh -c "echo '/usr/local/cuda/lib64' >> /etc/ld.so.conf.d/nvidia-tegra.conf"
sudo ldconfig

echo "------------------------------------"
echo "** Install requirement (1/4)"
echo "------------------------------------"
sudo apt update
sudo apt upgrade -y

echo "------Starting Dependency install script"
sleep 2
sudo chmod +x dependOpenCV.sh
sudo sh ./dependOpenCV.sh
echo "------Finished script----"
sleep 5

echo "-------Installing other dependencies-----"
sudo apt install -y build-essential cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev
sudo apt install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
sudo apt install -y python3.8-dev python-dev python-numpy python3-numpy
sudo apt install -y libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev
sudo apt install -y libv4l-dev v4l-utils qv4l2 v4l2ucp
sudo apt install -y curl


echo "------------------------------------"
echo "** Download opencv "${version}" (2/4)"
echo "------------------------------------"
cd ~
mkdir $folder
cd ${folder}
curl -L https://github.com/opencv/opencv/archive/${version}.zip -o opencv-${version}.zip
curl -L https://github.com/opencv/opencv_contrib/archive/${version}.zip -o opencv_contrib-${version}.zip
unzip opencv-${version}.zip
unzip opencv_contrib-${version}.zip
rm opencv-${version}.zip opencv_contrib-${version}.zip
cd opencv-${version}/


echo "------------------------------------"
echo "** Build opencv "${version}" (3/4)"
echo "------------------------------------"
mkdir release
cd release/
#cmake -D WITH_CUDA=ON -D WITH_CUDNN=ON -D CUDA_ARCH_BIN="7.2,8.7" -D CUDA_ARCH_PTX="" -D OPENCV_GENERATE_PKGCONFIG=ON -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${version}/modules -D WITH_GSTREAMER=ON -D WITH_LIBV4L=ON -D BUILD_opencv_python3=ON -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_EXAMPLES=OFF -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local ..
cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${version}/modules -D EIGEN_INCLUDE_PATH=/usr/include/eigen3 -D WITH_OPENCL=OFF -D WITH_CUDA=ON -D CUDA_ARCH_BIN=${archBin} -D CUDA_ARCH_PTX="" -D WITH_CUDNN=ON -D WITH_CUBLAS=ON -D ENABLE_FAST_MATH=ON -D CUDA_FAST_MATH=ON -D OPENCV_DNN_CUDA=ON -D ENABLE_NEON=ON -D WITH_QT=OFF -D WITH_OPENMP=ON -D BUILD_TIFF=ON -D WITH_FFMPEG=ON -D WITH_GSTREAMER=ON -D WITH_TBB=ON -D BUILD_TBB=ON -D BUILD_TESTS=OFF -D WITH_EIGEN=ON -D WITH_V4L=ON -D WITH_LIBV4L=ON -D OPENCV_ENABLE_NONFREE=ON -D INSTALL_C_EXAMPLES=OFF -D INSTALL_PYTHON_EXAMPLES=OFF -D OPENCV_GENERATE_PKGCONFIG=ON -D PYTHON3_PACKAGES_PATH=/usr/lib/python3/dist-packages -D PYTHON_DEFAULT_EXECUTABLE=$(which python3) -D BUILD_EXAMPLES=OFF -D BUILD_opencv_python3=yes ..
sleep 30
make -j$(nproc)


echo "------------------------------------"
echo "** Install opencv "${version}" (4/4)"
echo "------------------------------------"
sudo make install
echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> ~/.bashrc

if [[ $PRODUCT == *"Orin"* ]]; then
  echo 'export PYTHONPATH=/usr/local/lib/python3.10/site-packages/:$PYTHONPATH' >> ~/.bashrc
else
  echo 'export PYTHONPATH=/usr/local/lib/python3.8/site-packages/:$PYTHONPATH' >> ~/.bashrc
fi
source ~/.bashrc

sleep 5
if [[ $PRODUCT == *"Orin"* ]]; then
  echo "------------------------------------"
elif [[ $PRODUCT == *"Nano"* ]]; then
  echo "------------------------------------"
  echo "** Cleaning up extra swap..."
  echo "------------------------------------"
  sudo /etc/init.d/dphys-swapfile stop
  sudo apt-get remove --purge dphys-swapfile -y
  sudo rm /var/swap
  echo "** Removed extra swap"
fi

echo "** Installed opencv "${version}" with CUDA support successfully"
