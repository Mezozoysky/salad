#!/bin/sh

COMPILER="avr-g++"
COMPILER_OPTIONS="-c -g -Os -Wall -fno-exceptions -ffunction-sections -fdata-sections -mmcu=atmega328p -DF_CPU=16000000L -MMD -DUSB_VID=null -DUSB_PID=null -DARDUINO=106"
ARDUINO_HOME="/usr/share/arduino"

if [ -f "./build_config.sh" ]; then
    source ./build_config.sh
else
	echo "\t!! N.B.!"
	echo "\t!! You can override build setting with 'build_config.sh' file."
	echo "\t!! See details in 'build_config.sample.sh'."
fi

#TODO: arduino preprocessing
