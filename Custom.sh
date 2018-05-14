#!/bin/sh
clear
#Local globals------------------------------------------------------------------
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"
#-------------------------------------------------------------------------------
#AUR package manager
sh ""$Source_Path"Functions.sh" InstallPackages "aurman"

#Must have
pacman -S --noconfirm plasma-pa; #Volume adjustment app
pacman -S --noconfirm spectacle; #Print screen tool
pacman -S --noconfirm gwenview; #Image viewer
#Custom apps
pacman -S --noconfirm konsole; #Terminal
pacman -S --noconfirm dolphin; #File manager
pacman -S --noconfirm chromium; #Browser
pacman -S --noconfirm atom; #Text editor
pacman -S --noconfirm transmission-qt; #Torrent
pacman -S --noconfirm ark unrar; #Archive manager

#Display manager service
pacman -S --noconfirm sddm
systemctl enable sddm.service

#SDDM autologin
echo "[Autologin]
User=wisp
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
