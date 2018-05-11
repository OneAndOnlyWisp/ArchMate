#!/bin/sh
clear
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"

echo "Before calling Kernel_v2.sh"
sh ""$Source_Path"Kernel_v2.sh"
echo "After calling Kernel_v2.sh"

read -sn1
exit

#Custom apps
pacman -S --noconfirm konsole dolphin chromium atom transmission-qt sddm
#Apply services
systemctl enable sddm.service

#Revert changes to makepkg
cp ""$Source_Path"Assets/SysBU/makepkgBU" /usr/bin/makepkg

#Restart
reboot

echo "Done!"
read -sn1
