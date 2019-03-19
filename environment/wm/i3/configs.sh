#!/bin/bash
clear;
# Paths ------------------------------------------------------------------------
_SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
_SYSTEM_DIR="$_SOURCE/files/system";
_USER_DIR="$_SOURCE/files/user";
_CUSTOM_DIR="$_SOURCE/files/custom";
#-------------------------------------------------------------------------------
#---------------------------- System configuration -----------------------------
#-------------------------------------------------------------------------------
# Cron jobs for root
crontab "$_SYSTEM_DIR/cron";
# Terminal identity
cp "$_SYSTEM_DIR/nsswitch.conf" /etc/nsswitch.conf;
# Terminal identity
cp "$_SYSTEM_DIR/terminal.sh" /etc/profile.d/terminal.sh;
# Copy help for root
cp "$_SYSTEM_DIR/root_help" /root/root.readme;
#-------------------------------------------------------------------------------
#-------------------------- Copy default user configs --------------------------
#-------------------------------------------------------------------------------
sed -n '/\/bin\/bash/p' /etc/passwd | cut -d: -f1 | while read -r _USER; do
  # Set home folder location
  [[ $_USER = "root" ]] && _USER_HOME_DIR="/root" || _USER_HOME_DIR="/home/$_USER"
  # Copy config files
  cp -r "$_USER_DIR/*" "$_USER_HOME_DIR/";
  # Fix blocklets permissions
  find "$_USER_HOME_DIR/.blocklets" -type f -exec chmod 755 {} \;
  # Fix ownership
  [[ $_USER -ne "root" ]] && chown -R $_USER:users "$_USER_HOME_DIR/"
done
#-------------------------------------------------------------------------------
#---------------------------- Custom configuration -----------------------------
#-------------------------------------------------------------------------------
# Xorg driver settings
cp "$_CUSTOM_DIR/graphics" /etc/X11/xorg.conf.d/00-driver.conf;
# Ethernet killer
cp "$_CUSTOM_DIR/disable_usb_port.sh" /etc/NetworkManager/dispatcher.d/disable_usb_port.sh;
# Copy a default wallpaper
cp "$_CUSTOM_DIR/wallpaper.png" /wallpaper.png;
# Turn off beep sounds (Blacklist kernel module)
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf;
#-------------------------------------------------------------------------------
