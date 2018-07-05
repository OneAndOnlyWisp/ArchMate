#!/bin/bash
#Local globals------------------------------------------------------------------
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"
CPU=$(lscpu | sed -n 's/^Model name:[[:space:]]*//p')
GPU=$(lspci | grep -o 'VGA compatible controller: .*' | sed 's/.*: //') #Most likely need a rework later on!!!
Available=(); Packages=(); Installed=();
#-------------------------------------------------------------------------------
#Dependancy check---------------------------------------------------------------
function EnableMultilib {
  StartingLine=$(sed -n '/#\[multilib\]/=' /etc/pacman.conf)
  if ! [[ "$StartingLine" = "" ]]; then
    sed -ie ""$StartingLine"s/#//g" /etc/pacman.conf
    sed -ie ""$(($StartingLine + 1))"s/#//g" /etc/pacman.conf
    pacman -Syy
  fi
}
#-------------------------------------------------------------------------------
#CK Kernel specific elements(NOT USED)------------------------------------------
function NvidiaDrivers {
  UUID_Stash=()
  temp_list=$(sh ""$Source_Path"Kernel.sh" GetStash_UUID)
  UUID_Stash=(${temp_list// / })
  unset 'temp_list'
  echo "Installing ${Available[$1]} kernel specific drivers..."
  FirstPackage="true"
  for Package in $(echo ${Packages[$1]} | tr ";" "\n"); do
    if [[ $FirstPackage = "true" ]]; then
      for index in ${!UUID_Stash[*]}; do #Installed kernels
      ThisKernel=$(sed -n "${UUID_Stash[$index]}p" /boot/grub/grub.cfg | sed 's/.*\/vmlinuz-//' | sed 's/\s.*$//')
      KernelSuffix=$(echo $ThisKernel | sed 's/.*linux//')
      sh ""$Source_Path"Functions.sh" InstallPackages ""$Package""$KernelSuffix""
      FirstPackage="false"
      done
    else
      sh ""$Source_Path"Functions.sh" InstallPackages "$Package"
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
  Packages=("mesa lib32-mesa xf86-video-intel" "nvidia nvidia-utils lib32-nvidia-utils nvidia-settings" "xf86-video-amdgpu mesa lib32-mesa vulkan-radeon")
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
    if [[ ${Available[xindex]} = "NVIDIA" ]]; then
      for Package in $(echo ${Packages[xindex]} | tr ";" "\n"); do
        if [[ $Counter = 0 ]]; then
          Counter=$(($Counter + 1))
        elif [[ condition ]]; then
          if [[ $(sh ""$Source_Path"Functions.sh" _isInstalled "$Package") = 0 ]]; then
            Counter=$(($Counter + 1))
          fi
        fi
      done
    else
      for Package in $(echo ${Packages[xindex]} | tr ";" "\n"); do
        if [[ $(sh ""$Source_Path"Functions.sh" _isInstalled "$Package") = 0 ]]; then
          Counter=$(($Counter + 1))
        fi
      done
    fi
    PackageCount=$(($(echo ${Packages[xindex]} | sed 's/[^ ]//g' | tr -d "\n" | wc -c) + 1))
    if [[ $PackageCount = $Counter ]]; then
      Installed+=("${Available[xindex]}")
    fi
  done
}

function RemoveNotFound {
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
  RemoveNotFound
}
#-------------------------------------------------------------------------------
#Draw menu elements-------------------------------------------------------------
function HasOptions {
  echo "Available options:"
  for ThisEntry in "${!Available[@]}"; do #List menuentries
    echo "$(($ThisEntry + 1)). Install ${Available[ThisEntry]} graphics driver."
  done
  read -sn1 KEY_PRESS
  if ! [[ $KEY_PRESS = $'\e' ]]; then
    if [[ $KEY_PRESS =~ ^[0-9]+$ ]]; then
      if [[ $KEY_PRESS -le ${#Available[@]} ]]; then
        KEY_PRESS=$(($KEY_PRESS - 1))
        pacman -S --noconfirm ${Packages[$KEY_PRESS]}
      fi
    fi
  else
    exit
  fi
}

function DrawMenu {
  echo "Graphical adapters found:                 (Press \"ESC\" to go back.)"
  if [[ $CPU = *"Intel"* ]]; then
    echo "- $CPU (Intel graphics)"
  fi
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
EnableMultilib
#User interface-----------------------------------------------------------------
while [ "$INPUT_OPTION" != "end" ]
do
  clear
  GenerateMenuElements
  DrawMenu
done
#-------------------------------------------------------------------------------
