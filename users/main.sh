#!/bin/bash
#-------------------------------------------------------------------------------
#Helper functions---------------------------------------------------------------
function UserExists {
  for Item in $(sed -n '/\/bin\/bash/p' /etc/passwd | cut -d: -f1); do
    if [[ "$Item" = "$1" ]]; then
      echo "true"
      return
    fi
  done
  echo "false"
  return
}

function isValidName {
  if [[ $1 =~ ^[a-z_]+$ ]]; then
    if [[ $(UserExists $1) = "true" ]]; then
      echo "User already exists!"
      exit
    else
      echo "true"
      exit
    fi
  fi
  echo "Invalid characters!"
  exit
}

function GetUserCount {
  echo $(sed -n '/\/bin\/bash/p' /etc/passwd | cut -d: -f1 | wc -l)
}

function CheckWheelAdmin {
  #Allow admin rigths for wheel group
  ReplaceThisLine=$(sed -n '/# %wheel ALL=(ALL) ALL/=' /etc/sudoers)
  if ! [[ "$ReplaceThisLine" = "" ]]; then
    ReplaceWith="%wheel ALL=(ALL) ALL"
    cat /etc/sudoers | sed -e ""$ReplaceThisLine"s/.*/$ReplaceWith/g" | EDITOR='tee' visudo
    clear
  fi
}
#Draw menu elements-------------------------------------------------------------
function DeleteUser {
  clear
  echo "Are you sure about deleting a user? yes|no"
  Security_Q=""
  while [ "$Security_Q" = "" ]; do
    read Security_Q
    if [[ $Security_Q = "yes" ]]; then
      printf 'Type username: '; read -r Username;
      if [[ $(UserExists $Username) = "true" ]]; then
        killall -KILL -u $Username
        crontab -r -u $Username #Dont think its neccessary
        userdel -r $Username
        clear
        echo "Succesfully deleted user \"$Username\"."
      else
        echo "User \"$Username\" doesnt exists."
      fi
    else
      echo "Returning to previous menu."
      Security_Q=""
      return
    fi
  done
}

function CreateUser {
  clear
  if [[ $1 = "admin" ]]; then #Admin
    echo "Are you sure about adding an admin user? yes|no"
    Security_Q=""
    while [ "$Security_Q" = "" ]; do
      read Security_Q
      if [[ $Security_Q = "yes" ]]; then
        CheckWheelAdmin
        printf 'Type selected username: '; read -r Username;
        Valid=$(isValidName $Username)
        if [[ $Valid = "true" ]]; then
          useradd -m -g users -G wheel -s /bin/bash $Username
          echo "Succesfully added new user \"$Username\" with admin rigths."
        else
          echo $Valid
          return
        fi
        break
      else
        echo "Returning to previous menu."
        Security_Q=""
        return
      fi
    done
  else #Regular
    printf 'Type selected username: '; read -r Username;
    Valid=$(isValidName $Username)
    if [[ $Valid = "true" ]]; then
      useradd -m -g users -s /bin/bash $Username
      echo "Succesfully added new user \"$Username\"."
    else
      echo $Valid
      return
    fi
  fi
  passwd $Username
}

function DrawMenu {
  user_count=$(GetUserCount)
  if [[ $user_count = 1 ]]; then
    echo "Only \"$(sed -n '/\/bin\/bash/p' /etc/passwd | cut -d: -f1)\" user exists. (Press \"ESC\" to go back.)"
    echo "Available User options:"
    echo "1. Add Admin user"
    echo "2. Add regular user"
    read -sn1 INPUT_OPTION
    case $INPUT_OPTION in
      '1') CreateUser "admin";;
      '2') CreateUser "regular";;
      $'\e') exit;;
    esac
  else
    echo "This system has $user_count users. (Press \"ESC\" to go back.)"
    echo "Available User options:"
    echo "1. List users"
    echo "2. Add Admin user"
    echo "3. Add regular user"
    echo "4. Remove user"
    read -sn1 INPUT_OPTION
    case $INPUT_OPTION in
      '1') clear; sed -n '/\/bin\/bash/p' /etc/passwd | cut -d: -f1;;
      '2') CreateUser "admin";;
      '3') CreateUser "regular";;
      '4') DeleteUser;;
      $'\e') exit;;
    esac
    read -sn1;
  fi
}
#-------------------------------------------------------------------------------
#User interface-----------------------------------------------------------------
while [ "$INPUT_OPTION" != "end" ]
do
  clear
  DrawMenu
done
#-------------------------------------------------------------------------------
