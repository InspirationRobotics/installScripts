#!/bin/bash

echo "Thanks for following directions and running this script first"
sleep 1
for (( ; ; ))
do
    echo "Are you running as sudo? (Like sudo ./runFirst.sh not in su or anything) (y/n)"
    read question

    if [ "$question" = "y" ]; then
        echo "Whoo lets go your not dumb"
        sleep 1
        echo "Initializing stuff..."
        sudo chmod +x opencv4.7.0_Jetson.sh
        sudo chmod +x rtspSetup.sh
        sudo chmod +x test.sh
        echo "See that wasn't bad :), now run this script as sudo in the terminal you are installing stuff in at least once everytime so stuff doesn't go poop"
	break
    elif [ "$question" = "n" ]; then
        echo "You absolute buffoon, run as sudo and then i'll do some fancy shmancy stuff"
	break
    elif [ "$question" = "\"y\"" ]; then
        echo "I hate you"
	break
    else
        echo "wowwwwww you thought you were cool and quirky by not following the norm, well guess what, you're not."
        echo 'Run with sudo and type "y" like a normal person'
        break
    fi
done



