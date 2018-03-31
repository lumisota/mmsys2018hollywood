#!/bin/bash

set -e

# update apt cache
sudo DEBIAN_FRONTEND=noninteractive apt-get -y update

# install kernel build tools
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install dpkg-dev git
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo DEBIAN_FRONTEND=noninteractive apt-get -y update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install gcc-4.9 g++-4.9
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.9

# install ffmpeg		
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install yasm		
(git clone --verbose https://git.ffmpeg.org/ffmpeg.git ffmpeg) || exit		
cd ffmpeg		
./configure		
make		
sudo make install		
cd ..
 
# install Mininet

sudo DEBIAN_FRONTEND=noninteractive apt-get -y install clang wireshark-common
(git clone --verbose https://github.com/mininet/mininet) || exit
cd mininet
#git checkout -b 2.2.1 2.2.1
cd ..
mininet/util/install.sh -a

# install libcurl

sudo DEBIAN_FRONTEND=noninteractive apt-get -y install libcurl4-openssl-dev

