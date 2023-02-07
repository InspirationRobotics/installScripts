#!/bin/bash

sudo apt-get install libgstrtspserver-1.0 libgstreamer1.0-dev -y

git clone https://github.com/Dat-Bois/gst-rtsp-server.git

cd gst-rtsp-server/examples

gcc test-launch.c -o test-launch $(pkg-config --cflags --libs gstreamer-1.0 gstreamer-rtsp-server-1.0)

cd ../.. 

touch start_video.sh

echo 'if [ $# -eq 0 ]; then
    echo "No arguments supplied, defaulting to /dev/video0"
    ~/rtsp/gst-rtsp-server/examples/test-launch "v4l2src device = /dev/video0 ! nvvidconv ! omxh264enc insert-vui=true insert-sps-pps=1 ! video/x-h264, stream-format=byte-stream, alignment=au ! h264parse ! rtph264pay name=pay0 pt=96"
else
    ~/rtsp/gst-rtsp-server/examples/test-launch "v4l2src device = /dev/video$1 ! nvvidconv ! omxh264enc insert-vui=true insert-sps-pps=1 ! video/x-h264, stream-format=byte-stream, alignment=au ! h264parse ! rtph264pay name=pay0 pt=96"
fi
' >> start_video.sh

sudo chmod +x start_video.sh