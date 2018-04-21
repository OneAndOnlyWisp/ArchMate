#!/bin/sh

#Git clone the package
git clone https://aur.archlinux.org/linux-lqx.git
#Enter PACKAGE directory
cd linux-lqx
#Install package
makepkg -si --noconfirm --noprogressbar
