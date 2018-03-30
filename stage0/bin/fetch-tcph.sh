#!/bin/bash

set -o history
set -e

echo "*** Running fetch-tcph.sh"

if [ "$#" = 3 ]; then
    echo "***   Installing ssh keys"
    REPO=$1
    KEY=$2
    REV=$3
    echo -e "IdentitiesOnly yes\nHost github.com\n\tStrictHostKeyChecking no\n\tIdentityFile /vagrant/$KEY\n" >> ~/.ssh/config
    sudo chmod 600 /vagrant/$KEY
    sudo chmod 600 /vagrant/$KEY.pub
else
    echo "***   Did not install ssh keys"
    REPO=$1
    REV=$2
fi

echo "***   REPO = $REPO"
echo "***   KEY  = $KEY"
echo "***   REV  = $REV"

(git clone $REPO tcp-hollywood-linux) || exit
cd tcp-hollywood-linux
git checkout $REV
tar -pczvf /vagrant/hollywood-$REV.tar.gz .

echo "*** Finished fetch-tcph.sh"