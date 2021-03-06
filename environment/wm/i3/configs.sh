#!/bin/bash
clear;
# Paths ------------------------------------------------------------------------
_SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
_SYSTEM_DIR="$_SOURCE_DIR/files/system";
_USER_DIR="$_SOURCE_DIR/files/user";
_CUSTOM_DIR="$_SOURCE_DIR/files/custom";
#-------------------------------------------------------------------------------
#---------------------------- System configuration -----------------------------
#-------------------------------------------------------------------------------
# Cron jobs
crontab "$_SYSTEM_DIR/cron";
# Local domain resolve
cp "$_SYSTEM_DIR/nsswitch.conf" /etc/nsswitch.conf;
# SSH config
cp "$_SYSTEM_DIR/sshd_config" /etc/ssh/sshd_config; systemctl enable sshd.service;
# Copy info for root
cp "$_SYSTEM_DIR/root_help" /root/root.readme;
#-------------------------------------------------------------------------------
#-------------------------- Copy default user configs --------------------------
#-------------------------------------------------------------------------------
sed -n '/\/bin\/bash/p' /etc/passwd | cut -d: -f1 | while read -r _USER; do
  # Set home folder location
  [[ $_USER = "root" ]] && _USER_HOME_DIR="/root" || _USER_HOME_DIR="/home/$_USER"
  # Copy config files
  cp -r "$_USER_DIR/." "$_USER_HOME_DIR/";
  # Fix blocklets permissions
  find "$_USER_HOME_DIR/.blocklets" -type f -exec chmod 700 {} \;
  # Create default bash_profile for root and fix ownership for non-root users
  [[ $_USER = "root" ]] && echo "[[ -f ~/.bashrc ]] && . ~/.bashrc" > "$_USER_HOME_DIR/.bash_profile" || chown -R $_USER:users "$_USER_HOME_DIR/"; #
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
