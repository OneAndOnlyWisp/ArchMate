#!/bin/bash

#Gather required system information
[[ $(uname -r) = *"lts"* ]] && KERNEL_VERSION="LTS" || KERNEL_VERSION="default"
#Menu
while [ "$INPUT_OPTION" != "end" ]
do
  clear
  echo "Linux currently uses \"$KERNEL_VERSION\" kernel. (Press \"ESC\" to go back.)"
  echo "Available kernel options:"
  case $KERNEL_VERSION in
    "default")
      echo "1. Change to LTS Kernel."
      read -sn1 INPUT_OPTION
      case $INPUT_OPTION in
        '1')
          echo "Trying to install LTS Kernel..."
          #pacman -S --noconfirm --noprogressbar --quiet linux-lts linux-lts-headers
          #Reconfigure to bootloader
          #grub-mkconfig -o /boot/grub/grub.cfg
          ;;
        $'\e') break;;
      esac
      ;;
    "LTS")
      echo "1. Change to default Kernel."
      read -sn1 INPUT_OPTION
      case $INPUT_OPTION in
        '1') echo "Trying to install default Kernel..."; pacman -S --noconfirm --noprogressbar --quiet linux linux-headers;;
        $'\e') break;;
      esac
      ;;
  esac
done
