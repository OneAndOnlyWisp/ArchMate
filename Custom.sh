#!/bin/sh
clear

sh Functions.sh InstallAurman
if [[ $(sh Functions.sh _isInstalled "aurman") == 0 ]]; then
  sh Functions.sh InstallAURPackages "pup-git"
  sh Functions.sh IntelCodename
else
  echo "failed to install aurman"
fi

echo "Done!"

#Custom apps
#pacman -S --noconfirm konsole dolphin chromium atom sddm
#Apply services
#systemctl enable sddm.service

read -sn1



case $INPUT_OPTION in
  '1')
    if ! [[ "${Available[0]}" = *"(AUR)"* ]]; then
      echo "Normal"
      #sh Functions.sh InstallPackages ${Packages[0]}
    else
      echo "AUR"
      #sh Functions.sh InstallAURPackages ${Packages[0]}
    fi;;
  '2')
    if ! [[ "${Available[1]}" = *"(AUR)"* ]]; then
      echo "Normal"
      #sh Functions.sh InstallPackages ${Packages[1]}
    else
      echo "AUR"
      #sh Functions.sh InstallAURPackages ${Packages[1]}
    fi;;
  '3') ! [[ "${Available[2]}" = *"(AUR)"* ]] && echo "Normal" || echo "AUR";; #sh Functions.sh InstallPackages ${Packages[2]} || sh Functions.sh InstallAURPackages ${Packages[2]}
  '4') ! [[ "${Available[3]}" = *"(AUR)"* ]] && echo "Normal" || echo "AUR";; #sh Functions.sh InstallPackages ${Packages[3]} || sh Functions.sh InstallAURPackages ${Packages[3]}
  $'\e') break;;
esac
