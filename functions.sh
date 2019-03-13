#!/bin/bash
#-------------------------------------------------------------------------------
#Check if a package is installed------------------------------------------------
function _isInstalled {
    package="$1";
    check="$(pacman -Qs --color always "${package}" | grep "local" | grep "${package} ")";
    if [ -n "${check}" ] ; then
        echo 0; #'0' means 'true' in Bash
        return; #true
    fi;
    echo 1; #'1' means 'false' in Bash
    return; #false
}
#-------------------------------------------------------------------------------
#Install packages from AUR repository-------------------------------------------
function InstallFromAUR {
  #The packages that are not installed will be added to this array.
  toInstall=();
  #Loop through packages
  for pkg; do
      # If the package IS installed, skip it.
      if [[ $(_isInstalled "${pkg}") == 0 ]]; then
          echo "${pkg} is already installed."
          continue
      fi
      #Otherwise, add it to the list of packages to install.
      toInstall+=("${pkg}")
  done
  #Install missing packages
  for index in "${!toInstall[@]}"; do
    cd $HOME
    echo ""
    #Git clone the package
    if ! [[ -d ${toInstall[$index]} ]]; then
      git clone "https://aur.archlinux.org/${toInstall[$index]}.git"
      if [[ "$(ls -A "${toInstall[$index]}" | wc -l)" < 2 ]]; then
        echo "Package not found on AUR repository: ${toInstall[$index]}"
        rm -rf "${toInstall[$index]}"
        continue
      else
        cd ${toInstall[$index]}
      fi
    else
      cd ${toInstall[$index]}
      git pull
    fi
    makepkg -si --noconfirm --skippgpcheck; #Install
    cd $HOME; rm -rf "${toInstall[$index]}"; #Remove source
  done
}
#-------------------------------------------------------------------------------

"$@"
