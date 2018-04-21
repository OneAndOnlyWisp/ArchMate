#!/bin/sh
clear

function ReadBootCFG {
  #Grub
  BootFile="/boot/grub/grub.cfg"
  while read line
  do
    let LineCount=LineCount+1
    #Search for menuentries
    if [[ $line = "menuentry 'Arch"* ]] && ! [[ $line = *"fallback initramfs"* ]]; then
      IsMenu="true"
      let MenuEntryCount=MenuEntryCount+1
      if [[ $MenuEntryCount = 1 ]]; then
        VM_Linuz_default[0]=$(echo $line | sed "s/.*menuentry '\(.*\)'.*/\1/" | sed "s/'.*//")
      else
        if [[ ${#Version_Stash[*]} = 0 ]]; then
          Version_Stash[0]=$(echo $line | sed "s/.*menuentry '\(.*\)'.*/\1/" | sed "s/'.*//")
        else
          Version_Stash[${#Version_Stash[*]}]=$(echo $line | sed "s/.*menuentry '\(.*\)'.*/\1/" | sed "s/'.*//")
        fi
      fi
    fi
    #Find lines to replace
    if [[ $IsMenu = "true" ]]; then
      case $line in
        *"linux	/"* )
          if [[ $MenuEntryCount = 1 ]]; then
            VM_Linuz_default[1]=$LineCount
          else
            if [[ ${#UUID_Stash[*]} = 0 ]]; then
              UUID_Stash[0]=$LineCount
            else
              UUID_Stash[${#UUID_Stash[*]}]=$LineCount
            fi
          fi
          ;;
        *"initrd"* )
          Initframs=$line
          if [[ $MenuEntryCount = 1 ]]; then
            VM_Linuz_default[2]=$LineCount
          else
            if [[ ${#IMG_Stash[*]} = 0 ]]; then
              IMG_Stash[0]=$LineCount
            else
              IMG_Stash[${#IMG_Stash[*]}]=$LineCount
            fi
          fi
          ;;
      esac
      #Close menu
      if [[ $line = *"}"* ]]; then
        IsMenu="false"
      fi
    fi
  done < $BootFile

  echo "Available versions:" ${#Version_Stash[*]}
  echo ""
  echo "Default linux:" ${VM_Linuz_default[0]}
  echo "UUID line number:" ${VM_Linuz_default[1]}
  echo "IMG line number:" ${VM_Linuz_default[2]}
  echo ""
  echo "Version stash:" ${Version_Stash[*]}
  echo "UUID stash:" ${UUID_Stash[*]}
  echo "IMG stash:" ${IMG_Stash[*]}

}

ReadBootCFG
#Set default kernel to load                                         UUID_Stash Set here ˇ
sh Functions.sh ReplaceLineByNumber ${VM_Linuz_default[1]} "$(sed -n -e "${UUID_Stash[1]}p" $BootFile | sed 's/\//\\\//g' | cut -c 2-)" $BootFile
#Set default kernel to load                                         IMG_Stash Set here ˇ
sh Functions.sh ReplaceLineByNumber ${VM_Linuz_default[2]} "$(sed -n -e "${IMG_Stash[1]}p" $BootFile | sed 's/\//\\\//g' | cut -c 2-)" $BootFile
