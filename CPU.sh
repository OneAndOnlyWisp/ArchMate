#!/bin/bash
#Gather required system information
CPUID=$(lscpu | sed -n 's/^Model name:[[:space:]]*//p')
[[ $CPUID = *"Intel"* ]] && CPU_MANUFACTURER="Intel" || CPU_MANUFACTURER="AMD"
#Menu
while [ "$INPUT_OPTION" != "end" ]
do
  clear
  echo "This system has a \"$CPUID\" processor. (Press \"ESC\" to go back.)"
  echo "Available CPU options:"
  case $CPU_MANUFACTURER in
    "Intel")
      echo "1. Install Microcode."
      echo "2. Install Intel Graphics."
      echo "3. Install Vulkan Support. (Ivy Bridge and newer)"
      read -sn1 INPUT_OPTION
      case $INPUT_OPTION in
        '1')
          echo "Trying to install Intel Microcode..."; pacman -S --noconfirm --noprogressbar --quiet intel-ucode
          #Reconfigure to bootloader
          grub-mkconfig -o /boot/grub/grub.cfg;;
        '2') echo "Trying to install Intel Graphics driver..."; pacman -S --noconfirm --noprogressbar --quiet mesa lib32-mesa;;
        '3') echo "Trying to install Vulkan driver..."; pacman -S --noconfirm --noprogressbar --quiet vulkan-intel;;
        $'\e') break;;
      esac
      ;;
    "AMD")
      echo "1. Install AMDGPU Graphics."
      echo "2. Install Vulkan Support."
      read -sn1 INPUT_OPTION
      case $INPUT_OPTION in
        '1') echo "Trying to install AMDGPU driver..."; pacman -S --noconfirm --noprogressbar --quiet mesa lib32-mesa xf86-video-amdgpu;;
        '2') echo "Trying to install Vulkan driver..."; pacman -S --noconfirm --noprogressbar --quiet vulkan-radeon;;
        $'\e') break;;
      esac
      ;;
  esac
done
