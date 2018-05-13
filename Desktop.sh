#Local globals------------------------------------------------------------------
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"
Available=(); Packages=(); AutostartScripts=(); Installed=();
#-------------------------------------------------------------------------------
#Helper functions area----------------------------------------------------------
function SetAsDefault {
  for index in "${!Available[@]}"; do
    if [[ "${Available[$index]}" = "$1" ]]; then
      echo "exec ${AutostartScripts[$index]}" > ~/.xinitrc
    fi
  done
}

function CheckDependancy {
  #Init "Multimedia engine" (Audio + Window system)
  sh ""$Source_Path"Functions.sh" InstallPackages "pulseaudio"
  sh ""$Source_Path"Functions.sh" InstallPackages "pulseaudio-alsa"
  sh ""$Source_Path"Functions.sh" InstallPackages "xorg" "xorg-xinit"
  sh ""$Source_Path"Functions.sh" InstallPackages "xorg-xinit"
}
#-------------------------------------------------------------------------------
#Menu item generation elements--------------------------------------------------
function SetDefaultLists {
  Available=(); Packages=(); AutostartScripts=();
  #Available options
  Available=("Plasma" "Gnome" "Budgie" "Lumina (AUR)")
  Packages=("plasma-desktop" "gnome" "budgie-desktop" "lumina-desktop")
  AutostartScripts=("startkde" "gnome-session" "budgie-desktop" "start-lumina-desktop")
  if ! [[ ${#Available[@]} = ${#Packages[@]} ]]; then
    echo "Error"
    exit
  fi
}

function SearchForInstalled {
  SetDefaultLists
  Installed=()
  for index in ${!Packages[*]}; do
    #echo ${Packages[index]}
    [[ $(sh ""$Source_Path"Functions.sh" _isInstalled "${Packages[index]}") = 0 ]] && Installed+=("${Available[index]}")
  done
}

function GenerateMenuElements {
  SearchForInstalled
  _temp_aval=()
  _temp_pack=()
  _temp_exec=()
  for xindex in "${!Installed[@]}"; do
    for yindex in "${!Available[@]}"; do
      if [[ "${Available[$yindex]}" = "${Installed[$xindex]}" ]]; then
        unset 'Available[yindex]'
        unset 'Packages[yindex]'
        unset 'AutostartScripts[yindex]'
      fi
    done
  done
  for index in "${!Available[@]}"; do
    _temp_aval+=("${Available[$index]}")
    _temp_pack+=("${Packages[$index]}")
    _temp_exec+=("${AutostartScripts[$index]}")
  done
  Available=("${_temp_aval[@]}")
  Packages=("${_temp_pack[@]}")
  AutostartScripts=("${_temp_exec[@]}")
  unset '_temp_aval'
  unset '_temp_pack'
  unset '_temp_exec'
}
#-------------------------------------------------------------------------------
#Set default desktop elements---------------------------------------------------
function ListInstalledDesktops {
  for ThisEntry in "${!Installed[@]}"; do #Installed desktops list
    echo "$(($ThisEntry + 1)). Set ${Installed[ThisEntry]} as default."
  done
}

function SetDefaultDesktop {
  SearchForInstalled
  clear
  echo "Choose default desktop:"
  ListInstalledDesktops
  read -sn1 KEY_PRESS
  if ! [[ $KEY_PRESS = $'\e' ]]; then
    if [[ $KEY_PRESS =~ ^[0-9]+$ ]]; then
      if [[ $KEY_PRESS -le ${#Installed[@]} ]] && [[ $KEY_PRESS -ne 0 ]]; then
        KEY_PRESS=$(($KEY_PRESS - 1))
        SetAsDefault ${Installed[$KEY_PRESS]}
        echo "Succesfully set ${Installed[$KEY_PRESS]} desktop as default."
      else
        echo "Invalid number!"
      fi
      read -sn1
    fi
  fi
}
#-------------------------------------------------------------------------------
#Draw menu elements-------------------------------------------------------------
function ListAvailableItems {
  #List menuentries
  if [[ "$1" = "" ]]; then
    for index in "${!Available[@]}"; do
      echo "$(($index + 1)). Install ${Available[index]} desktop."
    done
  else
    for index in "${!Available[@]}"; do
      echo "$(($index + $1)). Install ${Available[index]} desktop."
    done
  fi
}

function SimpleDesktop {
  echo "Available options:"
  ListAvailableItems
  read -sn1 KEY_PRESS
  if ! [[ $KEY_PRESS = $'\e' ]]; then
    if [[ $KEY_PRESS =~ ^[0-9]+$ ]]; then
      if [[ $KEY_PRESS -le ${#Available[@]} ]]; then
        KEY_PRESS=$(($KEY_PRESS - 1))
        sh ""$Source_Path"Functions.sh" InstallPackages ${Packages[$KEY_PRESS]}
        SetAsDefault ${Available[$KEY_PRESS]}
      fi
    fi
  else
    exit
  fi
}

function MultipleDesktops {
  echo "Available options:"
  echo "1. Set default desktop."
  ListAvailableItems 2
  read -sn1 KEY_PRESS
  if ! [[ $KEY_PRESS = $'\e' ]]; then
    if [[ $KEY_PRESS =~ ^[0-9]+$ ]]; then
      if [[ $KEY_PRESS -le $((${#Available[@]} + 1)) ]]; then
        KEY_PRESS=$(($KEY_PRESS - 1))
        if [[ $KEY_PRESS = 0 ]]; then
          SetDefaultDesktop
        else
          KEY_PRESS=$(($KEY_PRESS - 1))
          sh ""$Source_Path"Functions.sh" InstallPackages ${Packages[$KEY_PRESS]}
          SetAsDefault ${Available[$KEY_PRESS]}
        fi
      fi
    fi
  else
    exit
  fi
}

function DrawMenu {
  if [[ ${#Installed[@]} = 0 ]] || [[ ${#Installed[@]} = 1 ]]; then
    if [[ ${#Installed[@]} = 0 ]]; then
      echo "No desktops installed on this system. (Press \"ESC\" to quit.)"
    else
      echo "${Installed[0]} desktop is already installed on this system. (Press \"ESC\" to quit.)"
    fi
    SimpleDesktop
  else
    echo "Multiple desktops are installed on this system. (Press \"ESC\" to quit.)"
    MultipleDesktops
  fi
}
#-------------------------------------------------------------------------------
#User interface-----------------------------------------------------------------
while [ "$INPUT_OPTION" != "end" ]; do
  clear
  GenerateMenuElements
  DrawMenu
done
