#!/bin/bash
#Local globals------------------------------------------------------------------
BootFile="/boot/grub/grub.cfg"
Version_Stash=(); UUID_Stash=(); IMG_Stash=();
Available=(); Packages=(); Installed=();
#-------------------------------------------------------------------------------
#CPU microcode------------------------------------------------------------------
function InstallMicrocode {
  CPU=$(lscpu | sed -n 's/^Model name:[[:space:]]*//p')
  if [[ $CPU = *"Intel"* ]]; then
    pacman -S --noconfirm intel-ucode;
  elif [[ $CPU = *"AMD"* ]]; then
    pacman -S --noconfirm amd-ucode;
  fi
  grub-mkconfig -o /boot/grub/grub.cfg
}
#-------------------------------------------------------------------------------
#Helper functions---------------------------------------------------------------
function GetDefaultKernel {
  temp="$(sed -n "${VM_Linuz_default[1]}p" $BootFile | sed 's/.*\/vmlinuz-//' | sed 's/\s.*$//') "
  for index in "${!Packages[@]}"; do #Default kernel to boot
    if [[ "${Packages[$index]}" = "${temp%?}"* ]]; then
      echo "${Available[$index]}"
      exit
    fi
  done
}

function GetActiveKernel {
  temp=$(uname -r | rev | cut -d "-" -f 1 | rev)
  if [[ "$temp" = "ARCH" ]]; then
    echo "Stable"
  else
    for index in "${!Packages[@]}"; do
      if [[ "${Packages[$index]}" = *"$temp"* ]]; then
        echo ${Available[$index]}
        break
      fi
    done
  fi
  exit
}

function SetAsDefault {
  #Set default kernel to load (UUID_Stash)
  ReplaceWith=$(sed -n -e "${UUID_Stash[$1]}p" $BootFile | sed 's/\//\\\//g' | cut -c 2-)
  sed -ie "${VM_Linuz_default[1]}s/.*/$ReplaceWith/g" $BootFile
  #Set default kernel to load (IMG_Stash)
  ReplaceWith=$(sed -n -e "${IMG_Stash[$1]}p" $BootFile | sed 's/\//\\\//g' | cut -c 2-)
  sed -ie "${VM_Linuz_default[2]}s/.*/$ReplaceWith/g" $BootFile
}

function ListKernelsFromBoot {
  SetDefaultLists
  for xindex in "${!Version_Stash[@]}"; do
    FindMe=$(sed -n "${UUID_Stash[xindex]}p" $BootFile | sed 's/.*\/vmlinuz-//' | sed 's/\s.*$//')
    for yindex in "${!Packages[@]}"; do
      if [[ "${Packages[$yindex]}" = "$FindMe"* ]]; then
        echo "$(($xindex + 1)). Set ${Available[$yindex]} as default."
      fi
    done
  done
}

