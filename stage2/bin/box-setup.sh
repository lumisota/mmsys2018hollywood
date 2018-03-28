#!/bin/bash

set -e

if [ "$#" = 3 ]; then
    REPO=$1
    KEY=$2
    REV=$3
    echo -e "IdentitiesOnly yes\nHost github.com\n\tStrictHostKeyChecking no\n\tIdentityFile /vagrant/$KEY\n" >> ~/.ssh/config
    sudo chmod 600 /vagrant/$KEY
    sudo chmod 600 /vagrant/$KEY.pub
else
    REPO=$1
    REV=$2
fi

# update 
sudo apt-get update -y
sudo apt-get install -y git libboost-all-dev

(git clone $REPO hollywood-api --verbose) || exit
cd hollywood-api
(git checkout $REV) || exit
make
cd ..