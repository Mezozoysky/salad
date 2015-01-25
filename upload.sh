#!/bin/bash

BASE_DIR=`pwd -P`
BIN_DIR="${BASE_DIR}/bin"
FIRMWARE="Salad.hex"

read -n1 -p "Upload Salad firmware? [y,n]" input
if [[ $input == "Y" || $input == "y" ]]; then
       	printf "\nUploading.."
else
        printf "\nBuy."
	exit 0
fi
if [ $(find $BIN_DIR -name "$FIRMWARE") ]; then 
	printf "\nFile to upload: ${BIN_DIR}/${FIRMWARE}"
else
	printf "\n${BIN_DIR}/${FIRMWARE} not found\nPress any key to exit"
 	read
	exit 0
fi

#read -n1
avrdude -c gpio -p m328p -U flash:w:"${BIN_DIR}/${FIRMWARE}"


