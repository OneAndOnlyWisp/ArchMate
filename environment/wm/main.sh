#!/bin/bash
#-------------------------------------------------------------------------------
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WM="$Source_Path/i3/install.sh"
APPS="$Source_Path/i3/apps.sh"
CONFIG="$Source_Path/i3/configs.sh"
LAPTOP="$Source_Path/i3/laptop.sh"
#Main loop----------------------------------------------------------------------
while [ "$INPUT_OPTION" != "end" ]; do
  clear
  echo "Please type the number of selected task! (Press \"ESC\" to quit.)"
  echo "1. Install i3wm"
  echo "2. Install default apps"
  echo "3. Copy custom settings"
  read -sn1 INPUT_OPTION
  case $INPUT_OPTION in
    '1') sh $WM; clear;;
    '2') sh $APPS; clear;;
    '3') sh $CONFIG; clear;;
    $'\e') clear; break;;
  esac
done
#-------------------------------------------------------------------------------
