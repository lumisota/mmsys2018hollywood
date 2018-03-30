#!/bin/bash

set -o history
set -e

echo "*** Running tcph-install.sh"

REV=$1

echo "***   REV  = $REV"

cd ~/tcp-hollywood-linux
make deb-pkg LOCALVERSION=-hollywood KDEB_PKGVERSION=$(make kernelversion)-1
sudo dpkg -i ../linux-headers-$(make kernelversion)-hollywood-g"$REV"_$(make kernelversion)-1_amd64.deb
sudo dpkg -i ../linux-image-$(make kernelversion)-hollywood-g"$REV"_$(make kernelversion)-1_amd64.deb
sudo cp /vagrant/grub /etc/default/grub
sudo update-grub
export GRUB_CONFIG=`sudo find /boot -name "grub.cfg"`
echo $(grep 'menuentry ' $GRUB_CONFIG | nl -v 0 | grep "hollywood-g${3}'" | cut -c 6)
sudo grub-set-default $(grep 'menuentry ' $GRUB_CONFIG | nl -v 0 | grep "hollywood-g$REV'" | cut -c 6)]
cd ..
sudo rm -rf *

sudo apt-get clean
cat /dev/null > ~/.bash_history && history -c
sudo dd if=/dev/zero of=/EMPTY bs=1M | true
sudo rm -f /EMPTY

echo "*** Finished tcph-install.sh"

