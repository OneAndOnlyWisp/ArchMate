#!/bin/bash
#Local globals------------------------------------------------------------------
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"
CPU=$(lscpu | sed -n 's/^Model name:[[:space:]]*//p')
GPU=$(lspci | grep -o 'VGA compatible controller: .*' | sed 's/.*: //') #Most likely need a rework later on!!!
Available=(); Packages=(); Installed=();
#-------------------------------------------------------------------------------
#Helper functions area----------------------------------------------------------

#-------------------------------------------------------------------------------
#Kernel specific elements-------------------------------------------------------
function NvidiaDrivers {
  UUID_Stash=()
  temp_list=$(sh ""$Source_Path"Kernel.sh" GetUUID)
  UUID_Stash=(${temp_list// / })
  unset 'temp_list'
  echo "Installing ${Available[$1]} kernel specific drivers..."
  FirstPackage="true"
  for Package in $(echo ${Packages[$1]} | tr ";" "\n"); do
    if [[ $FirstPackage = "true" ]]; then
      for index in ${!UUID_Stash[*]}; do #Installed kernels
      ThisKernel=$(sed -n "${UUID_Stash[$index]}p" /boot/grub/grub.cfg | sed 's/.*\/vmlinuz-//' | sed 's/\s.*$//')
      echo $ThisKernel
      KernelSuffix=$(echo $ThisKernel | sed 's/.*linux//')
      echo "Installing "$Package""$KernelSuffix"..."
      #sh ""$Source_Path"Functions.sh" InstallPackages ""$ThisPackage""$KernelSuffix""
      FirstPackage="false"
      done
    else
      echo "Installing $Package package..."
      #sh ""$Source_Path"Functions.sh" InstallPackages "$Package"
    fi
  done
}
#-------------------------------------------------------------------------------
#Intel specific elements--------------------------------------------------------
function IntelVulkanCheck {
  CodeName=$(sh ""$Source_Path"Functions.sh" GetCodename)
  NotCompatible=("pentm" "pentium-m" "pentium4" "prescott" "nocona" "ivybridge" "sandybridge" "nehalem" "core2" "silvermont" "bonnell")
  temp=0
  for index in "${!NotCompatible[@]}"; do
    if ! [[ "$CodeName" = "${NotCompatible[$index]}" ]]; then
      temp=$(($temp + 1))
    fi
  done
  if [[ $temp = ${#NotCompatible[@]} ]]; then
    Packages[$1]="${Packages[$1]} vulkan-intel"
  fi
}
#-------------------------------------------------------------------------------
#Menu item generation elements--------------------------------------------------
function SetDefaultLists {
  Available=(); Packages=();
  #Available options
  Available=("Intel" "NVIDIA" "AMD")
  Packages=("xf86-video-intel mesa lib32-mesa" "nvidia nvidia-utils lib32-nvidia-utils" "xf86-video-amdgpu mesa lib32-mesa vulkan-radeon")
  if ! [[ ${#Available[@]} = ${#Packages[@]} ]]; then
    echo "Error"
    exit
  fi
}

function SearchForInstalled {
  SetDefaultLists
  Installed=()
  for xindex in ${!Packages[*]}; do
    Counter=0
    for Package in $(echo ${Packages[xindex]} | tr ";" "\n")
    do
      if [[ $(sh ""$Source_Path"Functions.sh" _isInstalled "$Package") = 0 ]]; then
        let Counter=Counter+1
      fi
    done
    PackageCount=$(($(echo ${Packages[xindex]} | sed 's/[^ ]//g' | tr -d "\n" | wc -c) + 1))
    if [[ $PackageCount = $Counter ]]; then
      Installed+=("${Available[xindex]}")
    fi
  done
}

function RemoveUnused {
  for index in "${!Available[@]}"; do
    if [[ "${Available[$index]}" = *"Intel"* ]]; then
      if [[ $CPU = *"Intel"* ]]; then
        IntelVulkanCheck $index
      fi
    else
      if ! [[ "$GPU" = *"${Available[$index]}"* ]]; then
        unset 'Available[index]'
        unset 'Packages[index]'
      fi
    fi
  done
}

function GenerateMenuElements {
  SearchForInstalled
  #RemoveUnused
  _temp_aval=()
  _temp_pack=()
  #Clear installed from available
  if ! [[ "${!Installed[@]}" = "" ]]; then
    for xindex in "${!Installed[@]}"; do
      for yindex in "${!Available[@]}"; do
        if [[ "${Available[$yindex]}" = "${Installed[$xindex]}" ]]; then
          unset 'Available[yindex]'
          unset 'Packages[yindex]'
        fi
      done
    done
  fi
  #Clear empty "cells"
  for index in "${!Available[@]}"; do
    _temp_aval+=("${Available[$index]}")
    _temp_pack+=("${Packages[$index]}")
  done
  Available=("${_temp_aval[@]}")
  Packages=("${_temp_pack[@]}")
  unset '_temp_aval'
  unset '_temp_pack'
  echo "MENU-------------------------------------------"
  echo "Available:" ${Available[*]} "| Length:" ${#Available[@]}
  echo "Packages:" ${Packages[*]}
  echo "-----------------------------------------------"
}
#-------------------------------------------------------------------------------
#Draw menu elements-------------------------------------------------------------
function DriverInstall {
  if [[ ${Available[$1]} = *"NVIDIA"* ]]; then
    NvidiaDrivers $1
  else
    for Package in $(echo ${Packages[$1]} | tr ";" "\n"); do
      echo "Installing $Package package..."
      #sh ""$Source_Path"Functions.sh" InstallPackages "$Package"
    done
  fi
}

function HasOptions {
  echo "Available options:"
  for ThisEntry in "${!Available[@]}"; do #List menuentries
    echo "$(($ThisEntry + 1)). Install ${Available[ThisEntry]} graphics driver."
  done
  read -sn1 KEY_PRESS
  if ! [[ $KEY_PRESS = $'\e' ]]; then
    if [[ $KEY_PRESS =~ ^[0-9]+$ ]]; then
      if [[ $KEY_PRESS -le ${#Available[@]} ]]; then
        DriverInstall $(($KEY_PRESS - 1))
      fi
    fi
  else
    exit
  fi
}

function DrawMenu {
  echo "Graphical adapters found:                 (Press \"ESC\" to go back.)"
  echo "- $GPU"
  if [[ ${#Available[@]} = 0 ]]; then #Everything available is installed
    echo "No available options."
    read -sn1 KEY_PRESS
    if [[ $KEY_PRESS = $'\e' ]]; then #Exit
      exit
    fi
  else
    HasOptions
  fi
}
#-------------------------------------------------------------------------------
#Menu
while [ "$INPUT_OPTION" != "end" ]
do
  clear
  GenerateMenuElements
  DrawMenu
  read -sn1
  exit


  #UI
  echo "Graphical adapters found:                 (Press \"ESC\" to go back.)"
  echo "- $GPU"
  if [[ ${#Available[@]} = 0 ]]; then #Everything available is installed
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
      for ThisPackage in $(echo ${Packages[$(($INPUT_OPTION - 1))]} | tr ";" "\n")
      do
        for index in ${!UUID_Stash[*]}; do #Installed kernels
          ThisKernel=$(sed -n "${UUID_Stash[$index]}p" $BootFile | sed 's/.*\/vmlinuz-//' | sed 's/\s.*$//')
          KernelSuffix=$(echo $ThisKernel | sed 's/.*linux//')
          echo ""$ThisPackage""$KernelSuffix""
          sh ""$Source_Path"Functions.sh" InstallPackages ""$ThisPackage""$KernelSuffix""
        done
      done
    fi
    read -sn1
  fi
done
