#!/bin/sh
clear

sh Functions.sh InstallAurman
if ! [[ $(sh Functions.sh _isInstalled "aurman") == 0 ]]; then
  echo "failed to install aurman"
fi

echo "Done!"

#Custom apps
#pacman -S --noconfirm konsole dolphin chromium atom sddm
#Apply services
#systemctl enable sddm.service

read -sn1
