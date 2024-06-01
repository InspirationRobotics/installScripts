# Install Scripts for Team Inspiration Jetson Devices

### Note: 
These scripts take some time so it is advised to run them via a screen session or using a monitor.

## Running a script

The general process to run a script is by first creating a new screen:

```
screen -S screen_name
```

Now inside the screen run:
```
sudo ./runFirst.sh
```

After that finishes, you can run the install script, for example:
```
./opencv4.9.0_Jetson.sh
```

Once the script has started you will want to detach from the screen so it can run in the background. You can do that with `CTRL-A` and then `D`. Make sure to detach before exiting the ssh from the Jetson.

To re-attach to the screen you can do the following:
```
screen -r screen_name
```

When the install is finished, you can end the screen by doing `CTRL-D`.

Repeat the above process for all the relevant scripts (listed below) in a sequential fashion. Do NOT run these scripts in parallel.

## Order to install:

Based off how the scripts install their dependencies, I suggest the following install procedure:

1. `./depthAISetup.sh`
2. `./opencv4.x.0_Jetson.sh` (select yes to remove old opencv; near the end it will ask for password again)
3. `./rosSetup.sh`
4. `./rtspSetup.sh`
5. `./nomachineSetup.sh` (optional)
6. `./teensySetup.sh` (optional)
