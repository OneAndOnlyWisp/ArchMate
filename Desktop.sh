#!/bin/sh
clear

#Init "Multimedia engine" (Audio + Window system)
#sh Functions.sh InstallPackages "pulseaudio" "pulseaudio-alsa" "xorg" "xorg-xinit"

function SetDefaults {
  #Available options
  Available=("Plasma" "Gnome" "Budgie" "Lumina (AUR)")
  echo "DEFAULT----------------------------------------"
  echo "Available:" ${Available[*]} "| Length:" ${#Available[@]}
  Packages=("plasma-desktop" "gnome" "budgie-desktop" "lumina-desktop")
  if ! [[ ${#Available[@]} = ${#Packages[@]} ]]; then
    echo "Error"
    exit
  fi
}

function GenerateMenuList {
  _temp_aval=()
  _temp_pack=()
  for ToDelete in ${Installed[@]}
  do
    for index in "${!Available[@]}"; do
      if [[ "${Available[$index]}" = "${ToDelete}" ]]; then
        unset 'Available[index]'
        unset 'Packages[index]'
      fi
    done
  done
  for i in "${!Available[@]}"; do
    _temp_aval+=("${Available[$i]}")
    _temp_pack+=("${Packages[$i]}")
  done
  Available=("${_temp_aval[@]}")
  Packages=("${_temp_pack[@]}")
  unset '_temp_aval'
  unset '_temp_pack'
}

function SearchForDesktops {
  #echo "-----------------------------------------------"
  for ThisPackage in ${!Packages[*]}; do
    #echo "Package: ${Packages[ThisPackage]} | Desktop: ${Available[ThisPackage]}"
    [[ $(sh Functions.sh _isInstalled "${Packages[ThisPackage]}") = 0 ]] && Installed+=("${Available[ThisPackage]}")
  done
  echo "Installed:" ${Installed[*]} "| Length:" ${#Installed[@]}
  echo "-----------------------------------------------"
}

#Menu
while [ "$INPUT_OPTION" != "end" ]
do
  Available=()
  Packages=()
  Installed=()
  SetDefaults
  SearchForDesktops
  #TEST
  Installed+=("${Available[2]}")
  GenerateMenuList
  echo "AFTER------------------------------------------"
  echo "Available:" ${Available[*]} "| Length:" ${#Available[@]}
  echo "Packages:" ${Packages[*]} "| Packages:" ${#Packages[@]}
  echo "-----------------------------------------------"
  #0 or 1 desktop
  if [[ ${#Installed[@]} = 0 ]] || [[ ${#Installed[@]} = 1 ]]; then
    if [[ ${#Installed[@]} = 0 ]]; then
      echo "No desktops installed on this system. (Press \"ESC\" to quit.)"
    else
      echo "${Installed[0]} desktop is already installed on this system. (Press \"ESC\" to quit.)"
    fi
    echo "Available desktops:"
    for ThisEntry in "${!Available[@]}"; do
      echo "$(($ThisEntry + 1)). Install ${Available[ThisEntry]} desktop environment."
    done
    #Menu options
    read -sn1 INPUT_OPTION
    case $INPUT_OPTION in
      '1') ! [[ "${Available[0]}" = *"(AUR)"* ]] && echo "Normal" || echo "AUR";; #sh Functions.sh InstallPackages ${Packages[0]} || sh Functions.sh InstallAURPackages ${Packages[0]}
      '2') ! [[ "${Available[1]}" = *"(AUR)"* ]] && echo "Normal" || echo "AUR";; #sh Functions.sh InstallPackages ${Packages[1]} || sh Functions.sh InstallAURPackages ${Packages[1]}
      '3') ! [[ "${Available[2]}" = *"(AUR)"* ]] && echo "Normal" || echo "AUR";; #sh Functions.sh InstallPackages ${Packages[2]} || sh Functions.sh InstallAURPackages ${Packages[2]}
      '4') ! [[ "${Available[3]}" = *"(AUR)"* ]] && echo "Normal" || echo "AUR";; #sh Functions.sh InstallPackages ${Packages[3]} || sh Functions.sh InstallAURPackages ${Packages[3]}
      $'\e') break;;
    esac
  #More than 1 desktops
  else
    echo "Multiple desktops are installed on this system. (Press \"ESC\" to quit.)"
    echo "Available desktops:"
    echo "1. Set default desktop."
    for ThisEntry in "${!Available[@]}"; do
      echo "$(($ThisEntry + 2)). Install ${Available[ThisEntry]} desktop environment."
    done
    #Menu options
    read -sn1 INPUT_OPTION
    case $INPUT_OPTION in
      '1') echo "Choose default desktop:";;
      '2') ! [[ "${Available[0]}" = *"(AUR)"* ]] && echo "Normal" || echo "AUR";; #sh Functions.sh InstallPackages ${Packages[0]} || sh Functions.sh InstallAURPackages ${Packages[0]}
      '3') ! [[ "${Available[1]}" = *"(AUR)"* ]] && echo "Normal" || echo "AUR";; #sh Functions.sh InstallPackages ${Packages[1]} || sh Functions.sh InstallAURPackages ${Packages[1]}
      '4') ! [[ "${Available[2]}" = *"(AUR)"* ]] && echo "Normal" || echo "AUR";; #sh Functions.sh InstallPackages ${Packages[2]} || sh Functions.sh InstallAURPackages ${Packages[2]}
      '5') ! [[ "${Available[3]}" = *"(AUR)"* ]] && echo "Normal" || echo "AUR";; #sh Functions.sh InstallPackages ${Packages[3]} || sh Functions.sh InstallAURPackages ${Packages[3]}
      $'\e') break;;
    esac
  fi
read -sn1
clear
done


#Desktop
#pacman -S --noconfirm plasma-desktop
#echo "exec startkde" > ~/.xinitrc
