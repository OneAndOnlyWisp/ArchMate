#!/bin/sh
clear

sh Functions.sh IntelCodename

echo "Done!"

#Custom apps
#pacman -S --noconfirm konsole dolphin chromium atom sddm
#Apply services
#systemctl enable sddm.service

read -sn1
