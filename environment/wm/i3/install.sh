#!/bin/bash
#-------------------------------------------------------------------------------
functions="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../../functions.sh"
#-------------------------------------------------------------------------------
#------------------------ Install i3WM and dependencies ------------------------
#-------------------------------------------------------------------------------
pacman -S --noconfirm pulseaudio pulseaudio-alsa alsa-utils; # Audio
pacman -S --noconfirm xorg xorg-xinit; # Window system
pacman -S --noconfirm i3; # Window manager
# Replace default lock screen with fuzzy one
pacman -R --noconfirm i3lock; sh $functions InstallFromAUR i3lock-color;
#-------------------------------------------------------------------------------
#------------------------------- System settings -------------------------------
#-------------------------------------------------------------------------------
timedatectl set-timezone Europe/Budapest; # Set timezone
localectl --no-convert set-x11-keymap us; # Set keyboard layout
pacman -S --noconfirm ntp; systemctl enable ntpd.service; # Network Time Protocol
timedatectl set-ntp true; #Enable autosync with NTP
#--------------------------------- NumLock ON ----------------------------------
sh $functions InstallFromAUR "systemd-numlockontty";
systemctl enable numLockOnTty;
pacman -S --noconfirm numlockx;
#-------------------------------------------------------------------------------
#------------------------- Default system applications -------------------------
#-------------------------------------------------------------------------------
pacman -S --noconfirm feh; # Background "service"/Image viewer
pacman -S --noconfirm dmenu; # Application launcher
pacman -S --noconfirm openssh; # SSH support
pacman -S --noconfirm cron; systemctl enable cronie.service; # Task scheduler
pacman -S --noconfirm libvncserver freerdp; # Remote desktop protocols
#------------------------------- NetworkManager --------------------------------
pacman -S --noconfirm networkmanager; systemctl enable NetworkManager;
pacman -S --noconfirm network-manager-applet; # Tray icon
pacman -S --noconfirm networkmanager-openvpn; # VPN support
#------------------------ Zero-configuration networking ------------------------
pacman -S --noconfirm avahi; systemctl enable avahi-daemon.service;
pacman -S --noconfirm nss-mdns; # Local hostname resolution
#--------------------------- Device mount protocols ----------------------------
pacman -S --noconfirm gvfs-afc gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-smb
#-------------------------------------------------------------------------------
