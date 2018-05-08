#!/bin/sh
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"

#Init "Multimedia engine" (Audio + Window system)
sh ""$Source_Path"Functions.sh" InstallPackages "pulseaudio" "pulseaudio-alsa" "xorg" "xorg-xinit"

function SetDefaultLists {
  #Available options
  Available=("Plasma" "Gnome" "Budgie" "Lumina (AUR)")
  Packages=("plasma-desktop" "gnome" "budgie-desktop" "lumina-desktop")
  AutostartScripts=("startkde" "gnome-session" "budgie-desktop" "start-lumina-desktop")
  if ! [[ ${#Available[@]} = ${#Packages[@]} ]]; then
    echo "Error"
    exit
  fi
}

function SearchForInstalled {
  for index in ${!Packages[*]}; do
    echo ${Packages[index]}
    [[ $(sh ""$Source_Path"Functions.sh" _isInstalled "${Packages[index]}") = 0 ]] && Installed+=("${Available[index]}")
  done
}

function GenerateMenuList {
  _temp_aval=()
  _temp_pack=()
  _temp_exec=()
  for xindex in "${!Installed[@]}"; do
    for yindex in "${!Available[@]}"; do
      if [[ "${Available[$yindex]}" = "${Installed[$xindex]}" ]]; then
        unset 'Available[yindex]'
        unset 'Packages[yindex]'
        unset 'AutostartScripts[yindex]'
      fi
    done
  done
  for index in "${!Available[@]}"; do
    _temp_aval+=("${Available[$index]}")
    _temp_pack+=("${Packages[$index]}")
    _temp_exec+=("${AutostartScripts[$index]}")
  done
  Available=("${_temp_aval[@]}")
  Packages=("${_temp_pack[@]}")
  AutostartScripts=("${_temp_exec[@]}")
  unset '_temp_aval'
  unset '_temp_pack'
  unset '_temp_exec'
}

function SetAsDefault {
  for index in "${!Available[@]}"; do
    if [[ "${Available[$index]}" = "$1" ]]; then
      echo "exec ${AutostartScripts[$index]}" > ~/.xinitrc
    fi
  done
}

#Menu
while [ "$INPUT_OPTION" != "end" ]
do
  #MENU---------------------------------------
  Available=()
  Packages=()
  AutostartScripts=()
  Installed=()
  SetDefaultLists
  SearchForInstalled
  GenerateMenuList
  #-------------------------------------------
  #clear
  #UI
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
      sh ""$Source_Path"Functions.sh" InstallPackages ${Packages[$(($INPUT_OPTION - 1))]}
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
      if ! [[ $INPUT_OPTION -gt ${#Installed[@]} ]]; then
        SetAsDefault ${Installed[$(($INPUT_OPTION - 1))]}
      fi
    else #Install packages
      sh ""$Source_Path"Functions.sh" InstallPackages ${Packages[$(($INPUT_OPTION - 2))]}      
      echo "exec ${AutostartScripts[$(($INPUT_OPTION - 2))]}" > ~/.xinitrc
    fi
  fi
done
