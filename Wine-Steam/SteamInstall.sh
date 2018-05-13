#!/bin/sh
clear
#Local globals------------------------------------------------------------------
Source_Path="../"
#-------------------------------------------------------------------------------
#Steam install elements---------------------------------------------------------
function GenerateLocale {
  StartingLine=$(sed -n '/#en_US\.UTF-8 UTF-8/=' /etc/locale.gen)
  if ! [[ "$StartingLine" = "" ]]; then
    sed -ie ""$StartingLine"s/#//g" /etc/locale.gen
    locale-gen
  fi
}

function InstallFonts {
  sh ""$Source_Path"Functions.sh" InstallPackages "ttf-liberation";
  sh ""$Source_Path"Functions.sh" InstallPackages "wqy-zenhei";
}

function CheckSteamDependancy {
  GenerateLocale
  InstallFonts
  sh ""$Source_Path"Functions.sh" InstallPackages "wget";
}

function WineInstallSteam {
  CheckSteamDependancy
  URL="https://steamcdn-a.akamaihd.net/client/installer/"
  FileName="SteamSetup.exe"
  wget -O $HOME/$FileName $URL$FileName
  wine "$HOME/$FileName"
}
#-------------------------------------------------------------------------------
#Wine install elements----------------------------------------------------------
function InstallWINE {
  sh ""$Source_Path"Functions.sh" InstallPackages "wine";
  sh ""$Source_Path"Functions.sh" InstallPackages "wine_gecko";
  sh ""$Source_Path"Functions.sh" InstallPackages "wine-mono";
}
#-------------------------------------------------------------------------------
InstallWINE
WineInstallSteam

read -sn1
exit
