import cv2
import time
import pyfakewebcam
import numpy as np
import os
import sys


# will create two fake webcam devices
os.system("sudo modprobe v4l2loopback devices=2")

IMG_W = 640
IMG_H = 480

cam = cv2.VideoCapture(0)
cam.set(cv2.CAP_PROP_FRAME_WIDTH, IMG_W)
cam.set(cv2.CAP_PROP_FRAME_HEIGHT, IMG_H)

fake1 = pyfakewebcam.FakeWebcam('/dev/video8', IMG_W, IMG_H)
fake2 = pyfakewebcam.FakeWebcam('/dev/video9', IMG_W, IMG_H)

while True:
    try:
        ret, frame = cam.read()

        flipped = cv2.flip(frame, 1)

        # Mirror effect
        frame[0: IMG_H, IMG_W//2: IMG_W] = flipped[0: IMG_H, IMG_W//2: IMG_W]

        fake1.schedule_frame(frame)
        fake2.schedule_frame(flipped)

        time.sleep(1/15.0)
    except KeyboardInterrupt:
        print("Exiting...")
        print("please run: sudo modprobe -r v4l2loopback")
        sys.exit()
