#!/bin/sh
clear;
src_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

# Special time settings for laptops
pacman -S --noconfirm ntp; #Install Network Time Protocol package
systemctl enable ntpd.service; #Enable NTP service
timedatectl set-ntp true; #Enable autosync with NTP

# Wifi connection managment
pacman -S --noconfirm iwd; #Install Internet Wireless Daemon
systemctl enable iwd.service; #Enable IWD service

# Copy readme for wifi useage
sed -n '/\/bin\/bash/p' /etc/passwd | cut -d: -f1 | while read -r username; do
  #Set home_folder location-----------------------------------------------------
  [[ $username = "root" ]] && home_folder="/root" || home_folder="/home/$username"
  cp "$src_path/files/wifi" "$home_folder/wifi.readme";
  #Fix ownership
  chown $username:users "$home_folder/wifi.readme"
done
