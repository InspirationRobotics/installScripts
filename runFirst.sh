#!/bin/bash

echo "Thanks for following directions and running this script first, you're not completely stupid ig"
sleep 1
for (( ; ; ))
do
    echo "Are you running as sudo? (Like sudo ./runFirst.sh not in su or anything)"
    read question

    if [ "$question" = "yes" || "$question" = "y" ]; then
        echo "Whoo lets go your not dumb"
        sleep 1
        echo "Initializing stuff..."
        sudo chmod +x opencv4.7.0_Jetson.sh
        sudo chmod +x rtspSetup.sh
        sudo chmod +x test.sh
        echo "See that wasn't bad :), now run this script as sudo in the terminal you are installing stuff in at least once everytime so stuff doesn't go poop"
	break
    elif [ "$question" = "no" || "$question" = "n" ]; then
        echo "You absolute buffoon, run as sudo and then i'll do some fancy shmancy stuff"
	break
    else
        echo "wowwwwww you thought you were cool and quirky by not following the norm, well guess what, you're not. \n Run with sudo and type yes like a normal person"
    fi
done



