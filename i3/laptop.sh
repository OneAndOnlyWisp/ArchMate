#!/bin/sh
clear;

# Special time settings for laptops
pacman -S --noconfirm ntp; #Install Network Time Protocol package
systemctl enable ntpd.service; #Enable NTP service
timedatectl set-ntp true; #Enable autosync with NTP

# Wifi connection managment
pacman -S --noconfirm iwd; #Install Internet Wireless Daemon
systemctl enable iwd.service; #Enable IWD service
