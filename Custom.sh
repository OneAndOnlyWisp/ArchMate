#!/bin/sh
clear
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"

#Custom apps
pacman -S --noconfirm konsole dolphin chromium atom transmission-qt sddm
#Apply services
systemctl enable sddm.service

#Restart
reboot

echo "Done!"
read -sn1
