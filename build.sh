#!/bin/bash

ARDUINO_HOME="/usr/share/arduino"
AVR_GCC_HOME="${ARDUINO_HOME}/hardware/tools/avr"
BASE_DIR=`pwd -P`
SRC_DIR=${BASE_DIR}/src
BIN_DIR=${BASE_DIR}/bin

SALAD_INCLUDE_DIRS="-I${SRC_DIR}"

if [ -f "./build_config.sh" ]; then
  . ./build_config.sh
else
	echo "\t!! N.B.!"
	echo "\t!! You can override build setting with 'build_config.sh' file."
	echo "\t!! See details in 'build_config.sample.sh'."
fi

C_COMPILER="${AVR_GCC_HOME}/bin/avr-gcc"
CPP_COMPILER="${AVR_GCC_HOME}/bin/avr-g++"
ARCHIVER="${AVR_GCC_HOME}/bin/avr-ar"
OBJCOPY="${AVR_GCC_HOME}/bin/avr-objcopy"

C_OPTIONS="-c -g -Os -Wall -ffunction-sections -fdata-sections -mmcu=atmega328p -DF_CPU=16000000L -MMD -DUSB_VID=null -DUSB_PID=null -DARDUINO=106"
CPP_OPTIONS="-c -g -Os -Wall -fno-exceptions -ffunction-sections -fdata-sections -mmcu=atmega328p -DF_CPU=16000000L -MMD -DUSB_VID=null -DUSB_PID=null -DARDUINO=106"
LINK_OPTIONS="-Os -Wl,--gc-sections -mmcu=atmega328p"

echo "!! ARDUINO_HOME: ${ARDUINO_HOME}"
echo "!! AVR_GCC_HOME: ${AVR_GCC_HOME}"
echo "!! SRC_DIR: ${SRC_DIR}"
echo "!! BIN_DIR: ${BIN_DIR}"
echo "!! C_COMPILER: ${C_COMPILER}"
echo "!! CPP_COMPILER: ${CPP_COMPILER}"
echo "!! ARCHIVER: ${ARCHIVER}"
echo "!! OBJCOPY: ${OBJCOPY}"
echo "!! C_OPTIONS: ${C_OPTIONS}"
echo "!! CPP_OPTIONS: ${CPP_OPTIONS}"
echo "!! LINK_OPTIONS: ${LINK_OPTIONS}"
echo

#TODO: arduino preprocessing

#prepeare to compile
if [ -d "${BIN_DIR}" ]; then
  rm -Rf "${BIN_DIR}"
fi

if [ ! -d "${BIN_DIR}" ]; then
  mkdir "${BIN_DIR}"
fi
if [ ! -d "${BIN_DIR}/Salad" ]; then
  mkdir "${BIN_DIR}/Salad"
fi
if [ ! -d "${BIN_DIR}/Wire" ]; then
  mkdir "${BIN_DIR}/Wire"
fi
if [ ! -d "${BIN_DIR}/Wire/utility" ]; then
  mkdir "${BIN_DIR}/Wire/utility"
fi
if [ ! -d "${BIN_DIR}/arduino" ]; then
  mkdir "${BIN_DIR}/arduino"
fi
if [ ! -d "${BIN_DIR}/arduino/avr-libc" ]; then
  mkdir "${BIN_DIR}/arduino/avr-libc"
fi

if [ -f "./build_functions.sh" ]; then
  . ./build_functions.sh
else
  echo "!! cant find 'build_functions.sh'"
  exit
fi

echo $'\n\tBUILDING ARDUINO LIB\n'

