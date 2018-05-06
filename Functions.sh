#!/bin/sh
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"

#Helper functions---------------------------------------------------------------
#Find and replace all match
# $1=ReplaceThis $2=ReplaceWith $3=Input
function FindAndReplaceAll {
  sed -ni "s/""$1""/""$2""/g" $3
}

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

#Install packages if not installed already
# $@PackageNames
function InstallPackages {
    # The packages that are not installed will be added to this array.
    toInstall=();

    for pkg; do
        # If the package IS installed, skip it.
        if [[ $(_isInstalled "${pkg}") == 0 ]]; then
            echo "${pkg} is already installed.";
            continue;
        fi;

        #Otherwise, add it to the list of packages to install.
        toInstall+=("${pkg}");
    done;

    # If no packages were added to the "${toInstall[@]}" array,
    #     don't do anything and stop this function.
    if [[ "${toInstall[@]}" == "" ]] ; then
        echo "All packages are already installed.";
        return;
    fi;

    # Otherwise, install all the packages that have been added to the "${toInstall[@]}" array.
    printf "Packages not installed:\n%s\n" "${toInstall[@]}";
    pacman -S --noconfirm --quiet "${toInstall[@]}";
}

#Install AUR packages if not installed already
# $@PackageNames
function InstallAURPackages {
    #If Aurman is not installed
    if ! [[ $(_isInstalled "aurman") == 0 ]]; then
        InstallAurman;
    fi;
    # The packages that are not installed will be added to this array.
    toInstall=();

    for pkg; do
        # If the package IS installed, skip it.
        if [[ $(_isInstalled "${pkg}") == 0 ]]; then
            echo "${pkg} is already installed.";
            continue;
        fi;

        #Otherwise, add it to the list of packages to install.
        toInstall+=("${pkg}");
    done;

    # If no packages were added to the "${toInstall[@]}" array,
    #     don't do anything and stop this function.
    if [[ "${toInstall[@]}" == "" ]] ; then
        echo "All packages are already installed.";
        return;
    fi;

    # Otherwise, install all the packages that have been added to the "${toInstall[@]}" array.
    printf "Packages not installed:\n%s\n" "${toInstall[@]}";
    if [[ $(_isInstalled aurman) == 0 ]]; then
        aurman -S --noconfirm "${toInstall[@]}";
    fi;
}
#-------------------------------------------------------------------------------

function Init {
	#Check and add .bashrc for root
	! [ -e ~root/.bashrc ] && cp /etc/skel/.bash* ~root
	#Ini file
	if ! [ -e ""$Source_Path"ArchMate.ini" ]; then #Create
	  echo "TurnMeOff=false" > ""$Source_Path"ArchMate.ini"
	else #Read
		TurnMeOff=$(sed 's:.*TurnMeOff=::' ""$Source_Path"ArchMate.ini")
    if [[ "$TurnMeOff" = "true" ]]; then
      if grep -q "ArchMate" ~root/.bashrc; then
        AutoStartSwitch
      fi
    fi
    echo "TurnMeOff=false" > ""$Source_Path"ArchMate.ini"
	fi
  if [[ $(lscpu | sed -n 's/^Model name:[[:space:]]*//p') = *"Intel"* ]]; then #Microcode for Intel CPUs
    if ! [[ $(_isInstalled "intel-ucode") == 0 ]]; then
      pacman -S --noconfirm --quiet "intel-ucode"
      grub-mkconfig -o /boot/grub/grub.cfg
    fi
  fi
  if ! [[ $(cat /usr/bin/makepkg | grep -o 'asroot') ]]; then #Allow makepkg to run as root
    cp /usr/bin/makepkg /home/wisp/ArchMate/Assets/SysBU/makepkgBU
    cp /home/wisp/ArchMate/Assets/makepkg /usr/bin/makepkg
    if [[ $(cat /usr/bin/makepkg | grep -o 'asroot') ]]; then
      echo "makepkg patch succes!"
    fi
  fi
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

#Returns Intel microarchitecture codename
function IntelCodename {
	set -euo pipefail

	if [[ $# == 0 ]]; then
	    modelname=$(cat /proc/cpuinfo | grep 'model name' | head -1)
	    if ! grep Intel <<<"$modelname" > /dev/null; then
	        echo "You don't seem to have an Intel processor" >&2
	        exit 1
	    fi
	    name=$(sed 's/.*\s\(\S*\) CPU.*/\1/' <<<"$modelname")
	else
	    name=$1
	fi

	links=($(curl --silent "https://ark.intel.com/search?q=$name" | pup 'a attr{href}'))

	results=${#links[@]}
	if [[ $results == 0 ]]; then
	    echo "No results found" >&2
	    exit 1
	fi

	link=${links[0]}
	if [[ $results != 1 ]]; then
	    echo "Warning: $results results found" >&2
	    echo "Using: $link" >&2
	fi

	url="https://ark.intel.com$link"
	codename=$(curl --silent "$url" | pup '.CodeNameText .value text{}' | xargs | sed 's/Products formerly //')

	echo "$codename"
}

#AUR package manager
function InstallAurman {
  #AUR packages default dependancy
  if ! [[ $(_isInstalled "base-devel") == 0 ]]; then
    pacman -Sy --needed --noconfirm base-devel
  fi
  #Git clone the package
  cd $HOME
  if ! [[ -d aurman ]]; then
    git clone https://aur.archlinux.org/aurman.git
    cd aurman
  else
    cd aurman
    git fetch https://aur.archlinux.org/aurman.git
    git checkout master
  fi
  #Install package
  makepkg -si --noconfirm
}


"$@"
