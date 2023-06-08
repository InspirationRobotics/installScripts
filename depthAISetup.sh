#!/bin/bash


version=$(python3 --version)
version=${version:7:3}
echo $version

sudo apt update

python3 -m pip install depthai
python3 -m pip install roboflowoak

mkdir ~/oak-d
cd ~/oak-d

git clone https://github.com/luxonis/depthai.git
git clone https://github.com/luxonis/depthai-python.git
git clone https://github.com/InspirationRobotics/roboflowoak.git

sudo rm -rf /usr/local/lib/python${version}/dist-packages/roboflowoak
sudo mv roboflowoak /usr/local/lib/python${version}/dist-packages/roboflowoak

cd depthai
python3 install_requirements.py

cd ..

echo '
from roboflowoak import RoboflowOak
import cv2
import time
import numpy as np

if __name__ == '__main__':
    # instantiating an object (rf) with the RoboflowOak module
    rf = RoboflowOak(model="face-detection-attempt-2", confidence=0.05, overlap=0.5,
    version="6", api_key="T1eP7cQw2VkGdtvxfsYN", rgb=True,
    depth=True, device=forward, blocking=True)
    # Running our model and displaying the video output with detections
    while True:
        t0 = time.time()
        # The rf.detect() function runs the model inference
        result, frame, raw_frame, depth = rf.detect()
        predictions = result["predictions"]
        #{
        #    predictions:
        #    [ {
        #        x: (middle),
        #        y:(middle),
        #        width:
        #        height:
        #        depth: ###->
        #        confidence:
        #        class:
        #        mask: {
        #    ]
        #}
        #frame - frame after preprocs, with predictions
        #raw_frame - original frame from your OAK
        #depth - depth map for raw_frame, center-rectified to the center camera

        # timing: for benchmarking purposes
        t = time.time()-t0
        print("INFERENCE TIME IN MS ", 1/t)
        print("PREDICTIONS ", [p.json() for p in predictions])

        # setting parameters for depth calculation
        max_depth = np.amax(depth)
        cv2.imshow("depth", depth/max_depth)
        # displaying the video feed as successive frames
        cv2.imshow("frame", frame)

        # how to close the OAK inference window / stop inference: CTRL+q or CTRL+c
        if cv2.waitKey(1) == ord('q'):
            break
' >> faceDetect.py

echo 'To run test script do : python3 ~/oak-d/faceDetect.py'
