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

#ACTIVE_KERNEL
[[ $(uname -r) = *"lts"* ]] && ACTIVE_KERNEL="Longterm" || ACTIVE_KERNEL="Stable"
#DEFAULT_KERNEL
DEFAULT_KERNEL=$(sed -n "${VM_Linuz_default[1]}p" $BootFile | sed 's/.*\///' | sed 's/\s.*$//')
case $DEFAULT_KERNEL in
  *"ck"* ) echo "CK kernel";;
  *"lqx"* ) echo "Liquorix kernel";;
  * ) [[ $DEFAULT_KERNEL = *"lts"* ]] && DEFAULT_KERNEL="Longterm" || DEFAULT_KERNEL="Stable"
    ;;
esac


#Set default kernel to load                                         UUID_Stash Set here ˇ
#sh Functions.sh ReplaceLineByNumber ${VM_Linuz_default[1]} "$(sed -n -e "${UUID_Stash[1]}p" $BootFile | sed 's/\//\\\//g' | cut -c 2-)" $BootFile
#Set default kernel to load                                         IMG_Stash Set here ˇ
#sh Functions.sh ReplaceLineByNumber ${VM_Linuz_default[2]} "$(sed -n -e "${IMG_Stash[1]}p" $BootFile | sed 's/\//\\\//g' | cut -c 2-)" $BootFile


#Gather required system information

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
  echo ""
  #TEST
  echo "Active kernel:" $ACTIVE_KERNEL
  echo "Grub default kernel:" $DEFAULT_KERNEL
  echo ""

  #CASE list (AVAILABLE-INSTALLED)

  #-----------------------------------------------------------------------------
  echo "Available kernel options:"
  case $ACTIVE_KERNEL in
    "Stable")
      echo "1. Change to LTS Kernel."
      read -sn1 INPUT_OPTION
      case $INPUT_OPTION in
        '1')
          echo "Trying to install LTS Kernel..."
          #pacman -S --noconfirm linux-lts linux-lts-headers
          #Reconfigure to bootloader
          #grub-mkconfig -o /boot/grub/grub.cfg
          ;;
        $'\e') break;;
      esac
      ;;
    "Longterm")
      echo "1. Change to default Kernel."
      read -sn1 INPUT_OPTION
      case $INPUT_OPTION in
        '1') echo "Trying to install default Kernel..."; pacman -S --noconfirm linux linux-headers;;
        $'\e') break;;
      esac
      ;;
  esac
done
