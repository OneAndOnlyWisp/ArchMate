#!/bin/sh

#later on read this value from input
isAuto="false"
needSUDO="false"
if [[ $isAuto = "true" ]] && [[ $needSUDO = "true" ]]; then
  sh Functions.sh InstallPackages "sudo"
  FindAndReplaceAll "# %wheel ALL=(ALL) ALL" "%wheel ALL=(ALL) ALL" /etc/sudoers | sudo EDITOR='tee' visudo
fi

function CreateUser {
  if [[ $needSUDO = "true" ]]; then
    sh Functions.sh InstallPackages "sudo"
    #Allow admin rigths for wheel group
    FindAndReplaceAll "# %wheel ALL=(ALL) ALL" "%wheel ALL=(ALL) ALL" /etc/sudoers | sudo EDITOR='tee' visudo
    needSUDO="false"
  fi
  if [[ $isAuto = "false" ]]; then
    if [[ $1 = "admin" ]]; then
      echo "Are you sure about that? yes|no"
      read Security_Q
      if [[ $Security_Q = "yes" ]]; then
        printf 'Type selected username: '
        read -r Username
        useradd -m -g users -G wheel -s /bin/bash $Username
        passwd $Username
      fi
    else
      useradd -m -g users -s /bin/bash $Username
      passwd $Username
    fi

  else
    if [[ $1 = "admin" ]]; then
      useradd -m -g users -G wheel -s /bin/bash $2
      echo "$2:$3" | chpasswd
    else
      useradd -m -g users -s /bin/bash $2
      echo "$2:$3" | chpasswd
    fi
  fi
}

function DeleteUser {
  if [[ $isAuto = "false" ]]; then
    echo "Are you sure about that? yes|no"
    read Security_Q
    if [[ $Security_Q = "yes" ]]; then
      printf 'Type username: '
      read -r Username
      killall -KILL -u $Username
      crontab -r -u $Username #Dont think its neccessary
      userdel -r $Username
    fi
  else
    killall -KILL -u $1
    crontab -r -u $1 #Dont think its neccessary
    userdel -r $1
  fi
}

while [ "$INPUT_OPTION" != "end" ]
do
  clear
  User_Count=$(sed -n '/\/bin\/bash/p' /etc/passwd | cut -d: -f1 | wc -l)
  if [[ $User_Count = 1 ]]; then
    echo "Only \"$(sed -n '/\/bin\/bash/p' /etc/passwd | cut -d: -f1)\" user exists. (Press \"ESC\" to go back.)"
    echo "Available User options:"
    echo "1. Add Admin user"
    echo "2. Add normal user"

    read -sn1 INPUT_OPTION
    case $INPUT_OPTION in
      '1') CreateUser "admin";;
      '2') CreateUser "normal";;
      $'\e') break;;
    esac
  else
    echo "This system has $User_Count users. (Press \"ESC\" to go back.)"
    echo "Available User options:"
    echo "1. List users"
    echo "2. Add Admin user"
    echo "3. Add normal user"
    echo "4. Remove user"

    read -sn1 INPUT_OPTION
    case $INPUT_OPTION in
      '1') clear; sed -n '/\/bin\/bash/p' /etc/passwd | cut -d: -f1; read -sn1;;
      '2') CreateUser "admin";;
      '3') CreateUser "normal";;
      '4') DeleteUser "";;
      $'\e') break;;
    esac
  fi
done
