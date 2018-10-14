#!/bin/sh
#-------------------------------------------------------------------------------
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CPP="$Source_Path/cpp.sh"
DOCKER="$Source_Path/docker.sh"
VULKAN="$Source_Path/vulkan.sh"
TF="$Source_Path/tensorflow.sh"
#Main loop----------------------------------------------------------------------
while [ "$INPUT_OPTION" != "end" ]; do
  clear
  echo "Please type the number of selected task! (Press \"ESC\" to quit.)"
  echo "1. C++"
  echo "2. Docker"
  echo "3. Vulkan"
  echo "4. Tensorflow (Python)"
  read -sn1 INPUT_OPTION
  case $INPUT_OPTION in
    '1') sh $CPP; clear;;
    '2') sh $DOCKER; clear;;
    '3') sh $VULKAN; clear;;
    '4') sh $TF; clear;;
    $'\e') clear; break;;
  esac
done
#-------------------------------------------------------------------------------
