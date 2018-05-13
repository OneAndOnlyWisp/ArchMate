#!/bin/sh
clear
#Local globals------------------------------------------------------------------
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"
#-------------------------------------------------------------------------------
#AUR package manager
sh ""$Source_Path"Functions.sh" InstallPackages "aurman"

#Custom apps
pacman -S --noconfirm konsole dolphin chromium atom transmission-qt sddm
#Apply services
systemctl enable sddm.service

#SDDM autologin
echo "[Autologin]
User=john
Session=plasma.desktop" > /etc/sddm.conf.d/autologin.conf

#Set window system keyboard layout
localectl set-x11-keymap hu

#Revert changes to makepkg
cp ""$Source_Path"Assets/SysBU/makepkgBU" /usr/bin/makepkg

#Display settings
cp ""$Source_Path"Personal/20-nvidia.conf" /etc/X11/xorg.conf.d/20-nvidia.conf

#Restart
reboot

echo "Done!"
read -sn1
