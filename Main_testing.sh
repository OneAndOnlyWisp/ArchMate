#!/bin/sh

#Gather system information
[[ $(uname -r) = *"lts"* ]] && KERNEL_VERSION="LTS" || KERNEL_VERSION="default"
CPUID=$(lscpu | sed -n 's/^Model name:[[:space:]]*//p')
[[ $CPUID = *"Intel"* ]] && CPU_MANUFACTURER="Intel" || CPU_MANUFACTURER="AMD"
clear

#Kernel menu
Kernel_Menu()
{
  while [ "$INPUT_OPTION" != "end" ]
  do
    clear
    echo "Linux currently uses \"$KERNEL_VERSION\" kernel. (Press \"ESC\" to go back.)"
    echo "Available kernel options:"
    case $KERNEL_VERSION in
      "default")
        echo "1. Change to LTS Kernel."
        read -sn1 INPUT_OPTION
        case $INPUT_OPTION in
          '1') echo "Trying to install LTS Kernel...";; #pacman -S --noconfirm --noprogressbar --quiet linux-lts linux-lts-headers;;
          $'\e') break;;
        esac
        ;;
      "LTS")
        echo "1. Change to default Kernel."
        read -sn1 INPUT_OPTION
        case $INPUT_OPTION in
          '1') echo "Trying to install default Kernel...";; #pacman -S --noconfirm --noprogressbar --quiet linux linux-headers;;
          $'\e') break;;
        esac
        ;;
    esac
  done
}

CPU_Menu()
{
  while [ "$INPUT_OPTION" != "end" ]
  do
    clear
    echo "This system has a \"$CPUID\" CPU. (Press \"ESC\" to go back.)"
    echo "Available CPU options:"
    case $CPU_MANUFACTURER in
      "Intel")
        echo "1. Install Intel Firmware."
        read -sn1 INPUT_OPTION
        case $INPUT_OPTION in
          '1') #pacman -S --noconfirm --noprogressbar --quiet intel-ucode
            #Reconfigure to bootloader
            #grub-mkconfig -o /boot/grub/grub.cfg;;
            ;;
          $'\e') break;;
        esac
        ;;
      "AMD")
        echo "No available options for this CPU."
        read -sn1 INPUT_OPTION
        case $INPUT_OPTION in
          $'\e') break;;
        esac
        ;;
    esac
  done
}

VGA_Menu()
{
  while [ "$INPUT_OPTION" != "end" ]
  do
    #VGA
    echo "VGA Options. (Type \"back\" to go back a level, or \"exit\" to quit.)"
    echo "2. Install Intel graphics driver"
    echo "3. Install NVIDIA graphics driver"
    echo "4. Install AMD/ATI graphics driver"
    read -sn1 INPUT_OPTION
    #Execute action
    case $INPUT_OPTION in
      '1') echo "Graphical adapters:"; lspci -k | grep -A 2 -E "(VGA|3D)" ;;
      '2')
        echo "Trying to install Intel graphics driver..."; pacman -S --noconfirm --noprogressbar --quiet mesa
        #Ivy Bridge and newer
        #[ -n $MOTHERBOARD_INFO ] && pacman -S --noconfirm --noprogressbar --quiet vulkan-intel
        ;;
      '3') echo "Trying to install NVIDIA graphics driver...";;
      '4') echo "Trying to install AMD/ATI graphics driver...";;
      $'\e') break;;
    esac
    clear
    echo "Press a button to continue..."; read TEMP
  done
}

#Main loop
INPUT_OPTION=default
while [ "$INPUT_OPTION" != "end" ]
do
  #Menu
	echo "Please type the number of selected task! (Press \"ESC\" to quit.)"
	echo "1. Kernel"
  echo "2. CPU"
  echo "3. VGA"
  read -sn1 INPUT_OPTION

  case $INPUT_OPTION in
    '1') Kernel_Menu; clear;;
    '2') CPU_Menu; clear;;
    '3') VGA_Menu; clear;;
    $'\e') clear; break;;
  esac
done
