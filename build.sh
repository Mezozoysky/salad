#!/bin/sh

if [ -f "./" ]; then
    source ./build_config.sh
fi

AVR_GCC="${AVR_HOME}/bin/gcc"
AVR_G++="${AVR_HOME}/bin/g++"
