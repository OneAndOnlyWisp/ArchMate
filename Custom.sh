#!/bin/sh
clear
#Local globals------------------------------------------------------------------
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"
#-------------------------------------------------------------------------------
#Wine install elements----------------------------------------------------------
function GenerateLocale {
  StartingLine=$(sed -n '/#en_US\.UTF-8 UTF-8/=' /etc/locale.gen)
  if ! [[ "$StartingLine" = "" ]]; then
    sed -ie ""$StartingLine"s/#//g" /etc/locale.gen
    locale-gen
  fi
}

function InstallFonts {
  sh ""$Source_Path"Functions.sh" InstallPackages "ttf-liberation";
  sh ""$Source_Path"Functions.sh" InstallPackages "wqy-zenhei";
}

function InstallSteam {
  GenerateLocale
  InstallFonts
}

function InstallWINE {
  echo "WINE"
}
#-------------------------------------------------------------------------------

#wget "https://steamcdn-a.akamaihd.net/client/installer/SteamSetup.exe"

read -sn1
exit

#Custom apps
pacman -S --noconfirm konsole dolphin chromium atom transmission-qt sddm
#Apply services
systemctl enable sddm.service

#Set window system keyboard layout
localectl set-x11-keymap hu

#Revert changes to makepkg
cp ""$Source_Path"Assets/SysBU/makepkgBU" /usr/bin/makepkg

#Restart
reboot

echo "Done!"
read -sn1
