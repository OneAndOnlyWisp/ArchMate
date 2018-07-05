# ArchMate
## Description
This script can help you have a working desktop environment in 5 mins. It is really user-friendly, automatic hardware detection doesnt let you install wrong drivers. Later on will be capable of reading config files, which makes the whole process automatic.

Under development for now. Use at your own risk. Only tested with Intel/NVIDIA setup.

#### Features:
- Change/set default kernel
- Install graphic drivers
- User management
- Desktop install
- Run custom end script (optional)

#### Will be implemented:
- Read from config file

## Prerequisites

- A working internet connection
- Logged in as 'root'
- (There are minimum hardware requirements, but no exact information for now)
- (Preferably pacstrap-base install)

## How to get it
#### With git
- Install and/or sync git: `pacman -Sy git`
- Get the script: `git clone git://github.com/OneAndOnlyWisp/ArchMate`

## How to use
- Download and run the script rigth after first root login on a fresh install
- sh ArchMate/Main.sh
