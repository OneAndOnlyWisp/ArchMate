#!/bin/sh

function Init {
	#Check and add .bashrc for root
	! [ -e ~root/.bashrc ] && cp /etc/skel/.bash* ~root
	#Read or create ini file
	if ! [ -e ArchMate.ini ]; then
		#Create
	  echo "TurnMeOff=false" > ArchMate.ini
	else
		#Read
		TurnMeOff=$(sed 's:.*TurnMeOff=::' ArchMate.ini)
	  case "$TurnMeOff" in
	    "true" )
				if grep -q "ArchMate" ~root/.bashrc; then
					AutoStartSwitch
				fi
				;;
			"false" )
				#Nothing for now
	      ;;
			* )
				echo "TurnMeOff=false" > ArchMate.ini
				;;
	  esac
	fi
}

function AutoStartSwitch {
	if grep -q "ArchMate" ~root/.bashrc; then
		sed -ie '/^ArchMate/,+2d' ~root/.bashrc
		sed -i -e :a -e '/^\n*$/{$d;N};/\n$/ba' ~root/.bashrc
		echo "Autostart Off."
	else
		echo $'\n'"ArchMate=\"$1\""$'\n'"sh \$ArchMate" >> ~root/.bashrc
		echo "Autostart On."
	fi
}

function InstallSUDO {
  #Install sudo
  pacman -S --noconfirm sudo
  #Allow admin rigths for wheel group
  FindAndReplaceAll "# %wheel ALL=(ALL) ALL" "%wheel ALL=(ALL) ALL" /etc/sudoers | sudo EDITOR='tee' visudo
}

function IntelCodename {
	set -euo pipefail

	if [[ $# == 0 ]]; then
	    modelname=$(cat /proc/cpuinfo | grep 'model name' | head -1)
	    if ! grep Intel <<<"$modelname" > /dev/null; then
	        echo "You don't seem to have an Intel processor" >&2
	        exit 1
	    fi

	    name=$(sed 's/.*\s\(\S*\) CPU.*/\1/' <<<"$modelname")
	    echo "Processor name: $name" >&2
	else
	    name=$1
	fi

	links=($(curl --silent "https://ark.intel.com/search?q=$name" | pup '.result-title a attr{href}'))

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

#UNDER DEVELOPMENT--NOT WORKING YET
#AUR package manager
function GetAurman {
  #AUR packages default dependancy
  pacman -S --needed --noconfirm base-devel
  #Git clone the package
	if ! git clone https://aur.archlinux.org/aurman.git; then
		if ! git pull https://aur.archlinux.org/aurman.git; then
			clear
		  echo "Failed to sync with repository!"
		fi
	fi
  #Enter PACKAGE directory
  #cd aurman
  #Install package
  #makepkg -si --noconfirm
}

#Helper functions---------------------------------------------------------------
function FindAndReplaceAll {
  sed -ni "s/""$1""/""$2""/g" $3
}

function ReplaceLineByNumber {
  sed -ni "$1s/.*/$2/p" $3
}
#-------------------------------------------------------------------------------

"$@"
