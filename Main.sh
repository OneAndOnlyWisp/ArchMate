#!/bin/sh

#Locals
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"
KERNEL=$Source_Path"Kernel.sh"
GRAPHICS=$Source_Path"Graphics.sh"
USER=$Source_Path"User.sh"
DESKTOP=$Source_Path"Desktop.sh"
CUSTOM=$Source_Path"Custom.sh"

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
  echo "2. Graphics"
  echo "3. User"
  echo "4. Desktop"
  if [[ -e $CUSTOM ]]; then
    echo "5. Run custom script"
  fi

  read -sn1 INPUT_OPTION

  case $INPUT_OPTION in
    '1') sh $KERNEL; clear; clear;; #sh $KERNEL CheckForReboot; (Removed for now)
    '2') sh $GRAPHICS; clear;;
    '3') sh $USER; clear;;
    '4') sh $DESKTOP; clear;;
    '5') [[ -e $CUSTOM ]] && sh $CUSTOM; clear;;
    $'\e') clear; break;;
  esac
done

#Revert changes to makepkg
cp ""$Source_Path"Assets/SysBU/makepkgBU" /usr/bin/makepkg
