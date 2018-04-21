#!/bin/bash

function ReadBootCFG {
  #Grub
  BootFile="/boot/grub/grub.cfg"
  while read line
  do
    let LineCount=LineCount+1
    #Search for menuentries
    if [[ $line = "menuentry 'Arch"* ]] && ! [[ $line = *"fallback initramfs"* ]]; then
      IsMenu="true"
      let MenuEntryCount=MenuEntryCount+1
      if [[ $MenuEntryCount = 1 ]]; then
        VM_Linuz_default[0]=$(echo $line | sed "s/.*menuentry '\(.*\)'.*/\1/" | sed "s/'.*//")
      else
        if [[ ${#Version_Stash[*]} = 0 ]]; then
          Version_Stash[0]=$(echo $line | sed "s/.*menuentry '\(.*\)'.*/\1/" | sed "s/'.*//")
        else
          Version_Stash[${#Version_Stash[*]}]=$(echo $line | sed "s/.*menuentry '\(.*\)'.*/\1/" | sed "s/'.*//")
        fi
      fi
    fi
    #Find lines to replace
    if [[ $IsMenu = "true" ]]; then
      case $line in
        *"linux	/"* )
          if [[ $MenuEntryCount = 1 ]]; then
            VM_Linuz_default[1]=$LineCount
          else
            if [[ ${#UUID_Stash[*]} = 0 ]]; then
              UUID_Stash[0]=$LineCount
            else
              UUID_Stash[${#UUID_Stash[*]}]=$LineCount
            fi
          fi
          ;;
        *"initrd"* )
          Initframs=$line
          if [[ $MenuEntryCount = 1 ]]; then
            VM_Linuz_default[2]=$LineCount
          else
            if [[ ${#IMG_Stash[*]} = 0 ]]; then
              IMG_Stash[0]=$LineCount
            else
              IMG_Stash[${#IMG_Stash[*]}]=$LineCount
            fi
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

ReadBootCFG
#Set default kernel to load                                         UUID_Stash Set here ˇ
#sh Functions.sh ReplaceLineByNumber ${VM_Linuz_default[1]} "$(sed -n -e "${UUID_Stash[1]}p" $BootFile | sed 's/\//\\\//g' | cut -c 2-)" $BootFile
#Set default kernel to load                                         IMG_Stash Set here ˇ
#sh Functions.sh ReplaceLineByNumber ${VM_Linuz_default[2]} "$(sed -n -e "${IMG_Stash[1]}p" $BootFile | sed 's/\//\\\//g' | cut -c 2-)" $BootFile



#Gather required system information
[[ $(uname -r) = *"lts"* ]] && KERNEL_VERSION="LTS" || KERNEL_VERSION="default"
#Menu
while [ "$INPUT_OPTION" != "end" ]
do
  clear
  #Boot stuff-------------------------------------------------------------------
  echo "Available versions:" ${#Version_Stash[*]}
  echo ""
  echo "Default linux:" ${VM_Linuz_default[0]}
  echo "UUID line number:" ${VM_Linuz_default[1]}
  echo "IMG line number:" ${VM_Linuz_default[2]}
  echo ""
  echo "Version stash:" ${Version_Stash[*]}
  echo "UUID stash:" ${UUID_Stash[*]}
  echo "IMG stash:" ${IMG_Stash[*]}
  sed -n "${VM_Linuz_default[1]}p" $BootFile
  #-----------------------------------------------------------------------------
  echo "Linux currently uses \"$KERNEL_VERSION\" kernel. (Press \"ESC\" to go back.)"
  echo "Available kernel options:"
  case $KERNEL_VERSION in
    "default")
      echo "1. Change to LTS Kernel."
      read -sn1 INPUT_OPTION
      case $INPUT_OPTION in
        '1')
          echo "Trying to install LTS Kernel..."
          #pacman -S --noconfirm --noprogressbar --quiet linux-lts linux-lts-headers
          #Reconfigure to bootloader
          #grub-mkconfig -o /boot/grub/grub.cfg
          ;;
        $'\e') break;;
      esac
      ;;
    "LTS")
      echo "1. Change to default Kernel."
      read -sn1 INPUT_OPTION
      case $INPUT_OPTION in
        '1') echo "Trying to install default Kernel..."; pacman -S --noconfirm --noprogressbar --quiet linux linux-headers;;
        $'\e') break;;
      esac
      ;;
  esac
done
