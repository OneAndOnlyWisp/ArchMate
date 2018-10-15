#!/bin/sh
clear;
#-------------------------------------------------------------------------------
username="wisp"; #Edit username here
#-------------------------------------------------------------------------------
#--------------------------------Virtualization---------------------------------
#-------------------------------------------------------------------------------
#--------------------------Enable IOMMU groups at boot--------------------------
#Read grub config---------------------------------------------------------------
LineCount=0
while read line; do
  LineCount=$(($LineCount + 1))
  if [[ $line = *"GRUB_CMDLINE_LINUX_DEFAULT"* ]]; then
    NewText=$(echo $line | head -c-2)" intel_iommu=on iommu=pt\""
    break
  fi
done < /etc/default/grub
#Edit grub config---------------------------------------------------------------
sed -ie $LineCount"s/.*/$NewText/g" /etc/default/grub;
#Regenerate boot config---------------------------------------------------------
grub-mkconfig -o /boot/grub/grub.cfg;
#-------------------------------------------------------------------------------
#-------------------------------Install packages--------------------------------
#-------------------------------------------------------------------------------
#Virtualization-----------------------------------------------------------------
pacman -S --noconfirm qemu libvirt ovmf;
#-------------------------------------------------------------------------------
#Virtual machine manager GUI----------------------------------------------------
pacman -S --noconfirm virt-manager;
#-------------------------------------------------------------------------------
#-----------------------------------Settings------------------------------------
#-------------------------------------------------------------------------------
#Add OVMF to QEMU machines (UEFI bios)------------------------------------------
nvram="nvram = [ \"/usr/share/ovmf/x64/OVMF_CODE.fd:/usr/share/ovmf/x64/OVMF_VARS.fd\" ]"
echo $nvram >> /etc/libvirt/qemu.conf
#-------------------------------------------------------------------------------
#Passing VM audio to host (PulseAudio)------------------------------------------
audio="user = \"$username\""
echo $audio >> /etc/libvirt/qemu.conf
#Set default sample rates-------------------------------------------------------
sample_rate_def="default-sample-rate = 44100"
sample_rate_alt="alternate-sample-rate = 48000"
echo $sample_rate_def >> /etc/pulse/daemon.conf
echo $sample_rate_alt >> /etc/pulse/daemon.conf
#-------------------------------------------------------------------------------
#Add default user to libvirt group----------------------------------------------
usermod -aG libvirt $username;
#-------------------------------------------------------------------------------
#Enable virtualization service--------------------------------------------------
systemctl enable libvirtd.service;
#-------------------------------------------------------------------------------
#Networkworking-----------------------------------------------------------------
pacman -S --noconfirm dnsmasq; pacman -S --noconfirm firewalld;
#systemctl enable firewalld.service;
#firewall-cmd --permanent --zone=public --add-port=8080/tcp; #Open port for VLC remote controll
#-------------------------------------------------------------------------------
#---------------------------------GPU isolation---------------------------------
#-------------------------------------------------------------------------------
src_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
sh "$src_path/isolation.sh";
#-------------------------------------------------------------------------------
