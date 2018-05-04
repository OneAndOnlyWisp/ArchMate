#!/bin/sh
clear

sh Functions.sh InstallAURPackages pup-git
if ! [[ $(pacman -Qs aurman) = "" ]]; then
  sudo pacman -Rs --noconfirm aurman
fi
if ! [[ $(pacman -Qs pup-git) = "" ]]; then
  sudo pacman -Rs --noconfirm pup-git
fi

#Custom apps
#pacman -S --noconfirm konsole dolphin chromium atom transmission-qt sddm
#Apply services
#systemctl enable sddm.service

echo "Done!"
read -sn1

P5
P6
NetBurst
Pentium M
Prescott
Intel Core
Penryn
Nehalem
Bonnell
Westmere
Saltwell
Sandy Bridge
Ivy Bridge
