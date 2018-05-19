#!/bin/sh
clear
#Local globals------------------------------------------------------------------
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"
#-------------------------------------------------------------------------------
#AUR package manager
sh ""$Source_Path"Functions.sh" InstallPackages "aurman";

#PC information
pacman -S --noconfirm neofetch
#Terminal screensaver
pacman -S --noconfirm cmatrix

#Display manager service
pacman -S --noconfirm sddm;
systemctl enable sddm.service;
#Network manager service
pacman -S --noconfirm networkmanager;
systemctl enable NetworkManager.service;

#SDDM autologin
echo "[Autologin]
User=wisp
Session=plasma.desktop" > /etc/sddm.conf.d/autologin.conf;

#Set window system keyboard layout
localectl set-x11-keymap hu;

#Sys tool
pacman -S --noconfirm ksysguard; #Process manager
pacman -S --noconfirm partitionmanager; #KDE partition manager
pacman -S --noconfirm plasma-nm; #Network manager app

#Life savers
pacman -S --noconfirm powerdevil; #Power management system tool
pacman -S --noconfirm plasma-pa; #Volume adjustment app
pacman -S --noconfirm spectacle; #Print screen tool

#Default apps
pacman -S --noconfirm gwenview; #Image viewer
pacman -S --noconfirm konsole; #Terminal
pacman -S --noconfirm dolphin; #File manager
pacman -S --noconfirm atom; #Text editor
pacman -S --noconfirm transmission-qt; #Torrent
pacman -S --noconfirm ark unrar; #Archive manager
pacman -S --noconfirm kodi; #Cloud/Local Audio/Video player

#Browser
pacman -S --noconfirm chromium;
echo "--password-store=basic" >> ~/.config/chromium-flags.conf

#Revert changes to makepkg
cp ""$Source_Path"Assets/SysBU/makepkgBU" /usr/bin/makepkg

#Display settings
cp ""$Source_Path"Personal/20-nvidia.conf" /etc/X11/xorg.conf.d/20-nvidia.conf

#Restart
reboot

echo "Done!"
read -sn1
