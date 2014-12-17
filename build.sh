#!/bin/sh

ARDUINO_HOME="/usr/share/arduino"
AVR_GCC_HOME="${ARDUINO_HOME}/hardware/tools/avr"
BASE_DIR=`pwd -P`
SRC_DIR=${BASE_DIR}/src
BIN_DIR=${BASE_DIR}/bin

SALAD_INCLUDE_DIRS="-I${SRC_DIR}"

if [ -f "./build_config.sh" ]; then
    source ./build_config.sh
else
	echo "\t!! N.B.!"
	echo "\t!! You can override build setting with 'build_config.sh' file."
	echo "\t!! See details in 'build_config.sample.sh'."
fi

C_COMPILER="${AVR_GCC_HOME}/bin/avr-gcc"
CPP_COMPILER="${AVR_GCC_HOME}/bin/avr-g++"
ARCHIVER="${AVR_GCC_HOME}/bin/avr-ar"

C_OPTIONS="-c -g -Os -Wall -ffunction-sections -fdata-sections -mmcu=atmega328p -DF_CPU=16000000L -MMD -DUSB_VID=null -DUSB_PID=null -DARDUINO=106"
CPP_OPTIONS="-c -g -Os -Wall -fno-exceptions -ffunction-sections -fdata-sections -mmcu=atmega328p -DF_CPU=16000000L -MMD -DUSB_VID=null -DUSB_PID=null -DARDUINO=106"
LINK_OPTIONS="-Os -Wl,--gc-sections -mmcu=atmega328p"

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

compileSource()
{
  local ARG_SRC=$1
  local ARG_OBJ=$2
  local ARG_INCLUDE_DIRS=$3

  local COMPILER=""
  local OPTIONS=""
  if [[ $ARG_SRC == *".c" ]]; then
    COMPILER=${C_COMPILER}
    OPTIONS=${C_OPTIONS}
  fi
  if [[ $ARG_SRC == *".cpp" ]]; then
    COMPILER=${CPP_COMPILER}
    OPTIONS=${CPP_OPTIONS}
  fi
  local CMD="${COMPILER} ${OPTIONS} ${ARG_INCLUDE_DIRS} ${ARG_SRC} -o ${ARG_OBJ}"

  echo "compiling '${ARG_SRC}' .."
  local CMD_OUTPUT=`${CMD}`
  if [ "x$CMD_OUTPUT" = "x" ]; then
    echo "done." # compiling '${ARG_SRC}'
  else
    echo "!! command:"
    echo ${CMD}
    echo "!! output:"
    echo ${CMD_OUTPUT}

    if [ -f "${ARG_OBJ}" ]; then
      echo "done." # compiling '${ARG_SRC}'
    else
      exit
    fi
  fi
}

compileSourcesFromDir()
{
  local ARG_SRC_DIR=$1
  local ARG_SRC_LIST=$2
  local ARG_INCLUDE_DIRS=$3

  local OBJS=""

  #echo "compiling sources from '${ARG_SRC_DIR}' .."
  for S in ${ARG_SRC_LIST}
  do
    local SRC_FN="${ARG_SRC_DIR}/${S}"
    local OBJ_FN="${BIN_DIR}/${S}.o"

    compileSource "${SRC_FN}" "${OBJ_FN}" "${ARG_INCLUDE_DIRS}"
    OBJS="${OBJS} ${OBJ_FN}"
  done
  #echo "done." # compiling source from '${ARG_SRC_DIR}'
  LAST_RESULT=${OBJS}
}

archiveStaticLib()
{
  local ARG_LIBNAME=$1
  local ARG_OBJ_LIST=$2
  local ARG_BIN_PREFIX=$3

  local LIB_FILE="${BIN_DIR}/${ARG_BIN_PREFIX}/lib${ARG_LIBNAME}.a"
  echo "creating static library '${LIB_FILE}' .."
  for F in ${ARG_OBJ_LIST}
  do
    local CMD="${ARCHIVER} rcs ${LIB_FILE} ${F}"
    echo "archiving '${F}' into '${LIB_FILE}' .."
    local CMD_OUTPUT=`${CMD}`
    if [ "x$CMD_OUTPUT" = "x" ]; then
      echo "done." # compiling '${ARG_SRC}'
    else
      echo "!! command:"
      echo ${CMD}
      echo "!! output:"
      echo ${CMD_OUTPUT}

      if [ -f "${LIB_FILE}" ]; then
        echo "done." # compiling '${ARG_SRC}'
      else
        exit
      fi
    fi
  done

  echo "done."

  LAST_RESULT=${LIB_FILE}
}

buildElfExecutable()
{
  local ARG_ELFNAME=$1
  local ARG_OBJS=$2
  local ARG_STATIC_LIBS=$3
  local ARG_BIN_PREFIX=$4

  local ELF_FILE="${BIN_DIR}/${ARG_BIN_PREFIX}/${ARG_ELFNAME}.elf"
  echo "creating ELF executable '${ELF_FILE}' .."

  local CMD="${C_COMPILER} ${LINK_OPTIONS} -o ${ELF_FILE} ${ARG_OBJS} ${ARG_STATIC_LIBS}"
  local CMD_OUTPUT=`${CMD}`
  if [ "x$CDM_OUTPUT" = "x" ]; then
    echo "done."
  else
    echo "!! command:"
    echo ${CMD}
    echo "!! output:"
    echo ${CMD_OUTPUT}

    if [ -f "{ELF_FILE}" ]; then
      echo "done."
    else
      exit
    fi
  fi

  LAST_RESULT=${ELF_FILE}
}

echo "\n\tARDUINO LIB\n"

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

echo "\n\tWIRE LIB\n"

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

echo "\n\tSALAD\n"

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
