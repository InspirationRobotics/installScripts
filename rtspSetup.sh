#!/bin/bash

sudo apt update
sudo apt-get install jq -y

mkdir ~/rtsp
cd ~/rtsp

sudo apt-get install libgstrtspserver-1.0 libgstreamer1.0-dev -y
sudo apt-get -y install v4l-utils -y
sudo apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-doc gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio -y
sudo pip3 install numpy
sudo apt-get install v4l2loopback-utils -y
sudo pip3 install pyfakewebcam

git clone https://github.com/Dat-Bois/gst-rtsp-server.git

cd gst-rtsp-server/examples

gcc test-launch.c -o test-launch $(pkg-config --cflags --libs gstreamer-1.0 gstreamer-rtsp-server-1.0)

cd ../.. 

touch start_video.sh

echo 'echo "Remember to use h265 decoding on groundstation"
if [ $# -eq 0 ]; then
    echo "No arguments supplied, defaulting to /dev/video0"
    ~/rtsp/gst-rtsp-server/examples/test-launch "v4l2src device=/dev/video0 ! video/x-raw, width=640, height=480 ! nvvidconv ! nvv4l2h265enc maxperf-enable=1 ! h265parse ! rtph265pay name=pay0"
else
    ~/rtsp/gst-rtsp-server/examples/test-launch "v4l2src device=/dev/video$1 ! video/x-raw, width=640, height=480 ! nvvidconv ! nvv4l2h265enc maxperf-enable=1 ! h265parse ! rtph265pay name=pay0"
fi
' >> start_video.sh

cp ~/installScripts/test.py ~/rtsp/

sudo chmod +x start_video.sh