#!/bin/sh
clear
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"


#Custom apps
#pacman -S --noconfirm konsole dolphin chromium atom transmission-qt sddm
#Apply services
#systemctl enable sddm.service

echo "Done!"
read -sn1


sh ArchMate/Functions.sh InstallPackages xf86-video-ati-lts
