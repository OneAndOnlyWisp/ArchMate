#!/bin/sh
#-------------------------------------------------------------------------------
src_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
#-------------------------------------------------------------------------------
# Install i3WM and dependencies ------------------------------------------------
pacman -S --noconfirm pulseaudio pulseaudio-alsa alsa-utils; # Audio
pacman -S --noconfirm xorg xorg-xinit; # Window system
pacman -S --noconfirm i3; # Window manager
#-------------------------------------------------------------------------------
# Timezone/Locals settings -----------------------------------------------------
timedatectl set-timezone Europe/Budapest; # Timezone
localectl --no-convert set-x11-keymap hu; # Set keyboard layout
#-------------------------------------------------------------------------------
# Basic system applications ----------------------------------------------------
pacman -S --noconfirm feh; # Background "service"/Image viewer
pacman -S --noconfirm dmenu; # Application launcher
pacman -S --noconfirm openssh; # SSH support
# Time based task scheduler ----------------------------------------------------
pacman -S --noconfirm cron; systemctl enable cronie.service;
#-------------------------------------------------------------------------------
# Fonts (To look atleast decent) -----------------------------------------------
pacman -S --noconfirm ttf-dejavu ttf-inconsolata;
#-------------------------------------------------------------------------------

# NetworkManager ---------------------------------------------------------------
pacman -S --noconfirm networkmanager; systemctl enable NetworkManager;
pacman -S --noconfirm network-manager-applet; # Tray icon
pacman -S --noconfirm networkmanager-openvpn; # VPN support
#-------------------------------------------------------------------------------
# Zero-configuration networking ------------------------------------------------
pacman -S --noconfirm avahi;
pacman -S --noconfirm nss-mdns; # Local hostname resolution
cp "$src_path/files/nsswitch" "/etc/nsswitch.conf";
systemctl enable avahi-daemon.service;
#-------------------------------------------------------------------------------
# Device mount protocols -------------------------------------------------------
pacman -S --noconfirm gvfs-afc gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-smb
#-------------------------------------------------------------------------------
# Remote desktop ---------------------------------------------------------------
pacman -S --noconfirm remmina libvncserver freerdp
#-------------------------------------------------------------------------------
