#!/bin/sh

#Locals
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"
KERNEL=$Source_Path"Kernel.sh"
CPU=$Source_Path"CPU.sh"
GPU=$Source_Path"GPU.sh"
USER=$Source_Path"User.sh"
DESKTOP=$Source_Path"Desktop.sh"
CUSTOM=$Source_Path"Custom.sh"

#Remove default "Stable" kernel
if [[ -e ""$Source_Path"autostart.conf" ]]; then
  if [[ $(cat ""$Source_Path"autostart.conf" | grep -o 'KeepStableKernel=') = "false" ]]; then
    pacman -Rs linux linux-headers
  fi
  rm ""$Source_Path"autostart.conf"
  sh ""$Source_Path"Kernel.sh" RestartSync
fi

#Init
sh ""$Source_Path"Functions.sh" Init

#Main loop
INPUT_OPTION=default
while [ "$INPUT_OPTION" != "end" ]
do
  clear
  #Menu
  echo "Please type the number of selected task! (Press \"ESC\" to quit.)"
  echo "1. Kernel"
  echo "2. CPU"
  echo "3. GPU"
  echo "4. User"
  echo "5. Desktop"
  if [[ -e $CUSTOM ]]; then
    echo "6. Run custom script"
  fi

  read -sn1 INPUT_OPTION

  case $INPUT_OPTION in
    '1') sh $KERNEL; clear;;
    '2') sh $CPU; clear;;
    '3') sh $GPU; clear;;
    '4') sh $USER; clear;;
    '5') sh $DESKTOP; clear;;
    '6') [[ -e $CUSTOM ]] && sh $CUSTOM; clear;;
    $'\e') clear; break;;
  esac
done
