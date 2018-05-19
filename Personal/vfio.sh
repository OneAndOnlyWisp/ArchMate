#!/bin/sh
clear
#Local globals------------------------------------------------------------------
Source_Path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"

function List_IOMMU_Groups {
  shopt -s nullglob
  for d in /sys/kernel/iommu_groups/*/devices/*; do
      n=${d#*/iommu_groups/*}; n=${n%%/*}
      printf 'IOMMU Group %s ' "$n"
      lspci -nns "${d##*/}"
  done;
}

/etc/modprobe.d/vfio.conf
options vfio-pci ids=10de:13c2,10de:0fbb

/etc/mkinitcpio.conf
MODULES=(... vfio_pci vfio vfio_iommu_type1 vfio_virqfd ...)

/etc/mkinitcpio.conf
HOOKS=(... modconf ...)

mkinitcpio -p "LinuxKernel"

pacman -S --noconfirm qemu libvirt ovmf virt-manager firewalld dnsmasq
