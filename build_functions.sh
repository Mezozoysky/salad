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

  local CMD="${C_COMPILER} ${LINK_OPTIONS} -o ${ELF_FILE} ${ARG_OBJS} ${ARG_STATIC_LIBS} -lm"
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

createHexFile()
{
  local ARG_HEXNAME=$1
  local ARG_ELF=$2
  local ARG_BIN_PREFIX=$3

  local EEP_FILE="${BIN_DIR}/${ARG_BIN_PREFIX}/${ARG_HEXNAME}.eep"
  local HEX_FILE="${BIN_DIR}/${ARG_BIN_PREFIX}/${ARG_HEXNAME}.hex"

  local CMD=""
  local CMD_OUTPUT=""

  echo "creating EEP file '${EEP_FILE}' .."
  CMD="${OBJCOPY}"
  CMD="${CMD} -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0"
  CMD="${CMD} ${ARG_ELF} ${EEP_FILE}"
  CMD_OUTPUT=`${CMD}`
  if [ "x$CMD_OUTPUT" = "x" ]; then
    echo "done."
  else
    echo "!! command:"
    echo ${CMD}
    echo "!! output:"
    echo ${CMD_OUTPUT}

    if [ -f "${EEP_FILE}" ]; then
      echo "done."
    else
      exit
    fi
  fi

  echo "creating HEX file '${HEX_FILE}' .."
  CMD="${OBJCOPY}"
  CMD="${CMD} -O ihex -R .eeprom"
  CMD="${CMD} ${ARG_ELF} ${HEX_FILE}"
  CMD_OUTPUT=`${CMD}`
  if [ "x$CMD_OUTPUT" = "x" ]; then
    echo "done."
  else
    echo "!! command:"
    echo ${CMD}
    echo "!! output:"
    echo ${CMD_OUTPUT}

    if [ -f "${HEX_FILE}" ]; then
      echo "done."
    else
      exit
    fi
  fi

  LAST_RESULT=${HEX_FILE}
}
