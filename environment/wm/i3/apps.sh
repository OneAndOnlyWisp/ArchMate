#!/bin/sh
#-------------------------------------------------------------------------------
functions="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../../functions.sh"
#-------------------------------------------------------------------------------
#---------------------------------Default apps----------------------------------
pacman -S --noconfirm neofetch; #PC information
pacman -S --noconfirm htop; #Process manager
pacman -S --noconfirm rxvt-unicode urxvt-perls; #Terminal
pacman -S --noconfirm pavucontrol; #PulseAudio Volume controller
pacman -S --noconfirm scrot xclip; #Print screen tool/Copy to clipboard
pacman -S --noconfirm pcmanfm; #File manager
pacman -S --noconfirm file-roller; #Archive manager
pacman -S --noconfirm chromium; #Browser
pacman -S --noconfirm atom; #Text editor
pacman -S --noconfirm transmission-qt; #Torrent
pacman -S --noconfirm vlc; #Video player
pacman -S --noconfirm openssh; #SSH connection
pacman -S --noconfirm bash-completion; #Super intelligent completion
sh $functions InstallFromAUR "aurman"; #AUR package installer
#-------------------------------------------------------------------------------
#---------------------------Terminal/Shell extensions---------------------------
#Shell extension - Extract .7z files--------------------------------------------
pacman -S --noconfirm p7zip;
#Shell extension - Floating point division--------------------------------------
pacman -S --noconfirm bc;
#Terminal extension (Resize font on fly)----------------------------------------
sh $functions InstallFromAUR "urxvt-resize-font-git";
#Awesome fonts for terminal use-------------------------------------------------
sh $functions InstallFromAUR "ttf-font-awesome-4";
#-------------------------------------------------------------------------------
