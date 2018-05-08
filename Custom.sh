#!/bin/sh
clear
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"
cat /etc/sudoers | grep -o '%wheel ALL=(ALL) ALL.*'
if [[ $(sh ""$Source_Path"Functions.sh" _isInstalled "sudo") = 0 ]]; then
  cat /etc/sudoers | grep -o '# %wheel ALL=(ALL) ALL.*'
  if ! [[ $(cat /etc/sudoers | grep -o '# %wheel ALL=(ALL) ALL.*') = "" ]]; then
    echo "OK"
    #Allow admin rigths for wheel group
    #sh ""$Source_Path"Functions.sh" FindAndReplaceAll "# %wheel ALL=(ALL) ALL" "%wheel ALL=(ALL) ALL" /etc/sudoers | sudo EDITOR='tee' visudo
  fi
fi
read -sn1
exit
#sed -ni "s/""$1""/""$2""/g" $3

exit

#Custom apps
pacman -S --noconfirm konsole dolphin chromium atom transmission-qt sddm
#Apply services
systemctl enable sddm.service

#Revert changes to makepkg
cp ""$Source_Path"Assets/SysBU/makepkgBU" /usr/bin/makepkg

#Restart
reboot

echo "Done!"
read -sn1
