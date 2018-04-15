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
		echo "Autostart Off."
		sed -ie '/^ArchMate/,+2d' ~root/.bashrc
		sed -i -e :a -e '/^\n*$/{$d;N};/\n$/ba' ~root/.bashrc
	else
		echo "Autostart On."
		echo $'\n'"ArchMate=\"$1\""$'\n'"sh \$ArchMate" >> ~root/.bashrc
	fi
}

"$@"
