#!/bin/sh
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"

#Gather required system information
GPU=$(lspci | grep -o 'VGA compatible controller: .*' | sed 's/.*: //') #Most likely need a rework later on!!!
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
  Available=("NVIDIA" "AMD" "VirtualBox")
  Packages=("nvidia" "xf86-video-ati" "virtualbox-guest-utils")
  if ! [[ ${#Available[@]} = ${#Packages[@]} ]]; then
    echo "Error"
    exit
  fi
}

function SearchForInstalled {
  for ThisPackageList in ${!Packages[*]}; do
    if [[ $(sh ""$Source_Path"Functions.sh" _isInstalled "${Packages[ThisPackageList]}") = 0 ]]; then
      Installed+=("${Available[ThisPackageList]}")
    fi
  done
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
        MenuFIX $yindex
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
