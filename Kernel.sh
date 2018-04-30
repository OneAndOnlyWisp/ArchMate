#!/bin/bash
clear

function SetDefaultLists {
  #Available options
  Available=("Stable" "Longterm" "Zen" "CK (AUR)")
  echo "DEFAULT----------------------------------------"
  echo "Available:" ${Available[*]} "| Length:" ${#Available[@]}
  Packages=("linux linux-headers" "linux-lts linux-lts-headers" "linux-zen linux-zen-headers" "linux-ck linux-ck-headers")
  if ! [[ ${#Available[@]} = ${#Packages[@]} ]]; then
    echo "Error"
    exit
  fi
}

function SearchForInstalled {
  #echo "-----------------------------------------------"
  for ThisPackageList in ${!Packages[*]}; do
    #echo "Packages: ${Packages[ThisPackageList]} | Desktop: ${Available[ThisPackageList]}"
    #Only search for installed kernels
    if [[ $(sh Functions.sh _isInstalled "$(echo ${Packages[ThisPackageList]} | sed -e 's/\s.*$//')") = 0 ]]; then
      Installed+=("${Available[ThisPackage]}")
    fi
  done
  echo "Installed:" ${Installed[*]} "| Length:" ${#Installed[@]}
  echo "-----------------------------------------------"
}

function GenerateMenuList {
  _temp_aval=()
  _temp_pack=()
  for ToDelete in ${Installed[@]}
  do
    for index in "${!Available[@]}"; do
      if [[ "${Available[$index]}" = "${ToDelete}" ]]; then
        unset 'Available[index]'
        unset 'Packages[index]'
      fi
    done
  done
  for i in "${!Available[@]}"; do
    _temp_aval+=("${Available[$i]}")
    _temp_pack+=("${Packages[$i]}")
  done
  Available=("${_temp_aval[@]}")
  Packages=("${_temp_pack[@]}")
  unset '_temp_aval'
  unset '_temp_pack'
}

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

#Gather required system information
ReadBootCFG
#ACTIVE_KERNEL
case $(uname -r) in
  *"ck"* ) echo "CK kernel";;
  *"lqx"* ) echo "Liquorix kernel";;
  * ) [[ $ACTIVE_KERNEL = *"lts"* ]] && ACTIVE_KERNEL="Longterm" || ACTIVE_KERNEL="Stable"
    ;;
esac
#DEFAULT_KERNEL
case $(sed -n "${VM_Linuz_default[1]}p" $BootFile | sed 's/.*\///' | sed 's/\s.*$//') in
  *"ck"* ) echo "CK kernel";;
  *"lqx"* ) echo "Liquorix kernel";;
  * ) [[ $DEFAULT_KERNEL = *"lts"* ]] && DEFAULT_KERNEL="Longterm" || DEFAULT_KERNEL="Stable"
    ;;
esac

#Set default kernel to load                                         UUID_Stash Set here ˇ
#sh Functions.sh ReplaceLineByNumber ${VM_Linuz_default[1]} "$(sed -n -e "${UUID_Stash[1]}p" $BootFile | sed 's/\//\\\//g' | cut -c 2-)" $BootFile
#Set default kernel to load                                         IMG_Stash Set here ˇ
#sh Functions.sh ReplaceLineByNumber ${VM_Linuz_default[2]} "$(sed -n -e "${IMG_Stash[1]}p" $BootFile | sed 's/\//\\\//g' | cut -c 2-)" $BootFile

