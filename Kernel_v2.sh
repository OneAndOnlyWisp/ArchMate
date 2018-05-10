#!/bin/bash
#Local globals------------------------------------------------------------------
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"
BootFile="/boot/grub/grub.cfg"
Version_Stash=(); UUID_Stash=(); IMG_Stash=();
Available=(); Packages=(); Installed=();
DEFAULT_KERNEL=""; ACTIVE_KERNEL="";
#-------------------------------------------------------------------------------
#Useable from outside-----------------------------------------------------------
function GetDefaultKernel {
  temp="$(sed -n "${VM_Linuz_default[1]}p" $BootFile | sed 's/.*\/vmlinuz-//' | sed 's/\s.*$//') "
  for index in "${!Packages[@]}"; do #Default kernel to boot
    if [[ "${Packages[$index]}" = "$temp"* ]]; then
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
      if [[ "${Packages[$index]}" = *"$ACTIVE_KERNEL"* ]]; then
        echo ${Available[$index]}
        break
      fi
    done
  fi
  exit
}

#MOVE THIS TO NEW "GRAPHICS"
function CPUSuffix {
  CodeName=$(sh ""$Source_Path"Functions.sh" GetCodename)
  case $CodeName in
    "bonnell") CodeName="atom";;
    "pentium4") CodeName="p4";;
    "prescott") CodeName="p4";;
    "nocona") CodeName="p4";;
    "pentium-m") CodeName="pentm";;
    "athlon") CodeName="kx";;
    "athlon-4") CodeName="kx";;
    "athlon-tbird") CodeName="kx";;
    "athlon-mp") CodeName="kx";;
    "athlon-xp") CodeName="kx";;
    "k8-sse3") CodeName="kx";;
    "amdfam10") CodeName="k10";;
    "btver1") CodeName="bobcat";;
    "bdver1") CodeName="bulldozer";;
    "bdver2") CodeName="piledriver";;
    "znver1") CodeName="zen";;
  esac
  Legit=("atom" "silvermont" "core2" "nehalem" "sandybridge" "ivybridge" "haswell" "broadwell" "skylake" "p4" "pentm" "kx" "k10" "bobcat" "bulldozer" "piledriver" "zen")
  isLegit="false"
  for index in "${!Legit[@]}"; do
    if [[ "${Legit[index]}" = $CodeName ]]; then
      isLegit="true"
    fi
  done
  if [[ $isLegit = "true" ]]; then
    echo $CodeName
  else
    echo "generic"
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
  Available=(); Packages=(); Installed=();
  Available=("Stable" "Hardened" "Longterm" "Zen" "CK (AUR)")
  Packages=("linux linux-headers" "linux-hardened" "linux-lts linux-lts-headers" "linux-zen linux-zen-headers" "linux-ck-$(CPUSuffix) linux-ck-headers")
  if ! [[ ${#Available[@]} = ${#Packages[@]} ]]; then
    echo "Error"
    break
  fi
  DEFAULT_KERNEL="$(GetDefaultKernel)"
  ACTIVE_KERNEL=$(GetActiveKernel)
}

function SearchForInstalled {
  SetDefaultLists
  ReadBootCFG
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
#Kernel specific elements-------------------------------------------------------
function EnableCKrepository {
  StartingLine=$(sed -n '/\[repo-ck\]/=' /etc/pacman.conf)
  if [[ "$StartingLine" = "" ]]; then
    echo "" >> /etc/pacman.conf
    echo "[repo-ck]" >> /etc/pacman.conf
    echo "Server = http://repo-ck.com/\$arch" >> /etc/pacman.conf
    pacman-key -r 5EE46C4C && pacman-key --lsign-key 5EE46C4C
    pacman -Syy --noconfirm --quiet
  fi
}
#-------------------------------------------------------------------------------
#Set default kernel elements----------------------------------------------------
function ListKernelsFromBoot {
  SetDefaultLists
  for xindex in "${!Version_Stash[@]}"; do
    FindMe=$(sed -n "${UUID_Stash[xindex]}p" $BootFile | sed 's/.*\/vmlinuz-//' | sed 's/\s.*$//')
    for yindex in "${!Packages[@]}"; do
      if [[ "${Packages[$yindex]}" = "$FindMe "* ]]; then
        echo "$(($xindex + 1)). Set ${Available[$yindex]} as default."
      fi
    done
  done
}

function SetDefaultKernel {
  echo "Choose default kernel:"
  ListKernelsFromBoot
  read -sn1 SELECTED_OPTION
  if [[ $SELECTED_OPTION = $'\e' ]]; then
    return
  elif ! [[ $SELECTED_OPTION -gt $((${#Version_Stash[@]} + 1)) ]]; then
    SELECTED_OPTION=$(($SELECTED_OPTION - 1))
    #Set default kernel to load (UUID_Stash)
    ReplaceWith=$(sed -n -e "${UUID_Stash[$SELECTED_OPTION]}p" $BootFile | sed 's/\//\\\//g' | cut -c 2-)
    sed -ie "${VM_Linuz_default[1]}s/.*/$ReplaceWith/g" $BootFile
    #Set default kernel to load (IMG_Stash)
    ReplaceWith=$(sed -n -e "${IMG_Stash[$SELECTED_OPTION]}p" $BootFile | sed 's/\//\\\//g' | cut -c 2-)
    sed -ie "${VM_Linuz_default[2]}s/.*/$ReplaceWith/g" $BootFile
  fi
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

function CheckAnswer {
  if [[ $SELECTED_OPTION = $'\e' ]]; then
    echo "exit"
    exit
  elif ! [[ $SELECTED_OPTION =~ ^[0-9]+$ ]]; then
    printf "Not number!\n"
    echo "-1"
  elif [[ $SELECTED_OPTION -gt $((${#Available[@]})) ]]; then
    printf "Invalid number!\n"
    echo "-1"
  else
    echo $(($SELECTED_OPTION - 1))
  fi
}

function InstallKernel {
  if [[ ${Available[$1]} = *"CK"* ]]; then
    EnableCKrepository
  fi
  for Package in $(echo ${Packages[$1]} | tr ";" "\n")
  do
    sh ""$Source_Path"Functions.sh" InstallPackages $Package
  done
  grub-mkconfig -o /boot/grub/grub.cfg
}

function OneKernel {
  echo "Available options:"
  ListAvailableItems
  read -sn1 KEY_PRESS
  ChoosenItem=$(CheckAnswer $KEY_PRESS)
  if [[ $ChoosenItem -ge 0 ]]; then
    InstallKernel $ChoosenItem
  fi
}

function MultipleKernel {
  echo "Booting with \"$DEFAULT_KERNEL\" kernel by default."
  echo "Available options:"
  echo "1. Set default kernel."
  ListAvailableItems 2
  read -sn1 KEY_PRESS
  ChoosenItem=$(CheckAnswer $KEY_PRESS)
  echo $(CheckAnswer $KEY_PRESS)
  if [[ $ChoosenItem -ge 0 ]]; then
    if [[ $ChoosenItem = 0 ]]; then
      SetDefaultKernel
    else
      InstallKernel $(($ChoosenItem - 1))
    fi
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
#User interface-----------------------------------------------------------------
while [ "$INPUT_OPTION" != "end" ]
do
  #clear
  GenerateMenuElements
  echo "${Installed[*]}"
  DrawMenu
done
#-------------------------------------------------------------------------------
#Post-script area---------------------------------------------------------------
function CheckForReboot {
  ReadBootCFG
  SetDefaultLists
  if ! [[ "$ACTIVE_KERNEL" = "$DEFAULT_KERNEL" ]]; then
    if ! [[ "$DEFAULT_KERNEL" = "Stable" ]]; then
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
  exit
}
#CheckForReboot

function RestartSync {
  #Read current boot information
  KEEP_KERNEL="$(GetDefaultKernel)"
  #Reconfigure grub
  grub-mkconfig -o /boot/grub/grub.cfg
  ReadBootCFG
  SetDefaultLists
  #Find the package name of kernel to keep
  if ! [[ "$KEEP_KERNEL" = "$DEFAULT_KERNEL" ]]; then
    for index in "${!Available[@]}"; do
      echo ${Available[$index]}
      if [[ "${Available[$index]}" = "$KEEP_KERNEL" ]]; then
        KEEP_KERNEL=$(echo ${Packages[$index]} | sed 's/\s.*$//')
        break
      fi
    done
    #Find entry in bootlader for the kernel to keep
    for index in "${!Version_Stash[@]}"; do #Linux images(kernel) list
      LinuxVersion=$(sed -n "${UUID_Stash[index]}p" $BootFile | sed 's/.*\/vmlinuz-//' | sed 's/\s.*$//')
      if [[ "$KEEP_KERNEL" = "$LinuxVersion" ]]; then
        echo "OK"
        #SetAsDefault $index
      fi
    done
  fi
  exit
}
#-------------------------------------------------------------------------------


"$@"
