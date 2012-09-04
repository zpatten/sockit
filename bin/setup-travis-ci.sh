#!/usr/bin/env sh
set -x

sudo apt-get update -qq
sudo apt-get install -qq wget
sudo mkdir -p /usr/local/src
cd /usr/local/src
sudo wget http://sourceforge.net/projects/ss5/files/ss5/3.8.9-6/ss5-3.8.9-6.tar.gz/download
sudo tar -zxvf ss5-3.8.9-6.tar.gz
cd ss5-3.8.9
sudo ./configure
sudo make install
