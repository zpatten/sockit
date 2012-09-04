#!/usr/bin/env sh

sudo apt-get update -qq
sudo apt-get install -qq wget
mkdir -p /usr/local/src
cd /usr/local/src
wget http://sourceforge.net/projects/ss5/files/ss5/3.8.9-6/ss5-3.8.9-6.tar.gz/download
tar -zxvf ss5-3.8.9-6.tar.gz
cd ss5-3.8.9
./configure
make install
