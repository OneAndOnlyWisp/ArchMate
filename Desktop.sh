#!/bin/sh

#Init "Multimedia engine" (Audio + Window system)
sh Functions.sh InstallPackages "pulseaudio" "pulseaudio-alsa" "xorg" "xorg-xinit"

function SetDefaultLists {
  #Available options
  Available=("Plasma" "Gnome" "Budgie" "Lumina (AUR)")
  #echo "DEFAULT----------------------------------------"
  #echo "Available:" ${Available[*]} "| Length:" ${#Available[@]}
  Packages=("plasma-desktop" "gnome" "budgie-desktop" "lumina-desktop")
  AutostartScripts=("startkde" "gnome-session" "budgie-desktop" "start-lumina-desktop")
  if ! [[ ${#Available[@]} = ${#Packages[@]} ]]; then
    echo "Error"
    exit
  fi
}

function SearchForInstalled {
  #echo "-----------------------------------------------"
  for ThisPackage in ${!Packages[*]}; do
    #echo "Package: ${Packages[ThisPackage]} | Desktop: ${Available[ThisPackage]}"
    [[ $(sh Functions.sh _isInstalled "${Packages[ThisPackage]}") = 0 ]] && Installed+=("${Available[ThisPackage]}")
  done
  #echo "Installed:" ${Installed[*]} "| Length:" ${#Installed[@]}
  #echo "-----------------------------------------------"
}

function GenerateMenuList {
  _temp_aval=()
  _temp_pack=()
  _temp_exec=()
  for ToDelete in ${Installed[@]}
  do
    for index in "${!Available[@]}"; do
      if [[ "${Available[$index]}" = "${ToDelete}" ]]; then
        unset 'Available[index]'
        unset 'Packages[index]'
        unset 'AutostartScripts[index]'
      fi
    done
  done
  for i in "${!Available[@]}"; do
    _temp_aval+=("${Available[$i]}")
    _temp_pack+=("${Packages[$i]}")
    _temp_exec+=("${AutostartScripts[$i]}")
  done
  Available=("${_temp_aval[@]}")
  Packages=("${_temp_pack[@]}")
  AutostartScripts=("${_temp_exec[@]}")
  unset '_temp_aval'
  unset '_temp_pack'
  unset '_temp_exec'
}

function SetAsDefault {
  FindMe=$1
  for index in "${!Available[@]}"; do
    if [[ "${Available[$index]}" = "$FindMe" ]]; then
      echo "exec ${AutostartScripts[$nemtom]}" > ~/.xinitrc
    fi
  done
}

#Menu
while [ "$INPUT_OPTION" != "end" ]
do
  clear
  Available=()
  Packages=()
  AutostartScripts=()
  Installed=()
  SetDefaultLists
  SearchForInstalled
  GenerateMenuList
  #echo "MENU-------------------------------------------"
  #echo "Available:" ${Available[*]} "| Length:" ${#Available[@]}
  #echo "Packages:" ${Packages[*]} "| Packages:" ${#Packages[@]}
  #echo "-----------------------------------------------"
  if [[ ${#Installed[@]} = 0 ]] || [[ ${#Installed[@]} = 1 ]]; then #0 or 1 desktop
    if [[ ${#Installed[@]} = 0 ]]; then #0 desktop text
      echo "No desktops installed on this system. (Press \"ESC\" to quit.)"
    else #1 desktop text
      echo "${Installed[0]} desktop is already installed on this system. (Press \"ESC\" to quit.)"
    fi
    echo "Available options:"
    for ThisEntry in "${!Available[@]}"; do #List menuentries
      echo "$(($ThisEntry + 1)). Install ${Available[ThisEntry]} desktop environment."
    done
    read -sn1 INPUT_OPTION
    if [[ $INPUT_OPTION = $'\e' ]]; then #Exit
      break
    elif ! [[ $INPUT_OPTION =~ ^[0-9]+$ ]]; then #Not number error
      echo "Not number!"
    elif [[ $INPUT_OPTION -gt $((${#Available[@]})) ]]; then #Invalid number error
      echo "Invalid number!"
    else #Install packages
      if ! [[ "${Available[$(($INPUT_OPTION - 1))]}" = *"(AUR)"* ]]; then
        sh Functions.sh InstallPackages ${Packages[$(($INPUT_OPTION - 1))]]}
      else
        sh Functions.sh InstallAURPackages ${Packages[$(($INPUT_OPTION - 1))]]}
      fi
      echo "exec ${AutostartScripts[$(($INPUT_OPTION - 1))]}" > ~/.xinitrc
    fi
  else #More than 1 desktops
    echo "Multiple desktops are installed on this system. (Press \"ESC\" to quit.)"
    echo "Available options:"
    echo "1. Set default desktop."
    for ThisEntry in "${!Available[@]}"; do #List menuentries
      echo "$(($ThisEntry + 2)). Install ${Available[ThisEntry]} desktop environment."
    done
    #Menu options
    read -sn1 INPUT_OPTION
    if [[ $INPUT_OPTION = $'\e' ]]; then #Exit
      break
    elif ! [[ $INPUT_OPTION =~ ^[0-9]+$ ]]; then #Not number error
      echo "Not number!"
    elif [[ $INPUT_OPTION -gt $((${#Available[@]} + 1)) ]]; then #Invalid number error
      echo "Invalid number!"
    elif [[ $INPUT_OPTION = 1 ]]; then #Select default
      echo "Choose default desktop:"
      for ThisEntry in "${!Installed[@]}"; do #Installed desktops list
        echo "$(($ThisEntry + 1)). Set ${Installed[ThisEntry]} as default."
      done
      SetDefaultLists
      read -sn1 INPUT_OPTION
      SetAsDefault ${Installed[$(($INPUT_OPTION - 1))]} #Do the work
    else #Install packages
      if ! [[ "${Available[$(($INPUT_OPTION - 2))]}" = *"(AUR)"* ]]; then
        sh Functions.sh InstallPackages ${Packages[$(($INPUT_OPTION - 2))]]}
      else
        sh Functions.sh InstallAURPackages ${Packages[$(($INPUT_OPTION - 2))]]}
      fi
      echo "exec ${AutostartScripts[$(($INPUT_OPTION - 2))]}" > ~/.xinitrc
    fi
  fi
done
