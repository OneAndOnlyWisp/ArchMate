#!/bin/sh
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"

#Helper functions---------------------------------------------------------------

#Check if a package is installed
# $1=PackageName
function _isInstalled {
    package="$1";
    check="$(pacman -Qs --color always "${package}" | grep "local" | grep "${package} ")";
    if [ -n "${check}" ] ; then
        echo 0; #'0' means 'true' in Bash
        return; #true
    fi;
    echo 1; #'1' means 'false' in Bash
    return; #false
}

#Install packages from AUR repository
function InstallFromAUR {
  #The packages that are not installed will be added to this array.
  toInstall=();
  #Loop through packages
  for pkg; do
      # If the package IS installed, skip it.
      if [[ $(_isInstalled "${pkg}") == 0 ]]; then
          echo "${pkg} is already installed."
          continue
      fi
      #Otherwise, add it to the list of packages to install.
      toInstall+=("${pkg}")
  done
  #Install missing packages
  for index in "${!toInstall[@]}"; do
    cd $HOME
    echo ""
    #Git clone the package
    if ! [[ -d ${toInstall[$index]} ]]; then
      git clone "https://aur.archlinux.org/${toInstall[$index]}.git"
      if [[ "$(ls -A "${toInstall[$index]}" | wc -l)" < 2 ]]; then
        echo "Package not found on AUR repository: ${toInstall[$index]}"
        rm -rf "${toInstall[$index]}"
        continue
      else
        cd ${toInstall[$index]}
      fi
    else
      cd ${toInstall[$index]}
      git pull
    fi
    makepkg -Si --noconfirm; #Install
    cd $HOME; rm -rf "${toInstall[$index]}"; #Remove source
  done
}

#Returns CPU microarchitecture codename
function GetCodename {
  Codename=$(gcc -c -Q -march=native --help=target | grep march | grep -oE '[^ ]+$')
  echo $Codename
}

#Switch to turn on/off autostart
function AutoStartSwitch {
	if grep -q "ArchMate" ~root/.bashrc; then
		sed -ie '/^ArchMate/,+2d' ~root/.bashrc
		sed -i -e :a -e '/^\n*$/{$d;N};/\n$/ba' ~root/.bashrc
		echo "Autostart Off."
	else
		echo $'\n'"ArchMate=\""$Source_Path"Main.sh\""$'\n'"sh \$ArchMate" >> ~root/.bashrc
		echo "Autostart On."
	fi
}

#-------------------------------------------------------------------------------
#Init functions-----------------------------------------------------------------

#Check if using Oracle VirtualBox (might need a rework)
function VirtualBox {
  if [[ $(lspci | grep -o 'VGA compatible controller: .*' | sed 's/.*: //') = *"VirtualBox"* ]]; then
    if ! [[ $(_isInstalled "virtualbox-guest-utils") == 0 ]]; then
      pacman -S --noconfirm --quiet virtualbox-guest-utils
    fi
    return 0
  else
    return 1
  fi
}

#Install microcode for intel CPU
function Microcode {
  if [[ $(lscpu | sed -n 's/^Model name:[[:space:]]*//p') = *"Intel"* ]]; then
    if ! [[ $(_isInstalled "intel-ucode") == 0 ]]; then
      pacman -S --noconfirm --quiet intel-ucode
      grub-mkconfig -o /boot/grub/grub.cfg
    fi
  fi
}

#Allow makepkg to run as root
function MakePKG_Patch {
  pacman -Sy --needed --noconfirm base-devel; #Install base-devel for makepkg usage
  #Allow makepkg to run as root
  if ! [[ $(cat /usr/bin/makepkg | grep -o 'asroot') ]]; then
    cp /usr/bin/makepkg ""$Source_Path"patches/makepkg_BU"
    cp ""$Source_Path"patches/makepkg" /usr/bin/makepkg
    if [[ $(cat /usr/bin/makepkg | grep -o 'asroot') ]]; then
      echo "makepkg patch succes!"
    fi
  fi
}

function Init {
  #Turn off automatic start on login
	if [ -e ""$Source_Path"autostart" ]; then
    if grep -q "ArchMate" ~root/.bashrc; then
      AutoStartSwitch
    fi
	fi
  #Remove default "Stable" kernel
  if [[ -e ""$Source_Path"removekernel" ]]; then
    pacman -Rs --noconfirm linux-headers
    pacman -Rs --noconfirm linux
    echo "Executing RestartSync..."
    sh ""$Source_Path"Kernel.sh" RestartSync
    rm ""$Source_Path"removekernel"
  fi
  #Install microcode for Intel CPU
  if ! [[ VirtualBox ]]; then
    Microcode
  fi
  #Allow makepkg to run as root
  MakePKG_Patch
}

#-------------------------------------------------------------------------------

"$@"
