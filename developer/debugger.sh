#!/bin/sh
clear;
#-------------------------------------------------------------------------------
#Install debugger---------------------------------------------------------------
pacman -S --noconfirm gdb;
#Install pip for Python---------------------------------------------------------
pacman -S --noconfirm python-pip;
#Install GDB for all user separately--------------------------------------------
sed -n '/\/bin\/bash/p' /etc/passwd | cut -d: -f1 | while read -r username; do
  if ! [[ $username = "root" ]]; then
    #Install gdbgui
    pip install -t /home/$username/.local/V_ENV gdbgui;
    #Add gdbgui to path
    echo "
export PATH=\$PATH:/home/$username/.local/V_ENV/bin" >> /home/$username/.bashrc
  fi
done
#-------------------------------------------------------------------------------
