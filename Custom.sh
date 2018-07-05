#!/bin/sh
clear
#Local globals------------------------------------------------------------------
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"
#-------------------------------------------------------------------------------

function Plasma {

  #AUR package manager
  sh ""$Source_Path"Functions.sh" InstallFromAUR "aurman";

  #Fonts
  pacman -S --noconfirm ttf-liberation; #Most popular fonts
  #pacman -S --noconfirm wqy-zenhei; #Chinese Outline Font (Most likely not needed)

  #PC information
  pacman -S --noconfirm neofetch
  #Terminal screensaver
  pacman -S --noconfirm cmatrix

  #Set keyboard layouts
  localectl --no-convert set-keymap hu;
  localectl --no-convert set-x11-keymap hu;

  #Display manager service
  pacman -S --noconfirm sddm;
  systemctl enable sddm.service;
  #SDDM autologin
  echo "[Autologin]
  User=wisp
  Session=plasma.desktop" > /etc/sddm.conf.d/autologin.conf;

  #Network manager service
  pacman -S --noconfirm networkmanager;
  systemctl enable NetworkManager.service;

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
  #Virtualization
  pacman -S --noconfirm qemu libvirt ovmf #Must have
  pacman -S --noconfirm virt-manager #Virtual machine manager with GUI

  #Display settings
  cp ""$Source_Path"Personal/20-intel.conf" /etc/X11/xorg.conf.d/20-intel.conf

}

DesktopSessions=("plasma-desktop" "xfdesktop" "gnome-shell" "budgie-desktop")
for index in ${!DesktopSessions[*]}; do
  [[ $(sh ""$Source_Path"Functions.sh" _isInstalled "${DesktopSessions[index]}") = 0 ]] && Installed=$index;
done

case $Installed in
  '0' ) Plasma;;
esac
