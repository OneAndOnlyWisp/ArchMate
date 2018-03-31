#!/bin/sh

#KERNEL_VERSION
[ $(uname -r) = *"lts"* ] && KERNEL_VERSION="LTS" || KERNEL_VERSION="default"
#CPU_MANUFACTURER
[ $(lscpu | sed -n 's/^Model name:[[:space:]]*//p') = *"Intel"* ] && CPU_MANUFACTURER="Intel" || CPU_MANUFACTURER="AMD"
#GPU_MANUFACTURER_LIST
#HA (( lspci | sed -n 's/^Model name:[[:space:]]*//p' ))
	GPU_NVIDIA=false
	GPU_AMD=false
	GPU_ONBOARD=false


#monitor 1768*992 | 30hz | váltottsoros

#Main loop
INPUT_OPTION='0'
while [ '$INPUT_OPTION' != $'\e' ]
do
	#Menu
	echo "Please type the number of selected task! (Press \"ESC\" to quit.)"
	echo "1. Kernel"
	echo "2. CPU"
	echo "3. VGA"
	echo "4. USERS"
	echo "5. REBOOT"
	read -sn1 INPUT_OPTION
	
	#Submenu
	case $INPUT_OPTION in
	'1')		
		while [ "$INPUT_OPTION" != "back" ]
		do			
			#Kernel
			echo "Kernel Options. (Type \"back\" to go back a level, or \"exit\" to quit.)"
			echo "1. Check current Kernel version"
			echo "2. Install LTS Kernel"
			echo "3. Install default Kernel"
			read -sn1 INPUT_OPTION			
			#Execute action
			case $INPUT_OPTION in
				'1')
					echo "Current Kernel version:"; uname -r									
					;;
				'2')
					echo "Trying to install LTS Kernel..."; pacman -S --noconfirm --noprogressbar --quiet linux-lts linux-lts-headers										
					;;
				'3')
					echo "Trying to install default Kernel..."; pacman -S --noconfirm --noprogressbar --quiet linux linux-headers					
					;;
				back)
					INPUT_OPTION=default; break					
					;;
				$'\e')					
					break
					;;	
				*)
					echo "Invalid input."					
					;;
			esac
			clear
			echo "Press a button to continue..."; read TEMP
		done			
		;;
	'2')		
		while [ "$INPUT_OPTION" != "back" ]
		do		
			#CPU
			echo "CPU Options. (Type \"back\" to go back a level, or \"exit\" to quit.)"
			echo "1. Check for CPU information"
			echo "2. Install Intel Firmware"
			read -sn1 INPUT_OPTION			
			#Execute action
			case $INPUT_OPTION in
				'1')
					echo "CPU model:"; lscpu | sed -n 's/^Model name:[[:space:]]*//p'
					;;
				'2')
					echo "Trying to install Intel Firmware..."; pacman -S --noconfirm --noprogressbar --quiet intel-ucode
					#Reconfigure to bootloader
					grub-mkconfig -o /boot/grub/grub.cfg
					;;
				back)
					INPUT_OPTION=default; break					
					;;
				$'\e')				
					break
					;;	
				*)
					echo "Invalid input."					
					;;
			esac
			clear
			echo "Press a button to continue..."; read TEMP
		done
		;;
	'3')	
		while [ "$INPUT_OPTION" != "back" ]
		do		
			#VGA
			echo "VGA Options. (Type \"back\" to go back a level, or \"exit\" to quit.)"
			echo "1. Check for graphical adapters"			
			echo "2. Install Intel graphics driver"
			echo "3. Install NVIDIA graphics driver"
			echo "4. Install AMD/ATI graphics driver"
			read -sn1 INPUT_OPTION			
			#Execute action
			case $INPUT_OPTION in
				'1')
					echo "Graphical adapters:"; lspci -k | grep -A 2 -E "(VGA|3D)"
					;;
				'2')
					echo "Trying to install Intel graphics driver..."; pacman -S --noconfirm --noprogressbar --quiet mesa
					#Ivy Bridge and newer
					#[ -n $MOTHERBOARD_INFO ] && pacman -S --noconfirm --noprogressbar --quiet vulkan-intel					
					;;
				'3')
					echo "Trying to install NVIDIA graphics driver..."	
					
					;;
				'4')
					echo "Trying to install AMD/ATI graphics driver..."	
					
					;;
					
				back)
					INPUT_OPTION=default; break					
					;;
				$'\e')			
					break
					;;	
				*)
					echo "Invalid input."					
					;;
			esac
			clear
			echo "Press a button to continue..."; read TEMP
		done			
		;;
	'4')
		echo "??????"		
		;;
	'5')
		reboot
		;;
	$'\e')
		echo "Closing..."; clear; break
		;;
	*)
		echo "Invalid input."
		;;
	esac  
done
