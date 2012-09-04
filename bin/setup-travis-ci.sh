#!/usr/bin/env sh
set -x

echo $PWD
ls -la
sudo apt-get update -qq
sudo apt-get install -qq wget
sudo mkdir -p /usr/local/src
cd /usr/local/src
echo $PWD
ls -la
sudo wget http://sourceforge.net/projects/ss5/files/ss5/3.8.9-6/ss5-3.8.9-6.tar.gz/download -O ss5-3.8.9.tar.gz
ls -la
sudo tar -zxvf ss5-3.8.9.tar.gz
ls -la
cd ss5-3.8.9
echo $PWD
ls -la
sudo ./configure
sudo make install
