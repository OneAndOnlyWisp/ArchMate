#!/bin/sh
clear

sh Functions.sh InstallPackages agg aide
pacman -Rs agg aide

#Custom apps
#pacman -S --noconfirm konsole dolphin chromium atom sddm
#Apply services
#systemctl enable sddm.service

echo "Done!"
read -sn1
