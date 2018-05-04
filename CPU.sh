#!/bin/bash
clear

#Gather required system information
CPU=$(lscpu | sed -n 's/^Model name:[[:space:]]*//p')

function EnableMultilibRepository {
  StartingLine=$(sed -n '/#\[multilib\]/=' /etc/pacman.conf)
  if ! [[ $StartingLine = "" ]]; then
    sed -ie ""$StartingLine"s/#//g" /etc/pacman.conf
    sed -ie "$(($StartingLine + 1))s/#//g" /etc/pacman.conf
    pacman -Syu
  fi
}

function SetDefaultLists {
  #Available options
  Available=("Intel Graphics" "Intel Vulkan" "AMD Graphics" "AMD Vulkan")
  echo "DEFAULT----------------------------------------"
  echo "Available:" ${Available[*]} "| Length:" ${#Available[@]}
  Packages=("mesa lib32-mesa" "vulkan-intel" "mesa lib32-mesa xf86-video-amdgpu" "vulkan-radeon")
  if ! [[ ${#Available[@]} = ${#Packages[@]} ]]; then
    echo "Error"
    exit
  fi
}

function SearchForInstalled {
  #echo "-----------------------------------------------"
  for ThisPackageList in ${!Packages[*]}; do
    Counter=0
    for ThisPackage in $(echo ${Packages[ThisPackageList]} | tr ";" "\n")
    do
      if [[ $(sh Functions.sh _isInstalled "$ThisPackage") = 0 ]]; then
        let Counter=Counter+1
      fi
    done
    PackageCount=$(($(echo ${Packages[ThisPackageList]} | sed 's/[^ ]//g' | tr -d "\n" | wc -c) + 1))
    if [[ $PackageCount = $Counter ]]; then
      Installed+=("${Available[ThisPackage]}")
    fi
    #echo "Packages: ${Packages[ThisPackageList]} | Desktop: ${Available[ThisPackageList]}"
  done
  echo "Installed:" ${Installed[*]} "| Length:" ${#Installed[@]}
  echo "-----------------------------------------------"
}

function VulkanSupportCheck {
  [[ $(sh Functions.sh _isInstalled "pup-git") = 1 ]] && sh Functions.sh InstallAURPackages "pup-git"
  if [[ $CodeName = "" ]]; then
    CodeName=$(sh Functions.sh IntelCodename)
  fi
  NotCompatible=("P5" "P" "NetBurst" "Pentium M" "Prescott" "Intel Core" "Penryn" "Nehalem" "Bonnell" "Westmere" "Saltwell" "Sandy Bridge" "Ivy Bridge")
  for index in "${!NotCompatible[@]}"; do
    if [[ "$CodeName" = "${NotCompatible[$index]}" ]]; then
      unset 'Available[$1]'
      unset 'Packages[$1]'
    fi
  done
}

function MenuFIX {
  if [[ $CPU = *"Intel"* ]]; then
    if [[ "${Available[$1]}" = *"AMD"* ]]; then
      unset 'Available[$1]'
      unset 'Packages[$1]'
    elif [[ "${Available[$1]}" = *"Vulkan"* ]]; then
      VulkanSupportCheck $1
    fi
  else
    if [[ "${Available[$1]}" = *"Intel"* ]]; then
      unset 'Available[$1]'
      unset 'Packages[$1]'
    fi
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
      fi
      MenuFIX $yindex
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

#Init 32bit support
EnableMultilibRepository
#Menu
while [ "$INPUT_OPTION" != "end" ]
do
  Available=()
  Packages=()
  Installed=()
  SetDefaultLists
  SearchForInstalled
  #TEST---------------------------------------
  #Installed+=("Intel Vulkan")
  #echo "INSTALLED FIX----------------------------------"
  #echo "Installed:" ${Installed[*]} "| Length:" ${#Installed[@]}
  #-------------------------------------------
  GenerateMenuList
  #echo "MENU-------------------------------------------"
  #echo "Available:" ${Available[*]} "| Length:" ${#Available[@]}
  #echo "Packages:" ${Packages[*]} "| Length:" ${#Packages[@]}
  #echo "-----------------------------------------------"
  #echo ""
  #echo "This system has an \"$CPU\" processor. (Press \"ESC\" to go back.)"
  if [[ ${#Available[@]} = 0 ]]; then
    echo "No available options."
    read -sn1 INPUT_OPTION
    if [[ $INPUT_OPTION = $'\e' ]]; then #Exit
      break
    fi
  else
    echo "Available CPU options:"
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
      for ThisPackage in $(echo ${Packages[$(($INPUT_OPTION - 1))]} | tr ";" "\n")
      do
        #echo $ThisPackage
        sh Functions.sh InstallPackages $ThisPackage
      done
    fi
  fi
  read -sn1
  clear
done
