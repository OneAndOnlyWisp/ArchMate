#!/bin/bash
clear;
#-------------------------------------------------------------------------------
#Download Vulkan SDK from: https://vulkan.lunarg.com/sdk/home
# - Create folder for SDK files, and enter it
# - "tar zxf $PATH_TO_FILE/vulkansdk-linux-x86_64-1.1.xx.y.tar.gz"
#  - Run => $SDK_PATH/1.1.xx.y/setup-env.sh
#-------------------------------------------------------------------------------
pacman -S --noconfirm vulkan-devel; #Vulkan development package group
pacman -S --noconfirm glfw-x11 glm; #OpenGL packages | Window creation mostly
#-------------------------------------------------------------------------------
