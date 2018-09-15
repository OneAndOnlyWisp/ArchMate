#!/bin/sh
#-------------------------------------------------------------------------------
#Install i3WM and dependencies--------------------------------------------------
pacman -S --noconfirm pulseaudio pulseaudio-alsa alsa-utils; #Audio
pacman -S --noconfirm xorg xorg-xinit; #Window system
pacman -S --noconfirm i3; #Window manager
#-------------------------------------------------------------------------------
#Timezone/Locals settings-------------------------------------------------------
timedatectl set-timezone Europe/Budapest; #Timezone
localectl --no-convert set-x11-keymap hu; #Set keyboard layout
#-------------------------------------------------------------------------------
#Basic system applications------------------------------------------------------
pacman -S --noconfirm feh; #Background handler
pacman -S --noconfirm dmenu; #Application launcher
#Time based task scheduler------------------------------------------------------
pacman -S --noconfirm cron; systemctl enable cronie.service;
#-------------------------------------------------------------------------------
#Fonts (To look atleast decent)-------------------------------------------------
pacman -S --noconfirm ttf-dejavu ttf-inconsolata ttf-font-awesome;
#-------------------------------------------------------------------------------
