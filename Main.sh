#!/bin/sh

#Contents
KERNEL="Kernel.sh"
CPU="CPU.sh"
GPU="GPU.sh"

#Main loop
INPUT_OPTION=default
while [ "$INPUT_OPTION" != "end" ]
do
  #Menu
	echo "Please type the number of selected task! (Press \"ESC\" to quit.)"
	echo "1. Kernel"
  echo "2. CPU"
  echo "3. GPU"
  read -sn1 INPUT_OPTION

  case $INPUT_OPTION in
    '1') /bin/bash $KERNEL; clear;;
    '2') /bin/bash $CPU; clear;;
    '3') /bin/bash $GPU; clear;;
    $'\e') clear; break;;
  esac
done
