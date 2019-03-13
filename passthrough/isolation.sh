#!/bin/bash

#VFIO
file="/etc/modprobe.d/vfio.conf"; touch $file;
echo "options vfio-pci ids=10de:17c8,10de:0fb0" > $file;

#MODULES
file="/etc/mkinitcpio.conf";
replace_this="MODULES=()";
replace_with="MODULES=(vfio_pci vfio vfio_iommu_type1 vfio_virqfd)";
sed -i -- "s/$replace_this/$replace_with/g" $file;
#mkinitcpio -p linux;
mkinitcpio -p linux-lts;
