#!/bin/bash
#Local globals------------------------------------------------------------------
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../"
CPU=$(lscpu | sed -n 's/^Model name:[[:space:]]*//p')
readarray -t GPU <<<"$(lspci | grep -o 'VGA compatible controller: .*' | sed 's/.*: //')";
Available=(); Packages=(); Installed=();
#-------------------------------------------------------------------------------
#32-bit application support?----------------------------------------------------
function EnableMultilib {
  StartingLine=$(sed -n '/#\[multilib\]/=' /etc/pacman.conf)
  if ! [[ "$StartingLine" = "" ]]; then
    sed -ie ""$StartingLine"s/#//g" /etc/pacman.conf
    sed -ie ""$(($StartingLine + 1))"s/#//g" /etc/pacman.conf
    pacman -Syy
  fi
}
#-------------------------------------------------------------------------------
#Intel vulkan check-------------------------------------------------------------
function VulkanCheck {
  CodeName=$(gcc -c -Q -march=native --help=target | grep march | grep -oE '[^ ]+$')
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
  #CPU
  if [[ "$CPU" = *"Intel"* ]]; then
    Available+=("Intel"); Packages+=("mesa lib32-mesa xf86-video-intel");
  elif [[ "$CPU" = *"AMD"* ]]; then
    Available+=("AMD"); Packages+=("xf86-video-amdgpu mesa lib32-mesa vulkan-radeon");
  fi
  #GPU
  for index in "${!GPU[@]}"; do
    if [[ "${GPU[$index]}" = *"NVIDIA"* ]]; then
      Available+=("NVIDIA")
      if ! [[ $(uname -r) = *"lts"* ]]; then
        Packages+=("nvidia nvidia-utils lib32-nvidia-utils nvidia-settings");
      else
        Packages+=("nvidia-lts nvidia-utils lib32-nvidia-utils nvidia-settings");
      fi
    elif [[ "${GPU[$index]}" = *"AMD"* ]] && [[ "$CPU" = *"Intel"* ]]; then
      Available+=("AMD"); Packages+=("xf86-video-amdgpu mesa lib32-mesa vulkan-radeon");
    fi
  done
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
          if [[ $(sh ""$Source_Path"functions.sh" _isInstalled "$Package") = 0 ]]; then
            Counter=$(($Counter + 1))
          fi
        fi
      done
    else
      for Package in $(echo ${Packages[xindex]} | tr ";" "\n"); do
        if [[ $(sh ""$Source_Path"functions.sh" _isInstalled "$Package") = 0 ]]; then
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

function IntelVulkanCheck {
  for index in "${!Available[@]}"; do
    if [[ "${Available[$index]}" = *"Intel"* ]]; then
      if [[ $CPU = *"Intel"* ]]; then
        VulkanCheck $index
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
  IntelVulkanCheck
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
  echo "- $CPU (CPU integrated graphics)"
  for index in "${!GPU[@]}"; do
    if ! [[ "${GPU[$index]}" = *"Intel"* ]]; then
      echo "- ${GPU[$index]}"
    fi
  done
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
#Init stuff---------------------------------------------------------------------
EnableMultilib
#-------------------------------------------------------------------------------
#User interface-----------------------------------------------------------------
while [ "$INPUT_OPTION" != "end" ]
do
  clear
  GenerateMenuElements
  DrawMenu
done
#-------------------------------------------------------------------------------
