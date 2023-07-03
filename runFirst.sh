#!/bin/bash

# echo "Thanks for following directions and running this script first"
# sleep 1
sudo apt install nano -y > /dev/null
sudo apt install screen -y > /dev/null
for (( ; ; ))
do
    echo "Are you running as sudo? (Like sudo ./runFirst.sh not in su or anything) (y/n)"
    read question

    if [ "$question" = "y" ]; then
        #echo "Whoo lets go your not dumb"
        echo "Initializing..."
        sudo chmod +x opencv4.7.0_Jetson.sh
        sudo chmod +x rtspSetup.sh
        sudo chmod +x test.sh
        sudo chmod +x depthAISetup.sh
        sudo chmod +x nomachineSetup.sh
        sudo chmod +x rosSetup.sh
        echo $SUDO_USER
        cd /home/inspiration/
        [ ! -d "/home/inspiration/auv" ] && echo "Downloading AUV code..." && sudo -u $SUDO_USER git clone https://github.com/InspirationRobotics/robosub_2023.git && mv /home/inspiration/robosub_2023 /home/inspiration/auv && cd auv && sudo -u $SUDO_USER git checkout Redesign && cd /home/inspiration/
        [ ! -d "/home/inspiration/companion" ] && echo "Downloading companion code..." && sudo -u $SUDO_USER git clone https://github.com/bluerobotics/companion.git
        sleep 2
        TEMP=$(dpkg -s postfix)
        if [[ $TEMP == *"installed"* ]]; then
            echo "Found postfix"
        else
            echo ""
            echo "To solve: sudo apt install postfix and select 'Local Only' on the configuration screen which shows"
            echo ""
        fi
        echo "** Please run this script as sudo in the terminal you are installing stuff in at least once everytime you use an install script"
    break
    elif [ "$question" = "n" ]; then
        #echo "You absolute buffoon, run as sudo and then i'll do some fancy shmancy stuff"
        echo "Please rerun in sudo"
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



