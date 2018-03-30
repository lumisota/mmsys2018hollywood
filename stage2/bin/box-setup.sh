#!/bin/bash

set -e

# update 
sudo apt-get update -y
sudo apt-get install -y git libboost-all-dev

cd ~/hollywood-api
make
cd ..