#Menu
while [ "$INPUT_OPTION" != "end" ]
do
  #Boot stuff-------------------------------------------------------------------
  #echo "Available versions:" ${#Version_Stash[*]}
  #echo ""
  #echo "Default linux:" ${VM_Linuz_default[0]}
  #echo "UUID line number:" ${VM_Linuz_default[1]}
  #echo "IMG line number:" ${VM_Linuz_default[2]}
  #echo ""
  #echo "Version stash:" ${Version_Stash[*]}
  #echo "UUID stash:" ${UUID_Stash[*]}
  #echo "IMG stash:" ${IMG_Stash[*]}
  #echo ""
  #TEST
  #sed -n "${VM_Linuz_default[1]}p" $BootFile
  #sed -n "${IMG_Stash[1]}p" $BootFile
  #sed -n "${VM_Linuz_default[1]}p" $BootFile | sed 's/.*\///' | sed 's/\s.*$//'
  #-----------------------------------------------------------------------------
  Available=()
  Packages=()
  Installed=()
  SetDefaultLists
  SearchForInstalled
  #TEST---------------------------------------
  Installed+=("Longterm")
  #-------------------------------------------
  GenerateMenuList
  echo "MENU-------------------------------------------"
  echo "Available:" ${Available[*]} "| Length:" ${#Available[@]}
  echo "Packages:" ${Packages[*]} "| Length:" ${#Packages[@]}
  echo "-----------------------------------------------"
  if [[ ${#Installed[@]} = 1 ]]; then #One kernel
    echo "Currently using \"$ACTIVE_KERNEL\" kernel. (Press \"ESC\" to quit.)"
    echo "Available options:"
    for ThisEntry in "${!Available[@]}"; do #List menuentries
      echo "$(($ThisEntry + 1)). Install ${Available[ThisEntry]} kernel."
    done
    read -sn1 INPUT_OPTION
    if [[ $INPUT_OPTION = $'\e' ]]; then #Exit
      break
    elif ! [[ $INPUT_OPTION =~ ^[0-9]+$ ]]; then #Not number error
      echo "Not number!"
    elif [[ $INPUT_OPTION -gt $((${#Available[@]})) ]]; then #Invalid number error
      echo "Invalid number!"
    else #Install packages
      if ! [[ "${Available[$(($INPUT_OPTION - 1))]}" = *"(AUR)"* ]]; then #Pacman
        for ThisPackage in $(echo ${Packages[$(($INPUT_OPTION - 1))]} | tr ";" "\n")
        do
          #echo $ThisPackage
          sh Functions.sh InstallPackages $ThisPackage
        done
      else #Aurman
        for ThisPackage in $(echo ${Packages[$(($INPUT_OPTION - 1))]} | tr ";" "\n")
        do
          #echo $ThisPackage
          sh Functions.sh InstallAURPackages $ThisPackage
        done
      fi
      grub-mkconfig -o /boot/grub/grub.cfg
    fi
  else #More than one kernel
    echo "Currently using \"$ACTIVE_KERNEL\" kernel. (Press \"ESC\" to quit.)"
    echo "Booting with \"$DEFAULT_KERNEL\" kernel by default."
    echo "Available options:"
    echo "1. Set default kernel."
    for ThisEntry in "${!Available[@]}"; do #List menuentries
      echo "$(($ThisEntry + 2)). Install ${Available[ThisEntry]} kernel."
    done
    read -sn1 INPUT_OPTION
    if [[ $INPUT_OPTION = $'\e' ]]; then #Exit
      break
    elif ! [[ $INPUT_OPTION =~ ^[0-9]+$ ]]; then #Not number error
      echo "Not number!"
    elif [[ $INPUT_OPTION -gt $((${#Available[@]} + 1)) ]]; then #Invalid number error
      echo "Invalid number!"
    elif [[ $INPUT_OPTION = 1 ]]; then #Select default
      echo "Choose default kernel:"
      #UNDER DEVELOPMENT
      #INSTALLED DESKTOP LIST
      for ThisEntry in "${!Installed[@]}"; do
        echo "$(($ThisEntry + 1)). Set ${Installed[ThisEntry]} as default."
      done
      SetDefaultLists
      read -sn1 INPUT_OPTION
      SetAsDefault ${Installed[$(($INPUT_OPTION - 1))]}
    else #Install packages
      if ! [[ "${Available[$(($INPUT_OPTION - 2))]}" = *"(AUR)"* ]]; then #Pacman
        echo "Normal"
        #sh Functions.sh InstallPackages ${Packages[$(($INPUT_OPTION - 2))]}
      else #Aurman
        echo "AUR"
        #sh Functions.sh InstallAURPackages ${Packages[$(($INPUT_OPTION - 2))]}
      fi
      #grub-mkconfig -o /boot/grub/grub.cfg
    fi
  fi
read -sn1
clear
done
