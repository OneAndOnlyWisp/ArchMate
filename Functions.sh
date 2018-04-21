#!/bin/sh

function Init {
	#Check and add .bashrc for root
	! [ -e ~root/.bashrc ] && cp /etc/skel/.bash* ~root || echo "Root .bashrc found."
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

#AUR package manager
function GetAurman {
  #AUR packages default dependancy
  pacman -S --needed --noconfirm --noprogressbar --quiet base-devel
  #Git clone the package
  git clone https://aur.archlinux.org/aurman.git
  #Enter PACKAGE directory
  cd aurman
  #Install package
  makepkg -si --noconfirm --noprogressbar
}

#Helper functions---------------------------------------------------------------
function FindAndReplaceAll {
  sed "s/""$1""/""$2""/g" $3
}

function ReplaceLineByNumber {
  sed -n "$1s/.*/$2/p" $3
}
#-------------------------------------------------------------------------------

"$@"
