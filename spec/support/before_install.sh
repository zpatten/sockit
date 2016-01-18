#!/usr/bin/env bash
set -ex

sudo apt-get -qy update
sudo apt-get -qy install wget build-essential libpam0g-dev libbsd-dev libbsd0 libbsd0-dbg libssl-dev libldap2-dev

wget http://sourceforge.net/projects/ss5/files/ss5/3.8.9-8/ss5-3.8.9-8.tar.gz/download -O ss5-3.8.9.tar.gz
tar -zxvf ss5-3.8.9.tar.gz
cd ss5-3.8.9
./configure --with-configfile=/etc/ss5/ss5.conf
sudo make
sudo make install

sudo mkdir -p /etc/ss5/

cat <<-EOF | sudo tee /etc/ss5/ss5.conf
auth 0.0.0.0/0 - -
permit - 0.0.0.0/0 - 0.0.0.0/0 - - - - -
EOF

cat <<-EOF | sudo tee /etc/ss5/ss5-auth.conf
auth 0.0.0.0/0 - u
permit - 0.0.0.0/0 - 0.0.0.0/0 - - - - -
EOF

cat <<-EOF | sudo tee /etc/ss5/ss5.passwd
root none
EOF

sudo SS5_SOCKS_PORT=1080 SS5_CONFIG_FILE=/etc/ss5/ss5.conf /usr/sbin/ss5 -t -u root
sudo SS5_SOCKS_PORT=1081 SS5_CONFIG_FILE=/etc/ss5/ss5-auth.conf SS5_PASSWORD_FILE=/etc/ss5/ss5.passwd /usr/sbin/ss5 -t -u root

nc -w 3 127.0.0.1 1080
nc -w 3 127.0.0.1 1081
