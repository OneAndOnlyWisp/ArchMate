#!/bin/bash
#-------------------------------------------------------------------------------
functions="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../../functions.sh"
#-------------------------------------------------------------------------------
#---------------------------------Default apps----------------------------------
#-------------------------------------------------------------------------------
pacman -S --noconfirm neofetch; #PC information
pacman -S --noconfirm htop; #Process manager
pacman -S --noconfirm rxvt-unicode urxvt-perls; #Terminal
pacman -S --noconfirm pavucontrol; #PulseAudio Volume controller
pacman -S --noconfirm scrot xclip; #Print screen tool/Copy to clipboard
pacman -S --noconfirm pcmanfm-gtk3; #File manager
pacman -S --noconfirm file-roller; #Archive manager
pacman -S --noconfirm chromium; #Browser
pacman -S --noconfirm atom; #Text editor
pacman -S --noconfirm transmission-qt; #Torrent
pacman -S --noconfirm vlc; #Video player
pacman -S --noconfirm bash-completion; #Super intelligent completion
pacman -S --noconfirm kvantum-qt5; #Window system theme manager
pacman -S --noconfirm udiskie; #USB Automount
pacman -S --noconfirm gparted; #Partition manager
pacman -S --noconfirm tigervnc; #VNC client
sh $functions InstallFromAUR "aurman"; #AUR package installer
#-------------------------------------------------------------------------------
# pacman -S --noconfirm xfce4-panel; # Only for the weak
#-------------------------------------------------------------------------------
#---------------------------Terminal/Shell extensions---------------------------
#Shell extension - Extract .7z files--------------------------------------------
pacman -S --noconfirm p7zip;
#Shell extension - Floating point division--------------------------------------
pacman -S --noconfirm bc;
#Terminal extension (Resize font on fly)----------------------------------------
sh $functions InstallFromAUR "urxvt-resize-font-git";
#Awesome 4 fonts ---------------------------------------------------------------
sh $functions InstallFromAUR "ttf-font-awesome-4";
#-------------------------------------------------------------------------------
