#!/bin/bash
#-------------------------------------------------------------------------------
#Locals-------------------------------------------------------------------------
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
KERNEL="$Source_Path/kernel/main.sh"
GRAPHIC="$Source_Path/graphics/main.sh"
USER="$Source_Path/users/main.sh"
ENV="$Source_Path/environment/main.sh"
DEV="$Source_Path/developer/main.sh"
VM="$Source_Path/passthrough/setup.sh"
#-------------------------------------------------------------------------------
#Functions----------------------------------------------------------------------
function MakePKG_Patch {
  pacman -Sy --needed --noconfirm base-devel; #Install base-devel for makepkg usage
  #Allow makepkg to run as root
  if ! [[ $(cat /usr/bin/makepkg | grep -o 'asroot') ]]; then
    cp /usr/bin/makepkg "$Source_Path/.patches/makepkg_BU"
    cp "$Source_Path/.patches/makepkg" /usr/bin/makepkg
    if [[ $(cat /usr/bin/makepkg | grep -o 'asroot') ]]; then
      echo "MakePKG patch succes!"
    fi
  fi
}

function Revert_MakePKG {
  mv "$Source_Path/.patches/makepkg_BU" /usr/bin/makepkg
}
#-------------------------------------------------------------------------------
#Allow makepkg to run as root
MakePKG_Patch
#Main loop----------------------------------------------------------------------
while [ "$INPUT_OPTION" != "end" ]; do
  clear
  echo "Please type the number of selected task! (Press \"ESC\" to quit.)"
  echo "1. Kernel"
  echo "2. Graphics"
  echo "3. User"
  echo "4. Graphical User Environment"
  echo "5. Virtualization with passthrough"
  echo "6. Developer packages"
  read -sn1 INPUT_OPTION
  case $INPUT_OPTION in
    '1') sh $KERNEL; clear;;
    '2') sh $GRAPHIC; clear;;
    '3') sh $USER; clear;;
    '4') sh $ENV; clear;;
    '5') sh $VM; clear;;
    '6') sh $DEV; clear;;
    $'\e') clear; break;;
  esac
done
#-------------------------------------------------------------------------------
#Revert changes to makepkg
Revert_MakePKG
#-------------------------------------------------------------------------------