function SetDefaultKernel {
  clear
  echo "Choose default kernel:"
  ListKernelsFromBoot
  read -sn1 KEY_PRESS
  if ! [[ $KEY_PRESS = $'\e' ]]; then
    if [[ $KEY_PRESS =~ ^[0-9]+$ ]]; then
      if [[ $KEY_PRESS -le ${#Version_Stash[@]} ]] && [[ $KEY_PRESS -gt 0 ]]; then
        KEY_PRESS=$(($KEY_PRESS - 1))
        SetAsDefault $KEY_PRESS
      fi
    fi
  fi
}

function InstallKernel {
  pacman -S --noconfirm ${Packages[$1]}
  grub-mkconfig -o /boot/grub/grub.cfg
}

function RemoveKernel {
  #Init stuff
  SearchForInstalled
  for xindex in "${!Version_Stash[@]}"; do
    #Kernel image name (package name)
    FindMe=$(sed -n "${UUID_Stash[xindex]}p" $BootFile | sed 's/.*\/vmlinuz-//' | sed 's/\s.*$//')
    for yindex in "${!Packages[@]}"; do
      if [[ "${Packages[$yindex]}" = "$FindMe "* ]]; then
        if [[ "${Available[$yindex]}" = "$ACTIVE_KERNEL" ]]; then
          #Remove active kernel from the list
          unset 'Available[yindex]'
          unset 'Packages[yindex]'
        fi
      fi
    done
  done
  #Remove not installed from the list
  for xindex in "${!Available[@]}"; do
    counter=0
    for yindex in "${!Installed[@]}"; do
      if [[ "${Available[$xindex]}" = "${Installed[$yindex]}" ]]; then
        counter=$(($counter + 1))
      fi
    done
    if [[ $counter = 0 ]]; then
      unset 'Available[xindex]'
      unset 'Packages[xindex]'
    fi
  done
  #Read from temp array
  for index in "${!Available[@]}"; do
    _temp_aval+=("${Available[$index]}")
    _temp_pack+=("${Packages[$index]}")
  done
  Available=("${_temp_aval[@]}")
  Packages=("${_temp_pack[@]}")
  #Clear temp array
  unset '_temp_aval'
  unset '_temp_pack'
  #Action
  clear
  echo "Choose kernel to remove:"
  for index in "${!Available[@]}"; do
    echo "$(($index + 1)). Remove ${Available[index]} kernel."
  done
  read -sn1 KEY_PRESS
  if ! [[ $KEY_PRESS = $'\e' ]]; then
    if [[ $KEY_PRESS =~ ^[0-9]+$ ]]; then
      if [[ $KEY_PRESS -le ${#Available[@]} ]] && [[ $KEY_PRESS -gt 0 ]]; then
        KEY_PRESS=$(($KEY_PRESS - 1))
        pacman -Rs --noconfirm ${Packages[$KEY_PRESS]}
        grub-mkconfig -o /boot/grub/grub.cfg
      fi
    fi
  fi
}
#-------------------------------------------------------------------------------
#Menu item generation elements--------------------------------------------------
function ReadBootCFG {
  Version_Stash=(); UUID_Stash=(); IMG_Stash=();
  MenuEntryCount=0
  LineCount=0
  while read line
  do
    let LineCount=LineCount+1
    #Search for menuentries
    if [[ $line = "menuentry 'Arch"* ]] && ! [[ $line = *"fallback initramfs"* ]]; then
      IsMenu="true"
      let MenuEntryCount=MenuEntryCount+1
      if [[ $MenuEntryCount = 1 ]]; then
        VM_Linuz_default+=("$(echo $line | sed "s/.*menuentry '\(.*\)'.*/\1/" | sed "s/'.*//")")
      else
        Version_Stash+=("$(echo $line | sed "s/.*menuentry '\(.*\)'.*/\1/" | sed "s/'.*//")")
      fi
    fi
    #Find lines to replace
    if [[ $IsMenu = "true" ]]; then
      case $line in
        *"linux	/"* )
          if [[ $MenuEntryCount = 1 ]]; then
            VM_Linuz_default+=("$LineCount")
          else
            UUID_Stash+=("$LineCount")
          fi
          ;;
        *"initrd"* )
          Initframs=$line
          if [[ $MenuEntryCount = 1 ]]; then
            VM_Linuz_default+=("$LineCount")
          else
            IMG_Stash+=("$LineCount")
          fi
          ;;
      esac
      #Close menu
      if [[ $line = *"}"* ]]; then
        IsMenu="false"
      fi
    fi
  done < $BootFile
}

function SetDefaultLists {
  Available=(); Packages=();
  Available=("Stable" "Longterm" "Zen" "Hardened")
  Packages=("linux" "linux-lts linux-lts-headers" "linux-zen linux-zen-headers" "linux-hardened")
  if ! [[ ${#Available[@]} = ${#Packages[@]} ]]; then
    echo "Error"
    break
  fi
  ReadBootCFG
  DEFAULT_KERNEL="$(GetDefaultKernel)"
  ACTIVE_KERNEL=$(GetActiveKernel)
}

function SearchForInstalled {
  SetDefaultLists
  Installed=()
  for xindex in ${!Packages[*]}; do
    for yindex in ${!UUID_Stash[*]}; do
      SearchFor=$(sed -n "${UUID_Stash[$yindex]}p" $BootFile | sed 's/.*\/vmlinuz-//' | sed 's/\s.*$//')
      ThisKernel=$(echo ${Packages[$xindex]} | sed -e 's/\s.*$//')
      if [[ "$ThisKernel" = "$SearchFor" ]]; then
        Installed+=("${Available[$xindex]}")
      fi
    done
  done
}

function GenerateMenuElements {
  SearchForInstalled
  _temp_aval=()
  _temp_pack=()
  for xindex in "${!Installed[@]}"; do
    for yindex in "${!Available[@]}"; do
      if [[ "${Available[$yindex]}" = "${Installed[$xindex]}" ]]; then
        unset 'Available[yindex]'
        unset 'Packages[yindex]'
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
#-------------------------------------------------------------------------------
#Draw menu elements-------------------------------------------------------------
function ListAvailableItems {
  #List menuentries
  if [[ "$1" = "" ]]; then
    for index in "${!Available[@]}"; do
      echo "$(($index + 1)). Install ${Available[index]} kernel."
    done
  else
    for index in "${!Available[@]}"; do
      echo "$(($index + $1)). Install ${Available[index]} kernel."
    done
  fi
}

function OneKernel {
  echo "Available options:"
  ListAvailableItems
  read -sn1 KEY_PRESS
  if ! [[ $KEY_PRESS = $'\e' ]]; then
    if [[ $KEY_PRESS =~ ^[0-9]+$ ]]; then
      if [[ $KEY_PRESS -le ${#Available[@]} ]]; then
        InstallKernel $(($KEY_PRESS - 1))
      fi
    fi
  else
    exit
  fi
}

function MultipleKernel {
  echo "Booting with \"$DEFAULT_KERNEL\" kernel by default."
  echo "Available options:"
  echo "1. Set default kernel."
  echo "2. Remove kernel."
  ListAvailableItems 3
  read -sn1 KEY_PRESS
  if ! [[ $KEY_PRESS = $'\e' ]]; then
    if [[ $KEY_PRESS =~ ^[0-9]+$ ]]; then
      if [[ $KEY_PRESS -le $((${#Available[@]} + 2)) ]]; then
        KEY_PRESS=$(($KEY_PRESS - 1))
        if [[ $KEY_PRESS = 0 ]]; then
          SetDefaultKernel
        elif [[ $KEY_PRESS = 1 ]]; then
          RemoveKernel
        else
          InstallKernel $(($KEY_PRESS - 2))
        fi
      fi
    fi
  else
    exit
  fi
}

function DrawMenu {
  echo "Currently using \"$ACTIVE_KERNEL\" kernel. (Press \"ESC\" to quit.)"
  if [[ ${#Installed[@]} = 1 ]]; then
    OneKernel
  else
    MultipleKernel
  fi
}
#-------------------------------------------------------------------------------
InstallMicrocode
#User interface-----------------------------------------------------------------
while [ "$StopLoop" != "true" ]
do
  clear
  GenerateMenuElements
  DrawMenu
done
#-------------------------------------------------------------------------------
