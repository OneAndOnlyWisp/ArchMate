#!/bin/sh

#Audio
if pacman -Qs pulseaudio pulseaudio-alsa > /dev/null ; then
  echo "The audio packages are installed"
fi
#Window system
if pacman -Qs xorg xorg-xinit > /dev/null ; then
  echo "The window system packages are installed"
fi

read -sn1
exit
while [ "$INPUT_OPTION" != "end" ]
do
  clear

done


#Desktop
#pacman -S --noconfirm plasma-desktop
#echo "exec startkde" > ~/.xinitrc
