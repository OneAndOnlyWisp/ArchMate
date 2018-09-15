#!/bin/sh
clear;
#Local globals------------------------------------------------------------------
functions="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../../functions.sh"
src_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
#-------------------------------------------------------------------------------
#------------------------------Stuff for everyone-------------------------------
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
sed -n '/\/bin\/bash/p' /etc/passwd | cut -d: -f1 | while read -r username; do
  #Set home_folder location-----------------------------------------------------
  [[ $username = "root" ]] && home_folder="/root" || home_folder="/home/$username"
  #Start i3 with startx---------------------------------------------------------
  echo "exec i3" > "$home_folder/.xinitrc";
  #Copy i3 files----------------------------------------------------------------
  mkdir -p "$home_folder/.config/i3/"; touch "$home_folder/.config/i3/config";
  cp "$src_path/files/config" "$home_folder/.config/i3/config"; #i3
  cp "$src_path/files/i3blocks" "$home_folder/.i3blocks.conf"; #i3blocks
  cp -r "$src_path/files/blocklets/." "$home_folder/.blocklets"; #i3 blocklets
  find "$home_folder/.blocklets" -type f -exec chmod 755 {} \; #Fix permissions
  #Xorg display settings--------------------------------------------------------
  cp "$src_path/files/resource" "$home_folder/.config/i3/.Xresources";
  #Set background script--------------------------------------------------------
  touch "$home_folder/.fehbg";
  cp "$src_path/files/background" "$home_folder/.fehbg";
  #-----------------------------------------------------------------------------
  if ! [[ $username = "root" ]]; then
    #Fix ownership--------------------------------------------------------------
    chown -R $username:users "$home_folder/"
    #---------------------------------------------------------------------------
    #-------------------------------Atom extensions-----------------------------
    #Atom Discord plugin--------------------------------------------------------
    runuser -l $username -c 'apm install atom-discord';
    #Atom GoTo Definition plugin------------------------------------------------
    runuser -l $username -c 'apm install goto-definition';
    #Atom linter----------------------------------------------------------------
    runuser -l $username -c 'apm install linter';
    #Linter Atom-UI-------------------------------------------------------------
    runuser -l $username -c 'apm install linter-ui-default';
    #Atom C++ linter------------------------------------------------------------
    runuser -l $username -c 'apm install linter-cpplint';
    #Reformat C/C++ code--------------------------------------------------------
    runuser -l $username -c 'apm install clang-format';
    #Atom CMake language--------------------------------------------------------
    runuser -l $username -c 'apm install language-cmake';
    #Atom CMake autocomplete----------------------------------------------------
    runuser -l $username -c 'apm install autocomplete-cmake';
    #Atom random stuff----------------------------------------------------------
    runuser -l $username -c 'apm install intentions busy-signal';
    #---------------------------------------------------------------------------
  fi
done
#-------------------------------------------------------------------------------
#Copy help for root-------------------------------------------------------------
cp "$src_path/files/root_help" "/root/root.readme";
#-------------------------------------------------------------------------------
