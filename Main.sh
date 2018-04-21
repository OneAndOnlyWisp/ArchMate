#!/bin/sh
clear

#Locals
ME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/$0"
KERNEL="Kernel.sh"
CPU="CPU.sh"
GPU="GPU.sh"

#Init
sh Functions.sh Init

#Main loop
INPUT_OPTION=default
while [ "$INPUT_OPTION" != "end" ]
do
  #Menu
  echo "Please type the number of selected task! (Press \"ESC\" to quit.)"
  echo "1. Kernel"
  echo "2. CPU"
  echo "3. GPU"
  echo "4. "
  read -sn1 INPUT_OPTION

  case $INPUT_OPTION in
    '1') sh $KERNEL $ME; clear;;
    '2') sh $CPU; clear;;
    '3') sh $GPU; clear;;
    '4')
      #"Multimedia engine"
      pacman -S --noconfirm pulseaudio pulseaudio-alsa xorg xorg-xinit
      #Desktop
      pacman -S --noconfirm plasma-desktop  
      echo "exec startkde" > ~/.xinitrc
      #Custom apps
      pacman -S --noconfirm konsole dolphin chromium atom sddm    
      #Apply services
      systemctl enable sddm.service
      ;;
    $'\e') clear; break;;
  esac
done
