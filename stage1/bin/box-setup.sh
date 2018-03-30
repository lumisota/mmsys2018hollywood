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