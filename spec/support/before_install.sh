#!/usr/bin/env bash
set -x

echo $PWD
sudo apt-get -qy update
sudo apt-get -qy install wget build-essential libpam0g-dev libbsd-dev libbsd0 libbsd0-dbg libssl-dev libldap2-dev
wget http://sourceforge.net/projects/ss5/files/ss5/3.8.9-8/ss5-3.8.9-8.tar.gz/download -O ss5-3.8.9.tar.gz
tar -zxvf ss5-3.8.9.tar.gz
cd ss5-3.8.9
./configure
sudo make
sudo make install
sudo /usr/sbin/ss5 -t
