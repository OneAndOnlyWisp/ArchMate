#!/bin/sh

GPU=$(lspci | grep -o 'VGA compatible controller: .*' | sed 's/.*: //')

while [ "$INPUT_OPTION" != "end" ]
do
  clear
  #echo "(Press \"ESC\" to go back.)"
  echo "Graphical adapters found:                 (Press \"ESC\" to go back.)"
  echo "- $GPU"
  echo "Available options:"
  #Create menu items
  OPT_COUNT=0
  if [[ $GPU = *"NVIDIA"* ]]; then
    let OPT_COUNT+=1; let NVIDIA_OPT=OPT_COUNT; echo "$NVIDIA_OPT. Install NVIDIA graphics driver."
  fi
  if [[ $GPU = *"Radeon"* ]]; then
    let OPT_COUNT+=1; let AMD_OPT=OPT_COUNT; echo "$AMD_OPT. Install AMD graphics driver."
  fi
  if [[ $GPU = *"VirtualBox"* ]]; then
    let OPT_COUNT+=1; let VB_OPT=OPT_COUNT; echo "$VB_OPT. Install VirtualBox Guest Additions."
  fi
  read -sn1 INPUT_OPTION
  #Execute selected action
  case "$INPUT_OPTION" in
    "$NVIDIA_OPT")
      echo "Trying to install NVIDIA graphics driver..."
      [[ $(uname -r) = *"lts"* ]] && pacman -S --noconfirm --noprogressbar --quiet nvidia-lts || pacman -S --noconfirm --noprogressbar --quiet nvidia
      ;;
    "$AMD_OPT") echo "Under development..."; echo "Press a button to continue..."; read -sn1;;
    "$VB_OPT") echo "Trying to install VirtualBox Guest Additions..."; pacman -S --noconfirm --noprogressbar --quiet virtualbox-guest-utils;;
    $'\e') break;;
  esac
done
