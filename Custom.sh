#!/bin/sh
clear
#Local globals------------------------------------------------------------------
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"
#-------------------------------------------------------------------------------

#Fonts
pacman -S --noconfirm ttf-liberation; #Most popular fonts
#pacman -S --noconfirm wqy-zenhei; #Chinese Outline Font (Most likely not needed)

#AUR package manager
sh ""$Source_Path"Functions.sh" InstallFromAUR "aurman";

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

#Set keyboard layouts
localectl --no-convert set-keymap hu;
localectl --no-convert set-x11-keymap hu;

#Sys tool
pacman -S --noconfirm htop; #Process manage
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
pacman -S --noconfirm kodi; #Multimedia GOD

#Browser
pacman -S --noconfirm chromium;
echo "--password-store=basic" >> ~/.config/chromium-flags.conf

#Display settings
cp ""$Source_Path"Personal/20-intel.conf" /etc/X11/xorg.conf.d/20-intel.conf

#Virtualization
pacman -S --noconfirm qemu libvirt ovmf #Must have
pacman -S --noconfirm virt-manager #Virtual machine manager with GUI
