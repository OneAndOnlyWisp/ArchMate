#!/bin/bash
clear;
#-------------------------------------------------------------------------------
#Main loop----------------------------------------------------------------------
while [ "$INPUT_OPTION" != "end" ]; do
  clear
  echo "Please type the number of selected task! (Press \"ESC\" to quit.)"
  echo "1. Install Tensorflow - CPU"
  echo "2. Install Tensorflow - GPU (NVIDIA only)"
  read -sn1 INPUT_OPTION
  case $INPUT_OPTION in
    '1') pacman -S --noconfirm python-tensorflow; clear;;
    '2') pacman -S --noconfirm python-tensorflow-cuda; clear;;
    $'\e') clear; break;;
  esac
done
#-------------------------------------------------------------------------------
