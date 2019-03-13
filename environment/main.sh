#!/bin/bash
#-------------------------------------------------------------------------------
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WM="$Source_Path/wm/main.sh"
DE="$Source_Path/de/main.sh"
#Main loop----------------------------------------------------------------------
while [ "$INPUT_OPTION" != "end" ]; do
  clear
  echo "Please type the number of selected task! (Press \"ESC\" to quit.)"
  echo "1. Window Manager"
  echo "2. Desktop environment"
  read -sn1 INPUT_OPTION
  case $INPUT_OPTION in
    '1') sh $WM; clear;;
    '2') sh $DE; clear;;
    $'\e') clear; break;;
  esac
done
#-------------------------------------------------------------------------------
