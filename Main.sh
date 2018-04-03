#!/bin/sh

#Contents
KERNEL="Kernel.sh"
CPU="CPU.sh"
GPU="GPU.sh"

VGA_Menu()
{
  while [ "$INPUT_OPTION" != "end" ]
  do
    #VGA
    echo "VGA Options. (Type \"back\" to go back a level, or \"exit\" to quit.)"
    echo "2. Install Intel graphics driver"
    echo "3. Install NVIDIA graphics driver"
    echo "4. Install AMD/ATI graphics driver"
    read -sn1 INPUT_OPTION
    #Execute action
    case $INPUT_OPTION in
      '1') echo "Graphical adapters:"; lspci -k | grep -A 2 -E "(VGA|3D)" ;;
      '2')
        echo "Trying to install Intel graphics driver..."; pacman -S --noconfirm --noprogressbar --quiet mesa
        #Ivy Bridge and newer
        #[ -n $MOTHERBOARD_INFO ] && pacman -S --noconfirm --noprogressbar --quiet vulkan-intel
        ;;
      '3') echo "Trying to install NVIDIA graphics driver...";;
      '4') echo "Trying to install AMD/ATI graphics driver...";;
      $'\e') break;;
    esac
    clear
    echo "Press a button to continue..."; read TEMP
  done
}

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
