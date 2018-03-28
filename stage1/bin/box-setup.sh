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
(git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg) || exit		
cd ffmpeg		
./configure		
make		
sudo make install		
cd ..
 
# install Mininet

sudo DEBIAN_FRONTEND=noninteractive apt-get -y install clang wireshark-common
(git clone https://github.com/mininet/mininet) || exit
cd mininet
#git checkout -b 2.2.1 2.2.1
cd ..
mininet/util/install.sh -a

# install libcurl

sudo DEBIAN_FRONTEND=noninteractive apt-get -y install libcurl4-openssl-dev

# install libsctp

sudo DEBIAN_FRONTEND=noninteractive apt-get -y install libsctp-dev libbz2-dev

# install netperfmeter

wget https://www.uni-due.de/~be0001/netperfmeter/download/netperfmeter-1.6.1.tar.gz
tar -xvf netperfmeter-1.6.1.tar.gz
cd netperfmeter-1.6.1
./configure
make
sudo make install

# install tapas dependencies

sudo DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:mc3man/trusty-media
sudo DEBIAN_FRONTEND=noninteractive apt-get -y update
sudo apt-get install python-twisted python-twisted-bin python-twisted-core python-twisted-web gstreamer0.10-plugins-* gstreamer0.10-ffmpeg gstreamer0.10-tools python-gst0.1 libgstreamer0.10-dev python-scipy python-psutil -y
