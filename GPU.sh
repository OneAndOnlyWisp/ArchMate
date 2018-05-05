#!/bin/sh
clear

#Gather required system information
GPU=$(lspci | grep -o 'VGA compatible controller: .*' | sed 's/.*: //') #Most likely need a rework later on!!!

function SetDefaultLists {
  #Available options
  Available=("NVIDIA" "AMD" "VirtualBox")
  #echo "DEFAULT----------------------------------------"
  #echo "Available:" ${Available[*]} "| Length:" ${#Available[@]}
  Packages=("nvidia" "xxxxx" "virtualbox-guest-utils")
  if ! [[ ${#Available[@]} = ${#Packages[@]} ]]; then
    echo "Error"
    exit
  fi
}

function SearchForInstalled {
  #echo "-----------------------------------------------"
  for ThisPackageList in ${!Packages[*]}; do
    #echo "Packages: ${Packages[ThisPackageList]} | Desktop: ${Available[ThisPackageList]}"
    if [[ $(sh Functions.sh _isInstalled "${Packages[ThisPackageList]}") = 0 ]]; then
      Installed+=("${Available[ThisPackageList]}")
    fi
  done
  #echo "Installed:" ${Installed[*]} "| Length:" ${#Installed[@]}
  #echo "-----------------------------------------------"
}

function MenuFIX {
  if [[ $GPU = *"NVIDIA"* ]] && ! [[ "${Available[$1]}" = *"NVIDIA"* ]]; then
    unset 'Available[$1]'
    unset 'Packages[$1]'
  elif [[ $GPU = *"Radeon"* ]] && ! [[ "${Available[$1]}" = *"Radeon"* ]]; then
    unset 'Available[$1]'
    unset 'Packages[$1]'
  elif [[ $GPU = *"VirtualBox"* ]] && ! [[ "${Available[$1]}" = *"VirtualBox"* ]]; then
    unset 'Available[$1]'
    unset 'Packages[$1]'
  fi
}

function GenerateMenuList {
  _temp_aval=()
  _temp_pack=()
  for xindex in "${!Installed[@]}"; do
    for yindex in "${!Available[@]}"; do
      if [[ "${Available[$yindex]}" = "${Installed[$xindex]}" ]]; then
        unset 'Available[yindex]'
        unset 'Packages[yindex]'
      else
        echo "MenuFIX"
        #MenuFIX $yindex
      fi
    done
  done
  for index in "${!Available[@]}"; do
    _temp_aval+=("${Available[$index]}")
    _temp_pack+=("${Packages[$index]}")
  done
  Available=("${_temp_aval[@]}")
  Packages=("${_temp_pack[@]}")
  unset '_temp_aval'
  unset '_temp_pack'
}

#Menu
while [ "$INPUT_OPTION" != "end" ]
do
  Available=()
  Packages=()
  Installed=()
  SetDefaultLists
  SearchForInstalled
  #TEST---------------------------------------
  #Installed+=("Longterm")
  #-------------------------------------------
  GenerateMenuList
  #echo "MENU-------------------------------------------"
  #echo "Available:" ${Available[*]} "| Length:" ${#Available[@]}
  #echo "Packages:" ${Packages[*]} "| Length:" ${#Packages[@]}
  #echo "-----------------------------------------------"
  echo "Graphical adapters found:                 (Press \"ESC\" to go back.)"
  echo "- $GPU"
  if [[ ${#Available[@]} = 0 ]]; then #Everything available installed
    echo "No available options."
    read -sn1 INPUT_OPTION
    if [[ $INPUT_OPTION = $'\e' ]]; then #Exit
      break
    fi
  else #Draw menu
    echo "Available options:"
    for ThisEntry in "${!Available[@]}"; do #List menuentries
      echo "$(($ThisEntry + 1)). Install ${Available[ThisEntry]} driver."
    done
    read -sn1 INPUT_OPTION
    if [[ $INPUT_OPTION = $'\e' ]]; then #Exit
      break
    elif ! [[ $INPUT_OPTION =~ ^[0-9]+$ ]]; then #Not number error
      echo "Not number!"
    elif [[ $INPUT_OPTION -gt $((${#Available[@]})) ]]; then #Invalid number error
      echo "Invalid number!"
    else #Install packages
      echo ${Available[$(($INPUT_OPTION - 1))]} | tr ";" "\n"
      #NEED check kernel for proper driver package
      if ! [[ "${Available[$(($INPUT_OPTION - 1))]}" = *"(AUR)"* ]]; then #Pacman
        for ThisPackage in $(echo ${Packages[$(($INPUT_OPTION - 1))]} | tr ";" "\n")
        do
          echo $ThisPackage
          #sh Functions.sh InstallPackages $ThisPackage
        done
      else #Aurman
        for ThisPackage in $(echo ${Packages[$(($INPUT_OPTION - 1))]} | tr ";" "\n")
        do
          echo $ThisPackage "(AUR)"
          #sh Functions.sh InstallAURPackages $ThisPackage
        done
      fi
    fi
    read -sn1
    clear
  fi
done