#compile Arduino
ARDUINO_INCLUDE_DIRS="${ARDUINO_INCLUDE_DIRS} -I${ARDUINO_HOME}/hardware/arduino/cores/arduino"
ARDUINO_INCLUDE_DIRS="${ARDUINO_INCLUDE_DIRS} -I${ARDUINO_HOME}/hardware/arduino/variants/eightanaloginputs"
ARDUINO_SRCS="arduino/avr-libc/malloc.c arduino/avr-libc/realloc.c"
ARDUINO_SRCS="${ARDUINO_SRCS} arduino/WInterrupts.c"
ARDUINO_SRCS="${ARDUINO_SRCS} arduino/wiring.c arduino/wiring_analog.c arduino/wiring_digital.c arduino/wiring_pulse.c arduino/wiring_shift.c"
ARDUINO_SRCS="${ARDUINO_SRCS} arduino/CDC.cpp"
ARDUINO_SRCS="${ARDUINO_SRCS} arduino/HardwareSerial.cpp"
ARDUINO_SRCS="${ARDUINO_SRCS} arduino/HID.cpp"
ARDUINO_SRCS="${ARDUINO_SRCS} arduino/IPAddress.cpp"
ARDUINO_SRCS="${ARDUINO_SRCS} arduino/main.cpp"
ARDUINO_SRCS="${ARDUINO_SRCS} arduino/new.cpp"
ARDUINO_SRCS="${ARDUINO_SRCS} arduino/Print.cpp arduino/Stream.cpp arduino/Tone.cpp arduino/USBCore.cpp"
ARDUINO_SRCS="${ARDUINO_SRCS} arduino/WMath.cpp arduino/WString.cpp"
ARDUINO_OBJS=""
compileSourcesFromDir "${ARDUINO_HOME}/hardware/arduino/cores" "${ARDUINO_SRCS}" "${ARDUINO_INCLUDE_DIRS}"
ARDUINO_OBJS="${ARDUINO_OBJS} ${LAST_RESULT}"
#create Arduino lib
archiveStaticLib "Arduino" "${ARDUINO_OBJS}" ""
ARDUINO_LIB="${LAST_RESULT}"

echo $'\n\tBUILDING WIRE LIB\n'

#compile Wire
WIRE_INCLUDE_DIRS="${WIRE_INCLUDE_DIRS} -I${ARDUINO_HOME}/libraries/Wire"
WIRE_INCLUDE_DIRS="${WIRE_INCLUDE_DIRS} -I${ARDUINO_HOME}/libraries/Wire/utility"
WIRE_INCLUDE_DIRS="${WIRE_INCLUDE_DIRS} -I${ARDUINO_HOME}/hardware/arduino/cores/arduino"
WIRE_INCLUDE_DIRS="${WIRE_INCLUDE_DIRS} -I${ARDUINO_HOME}/hardware/arduino/variants/eightanaloginputs"
WIRE_SRCS="Wire/Wire.cpp Wire/utility/twi.c"
WIRE_OBJS=""
compileSourcesFromDir "${ARDUINO_HOME}/libraries" "${WIRE_SRCS}" "${WIRE_INCLUDE_DIRS}"
WIRE_OBJS="${WIRE_OBJS} ${LAST_RESULT}"
#create Wire lib
archiveStaticLib "Wire" "${WIRE_OBJS}" ""
WIRE_LIB="${LAST_RESULT}"

echo $'\n\tBUILDING SALAD FIRMWARE\n'

#compile Salad
SALAD_INCLUDE_DIRS="${SALAD_INCLUDE_DIRS} -I${ARDUINO_HOME}/hardware/arduino/cores/arduino"
SALAD_INCLUDE_DIRS="${SALAD_INCLUDE_DIRS} -I${ARDUINO_HOME}/hardware/arduino/variants/eightanaloginputs"
SALAD_INCLUDE_DIRS="${SALAD_INCLUDE_DIRS} -I${ARDUINO_HOME}/libraries/Wire"
SALAD_SRCS="Salad/Salad.cpp Salad/EApp.cpp"
SALAD_OBJS=""
compileSourcesFromDir "${SRC_DIR}" "${SALAD_SRCS}" "${SALAD_INCLUDE_DIRS}"
SALAD_OBJS="${SALAD_OBJS} ${LAST_RESULT}"
#build Salad ELF
buildElfExecutable "Salad" "${SALAD_OBJS}" "${WIRE_LIB} ${ARDUINO_LIB}" ""
SALAD_ELF="${LAST_RESULT}"
#create Salad hex
createHexFile "Salad" "${SALAD_ELF}" ""
SALAD_HEX="${LAST_RESULT}"
