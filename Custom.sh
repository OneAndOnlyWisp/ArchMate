#!/bin/sh
clear

sh Functions.sh InstallAURPackages pup-git
if ! [[ $(pacman -Qs aurman) = "" ]]; then
  sudo pacman -Rs --noconfirm aurman
fi
if ! [[ $(pacman -Qs pup-git) = "" ]]; then
  sudo pacman -Rs --noconfirm pup-git
fi
#Custom apps
#pacman -S --noconfirm konsole dolphin chromium atom sddm
#Apply services
#systemctl enable sddm.service

echo "Done!"
read -sn1

#ACTIVE_KERNEL
case  in
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
echo "ok"
