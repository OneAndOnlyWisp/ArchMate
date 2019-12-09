#!/bin/bash
#-------------------------------------------------------------------------------
functions="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../../functions.sh"
#-------------------------------------------------------------------------------
#---------------------------------Default apps----------------------------------
#-------------------------------------------------------------------------------
pacman -S --noconfirm ttf-dejavu ttf-inconsolata; # Default fonts
pacman -S --noconfirm p7zip; # Extract .7z files
pacman -S --noconfirm bc; # Floating point division (shell)
pacman -S --noconfirm neofetch; # PC information
pacman -S --noconfirm htop; # Process manager
pacman -S --noconfirm rxvt-unicode urxvt-perls; # Terminal
pacman -S --noconfirm pavucontrol; # PulseAudio Volume controller
pacman -S --noconfirm scrot xclip; # Print screen tool/Copy to clipboard
pacman -S --noconfirm pcmanfm-gtk3; # File manager
pacman -S --noconfirm file-roller; # Archive manager
pacman -S --noconfirm chromium; # Browser
pacman -S --noconfirm atom; # Text editor
pacman -S --noconfirm transmission-cli; # Torrent daemon
pacman -S --noconfirm vlc; # Video player
pacman -S --noconfirm bash-completion; #S uper intelligent completion
pacman -S --noconfirm kvantum-qt5; # Window system theme manager
pacman -S --noconfirm udiskie; # USB Automount
pacman -S --noconfirm gparted; #P artition manager with GUI
pacman -S --noconfirm remmina libvncserver freerdp; # VNC client
pacman -S --noconfirm tigervnc; # VNC server for separate workspace
pacman -S --noconfirm x11vnc; # VNC server to share workspace
pacman -S --noconfirm wireguard-tools wireguard-lts; # Private network protocol
sh $functions InstallFromAUR "yay"; # AUR package manager
sh $functions InstallFromAUR "urxvt-resize-font-git"; # Resize font on fly
sh $functions InstallFromAUR "ttf-font-awesome-4"; # Awesome 4 fonts
sh $functions InstallFromAUR "ttf-font-logos"; # Arch linux logo
#-------------------------------------------------------------------------------
# pacman -S --noconfirm xfce4-panel; # Only for the weak
#-------------------------------------------------------------------------------
