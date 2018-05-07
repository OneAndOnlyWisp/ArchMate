#!/bin/bash
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"

#Grub config file
BootFile="/boot/grub/grub.cfg"

function ReadBootCFG {
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
  #Available options
  Available=("Stable" "Longterm" "Zen" "CK (AUR)")
  Packages=("linux linux-headers" "linux-lts linux-lts-headers" "linux-zen linux-zen-headers" "linux-ck linux-ck-headers")
  if ! [[ ${#Available[@]} = ${#Packages[@]} ]]; then
    echo "Error"
    break
  fi
  #Default kernel
  DEFAULT_KERNEL="$(sed -n "${VM_Linuz_default[1]}p" $BootFile | sed 's/.*\/vmlinuz-//' | sed 's/\s.*$//') "
  for index in "${!Packages[@]}"; do #Default kernel to boot
    if [[ "${Packages[$index]}" = "$DEFAULT_KERNEL"* ]]; then
      DEFAULT_KERNEL=${Available[$index]}
    fi
  done
  #Active kernel
  ACTIVE_KERNEL=$(uname -r | rev | cut -d "-" -f 1 | rev)
  if [[ "$ACTIVE_KERNEL" = "ARCH" ]]; then
    ACTIVE_KERNEL="Stable"
  else
    for index in "${!Packages[@]}"; do
      if [[ "${Packages[$index]}" = *"$ACTIVE_KERNEL"* ]]; then
        ACTIVE_KERNEL=${Available[$index]}
      fi
    done
  fi
}

function SearchForInstalled {
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

function GenerateMenuList {
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

function SetAsDefault {
  #Set default kernel to load (UUID_Stash)
  ReplaceWith=$(sed -n -e "${UUID_Stash[$1]}p" $BootFile | sed 's/\//\\\//g' | cut -c 2-)
  sed -ie "${VM_Linuz_default[1]}s/.*/$ReplaceWith/g" $BootFile
  #Set default kernel to load (IMG_Stash)
  ReplaceWith=$(sed -n -e "${IMG_Stash[$1]}p" $BootFile | sed 's/\//\\\//g' | cut -c 2-)
  sed -ie "${VM_Linuz_default[2]}s/.*/$ReplaceWith/g" $BootFile
}

#Menu
while [ "$INPUT_OPTION" != "end" ]
do
  #Boot stuff---------------------------------
  Version_Stash=()
  UUID_Stash=()
  IMG_Stash=()
  ReadBootCFG
  #-------------------------------------------
  #MENU---------------------------------------
  Available=()
  Packages=()
  Installed=()
  SetDefaultLists
  SearchForInstalled
  GenerateMenuList
  #-------------------------------------------
  clear
  #UI
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
      for ThisPackage in $(echo ${Packages[$(($INPUT_OPTION - 1))]} | tr ";" "\n")
      do
        #echo $ThisPackage
        sh ""$Source_Path"Functions.sh" InstallPackages $ThisPackage
      done
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
      SetDefaultLists
      echo "Choose default kernel:"
      for xindex in "${!Version_Stash[@]}"; do #Linux images(kernel) list
        FindMe=$(sed -n "${UUID_Stash[xindex]}p" $BootFile | sed 's/.*\/vmlinuz-//' | sed 's/\s.*$//')
        for yindex in "${!Packages[@]}"; do
          if [[ "${Packages[$yindex]}" = "$FindMe "* ]]; then
            echo "$(($xindex + 1)). Set ${Available[$yindex]} as default."
          fi
        done
      done
      read -sn1 INPUT_OPTION
      if ! [[ $INPUT_OPTION -gt $((${#Version_Stash[@]} + 1)) ]]; then
        SetAsDefault $(($INPUT_OPTION - 1))
      fi
    else #Install packages
      for ThisPackage in $(echo ${Packages[$(($INPUT_OPTION - 2))]} | tr ";" "\n")
      do
        #echo $ThisPackage
        sh ""$Source_Path"Functions.sh" InstallPackages $ThisPackage
      done
      grub-mkconfig -o /boot/grub/grub.cfg
    fi
  fi
done

#Autostart if ( ACTIVE_KERNEL != DEFAULT_KERNEL )
ReadBootCFG
SetDefaultLists
if ! [[ "$ACTIVE_KERNEL" = "$DEFAULT_KERNEL" ]]; then
  if ! [[ "$ACTIVE_KERNEL" = "Stable" ]]; then
    while [ "$Security_Q" != "end" ]
    do
      echo "Do you want to keep the default \"Stable\" kernel?"
      read Security_Q
      case $Security_Q in
        "no" ) echo "KeepStableKernel=false" > ""$Source_Path"autostart.conf"; break;;
        "yes") break;;
        * ) echo "Invalid answer!";;
      esac
    done
  fi
  if ! grep -q "ArchMate" ~root/.bashrc; then
    sh ""$Source_Path"Functions.sh" AutoStartSwitch
    echo "TurnMeOff=true" > ""$Source_Path"ArchMate.ini"
    reboot
  fi
fi
