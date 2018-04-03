#!/bin/sh

GPU=$(lspci | grep -o 'VGA compatible controller: .*' | sed 's/.*: //')

while [ "$INPUT_OPTION" != "end" ]
do
  clear
  echo "(Press \"ESC\" to go back.)"
  echo "Graphical adapters found:"
  echo "- $GPU"
  echo "Available options:"
  echo "1. Install NVIDIA graphics driver"
  echo "2. Install AMD/ATI graphics driver"
  read -sn1 INPUT_OPTION
  #Execute action
  case $INPUT_OPTION in
    '3') echo "Trying to install NVIDIA graphics driver...";;
    '4') echo "Trying to install AMD/ATI graphics driver...";;
    $'\e') break;;
  esac
  clear
  echo "Press a button to continue..."; read TEMP
done
