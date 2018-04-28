#!/bin/sh
clear

#Init "Multimedia engine" (Audio + Window system)
sh Functions.sh InstallPackages "pulseaudio" "pulseaudio-alsa" "xorg" "xorg-xinit"

#Available options
Available=("Plasma" "Gnome" "Budgie" "Lumina (AUR)")

echo "DEFAULT----------------------------------------"
echo "Available:" ${Available[*]} "| Length:" ${#Available[@]}
echo "Installed:" ${Installed[*]} "| Length:" ${#Installed[@]}
echo "-----------------------------------------------"

#Menu
while [ "$INPUT_OPTION" != "end" ]
do
  #Installed desktops
  Installed=()
  #[[ $(sh Functions.sh _isInstalled "plasma-desktop") = 0 ]] && Installed+=("Plasma")
  [[ $(sh Functions.sh _isInstalled "budgie-desktop") = 0 ]] && Installed+=("Budgie")
  #Test line
  #[[ $(sh Functions.sh _isInstalled "plasma-desktop") = 0 ]] && Installed+=("Budgie")
  #Create menu
  Result=()
  for ToDelete in ${Installed[@]}
  do
     Available=("${Available[@]/$ToDelete}")
  done
  for MenuEntry in "${!Available[@]}"; do
    if ! [[ "${Available[MenuEntry]}" = "" ]]; then
      Result+=("${Available[MenuEntry]}")
    fi
  done
  echo "RESULT-----------------------------------------"
  echo "Result:" ${Result[*]} "| Length:" ${#Result[@]}
  echo "-----------------------------------------------"
  read -sn1
  clear
  #0 or 1 desktop
  if [[ ${#Installed[@]} = 0 ]] || [[ $((${#Available[@]} - ${#Result[@]})) = 1 ]]; then
    if ! [[ $((${#Available[@]} - ${#Result[@]})) = 1 ]]; then
      echo "No desktops installed on this system. (Press \"ESC\" to quit.)"
    else
      echo "${Installed[0]} desktop is already installed on this system. (Press \"ESC\" to quit.)"
    fi
    echo "Available desktops:"
    for MenuEntry in "${!Result[@]}"; do
      echo "$(($MenuEntry + 1)). Install ${Result[MenuEntry]} desktop environment."
    done
    #Menu options
    read -sn1 INPUT_OPTION
    case $INPUT_OPTION in
      '1') echo "Installing ${Result[0]}";;
      '2') echo "Installing ${Result[1]}";;
      '3') echo "Installing ${Result[2]}";;
      '4') echo "Installing ${Result[3]}";;
      $'\e') break;;
    esac
  #More than 1 desktops
  else
    echo "Multiple desktops are installed on this system. (Press \"ESC\" to quit.)"
    echo "Available desktops:"
    echo "1. Set default desktop."
    for MenuEntry in "${!Result[@]}"; do
      echo "$(($MenuEntry + 2)). Install ${Result[MenuEntry]} desktop environment."
    done
  fi
done


#Desktop
#pacman -S --noconfirm plasma-desktop
#echo "exec startkde" > ~/.xinitrc
