#!/bin/bash
clear;
#Local globals------------------------------------------------------------------
functions="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../../functions.sh"
src_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
#-------------------------------------------------------------------------------
#------------------------------Stuff for everyone-------------------------------
#Terminal identity -------------------------------------------------------------
terminal="/etc/profile.d/terminal.sh"; touch $terminal;
echo "declare -x TERM=\"xterm-256color\"" | sudo tee $terminal > /dev/null;
echo "declare -x EDITOR=\"/usr/bin/nano\"" | sudo tee $terminal > /dev/null;
#Xorg driver settings-----------------------------------------------------------
cp "$src_path/files/graphics" /etc/X11/xorg.conf.d/00-driver.conf;
#Copy a default wallpaper-------------------------------------------------------
cp "$src_path/files/wallpaper.png" /wallpaper.png;
#Cron jobs for root-------------------------------------------------------------
crontab "$src_path/files/cron";
#-------------------------------------------------------------------------------
#Needed for Arch linux logo-----------------------------------------------------
sh $functions InstallFromAUR "ttf-font-logos";
#Needed for atom cpp-linter plugin----------------------------------------------
sh $functions InstallFromAUR "cpplint";
#-------------------------------------------------------------------------------
#--------------------------Copy settings for all users--------------------------
#-------------------------------------------------------------------------------
sed -n '/\/bin\/bash/p' /etc/passwd | cut -d: -f1 | while read -r username; do
  # Set home_folder location----------------------------------------------------
  [[ $username = "root" ]] && home_folder="/root" || home_folder="/home/$username"
  # Common ---------------------------------------------------------------------
  cp "$src_path/files/resource" "$home_folder/.config/i3/.Xresources";
  cp "$src_path/files/background" "$home_folder/.fehbg";
  cp "$src_path/files/bashrc" "$home_folder/.bashrc";
  cp "$src_path/files/bash_profile" "$home_folder/.bash_profile";
  cp "$src_path/files/xinitrc" "$home_folder/.xinitrc";
  # Window Manager -------------------------------------------------------------
  mkdir -p "$home_folder/.config/i3/"; touch "$home_folder/.config/i3/config";
  cp "$src_path/files/config" "$home_folder/.config/i3/config";
  cp "$src_path/files/i3blocks" "$home_folder/.i3blocks.conf";
  cp -r "$src_path/files/blocklets/." "$home_folder/.blocklets";
  # Fix permissions
  find "$home_folder/.blocklets" -type f -exec chmod 755 {} \;
  # Fix ownership---------------------------------------------------------------
  [[ $username -ne "root" ]] && chown -R $username:users "$home_folder/"
  # Atom plugins ---------------------------------------------------------------
  if [[ $username -ne "root" ]]; then
    runuser -l $username -c 'apm install goto-definition';
    runuser -l $username -c 'apm install linter';
    runuser -l $username -c 'apm install linter-ui-default';
    runuser -l $username -c 'apm install linter-gcc';
    runuser -l $username -c 'apm install language-cpp14';
    runuser -l $username -c 'apm install clang-format';
    runuser -l $username -c 'apm install language-cmake';
    runuser -l $username -c 'apm install autocomplete-cmake';
    runuser -l $username -c 'apm install output-panel';
    runuser -l $username -c 'apm install intentions busy-signal';
  fi
done
#-------------------------------------------------------------------------------
#------------------------------Copy help for root-------------------------------
cp "$src_path/files/root_help" "/root/root.readme";
#-------------------------------------------------------------------------------
