#!/usr/bin/env sh
set -x

echo $PWD
sudo apt-get -y --force-yes update
sudo apt-get -y --force-yes install wget build-essential libpam0g-dev
sudo mkdir -p /usr/local/src
cd /usr/local/src
sudo wget http://sourceforge.net/projects/ss5/files/ss5/3.8.9-6/ss5-3.8.9-6.tar.gz/download -O ss5-3.8.9.tar.gz
sudo tar -zxvf ss5-3.8.9.tar.gz
cd ss5-3.8.9
sudo ./configure
sudo make install
