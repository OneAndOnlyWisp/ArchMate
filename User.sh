#!/bin/sh

#later on read this value from input
isAuto="false"

while [ "$INPUT_OPTION" != "end" ]
do
  clear
  User_Count=$(sed -n '/\/bin\/bash/p' /etc/passwd | cut -d: -f1 | wc -l)
  if [[ $User_Count = 1 ]]; then
    echo "Only \"$(sed -n '/\/bin\/bash/p' /etc/passwd | cut -d: -f1)\" (Press \"ESC\" to go back.)"
  else
    echo "This system has $User_Count users. (Press \"ESC\" to go back.)"
  fi
  echo "Available User options:"
  echo "1. List users"
  echo "2. Add Admin user"
  echo "3. Add normal user"
  echo "4. Remove user"
  read -sn1 INPUT_OPTION

  case $INPUT_OPTION in
    '1') clear; sed -n '/\/bin\/bash/p' /etc/passwd | cut -d: -f1; read -sn1;;
    '2')
      if [[ $isAuto = "false" ]]; then
        echo "Are you sure about that? yes|no"
        read Security_Q
        if [[ $Security_Q = "yes" ]]; then
          printf 'Type selected username: '
          read -r Username
          #Install sudo
          echo "sudo"
          #pacman -S --noconfirm sudo
          #Allow admin rigths for wheel group
          echo "rigths"
          #FindAndReplaceAll "# %wheel ALL=(ALL) ALL" "%wheel ALL=(ALL) ALL" /etc/sudoers | sudo EDITOR='tee' visudo
          #Create user
          useradd -m -g users -G wheel -s /bin/bash $Username
          #Set password
          passwd $Username
        fi
      else
        echo "under dev"
        #Install sudo
        #pacman -S --noconfirm sudo
        #Allow admin rigths for wheel group
        #FindAndReplaceAll "# %wheel ALL=(ALL) ALL" "%wheel ALL=(ALL) ALL" /etc/sudoers | sudo EDITOR='tee' visudo
        #Create user
        #useradd -m -g users -G wheel -s /bin/bash wisp
        #Set password
        #echo "user:pass" | chpasswd
        #passwd wisp
      fi
      ;;
    '3') echo "under development";;
    '4')
      echo "Are you sure about that? yes|no"
      read Security_Q
      if [[ $Security_Q = "yes" ]]; then
        printf 'Type username: '
        read -r Username
        killall -KILL -u $Username
        #crontab -r -u $Username #Dont think its neccessary
        userdel -r $Username
      fi

      ;;
    $'\e') break;;
  esac
done
