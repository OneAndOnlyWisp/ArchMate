#!/bin/sh
#-------------------------------------------------------------------------------
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CPP="$Source_Path/cpp.sh"
DOCKER="$Source_Path/docker.sh"
VULKAN="$Source_Path/vulkan.sh"
TF="$Source_Path/tensorflow.sh"
DEBUG="$Source_Path/debugger.sh"
#Main loop----------------------------------------------------------------------
while [ "$INPUT_OPTION" != "end" ]; do
  clear
  echo "Please type the number of selected task! (Press \"ESC\" to quit.)"
  echo "1. Debugger (C, C++, Go, Rust)"
  echo "2. C++"
  echo "3. Docker"
  echo "4. Vulkan"
  echo "5. Tensorflow (Python)"
  read -sn1 INPUT_OPTION
  case $INPUT_OPTION in
    '1') sh $DEBUG; clear;;
    '2') sh $CPP; clear;;
    '3') sh $DOCKER; clear;;
    '4') sh $VULKAN; clear;;
    '5') sh $TF; clear;;
    $'\e') clear; break;;
  esac
done
#-------------------------------------------------------------------------------
