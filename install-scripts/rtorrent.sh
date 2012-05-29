#!/bin/bash -e
# this is meant for ubuntu precise (12.04)
# TODO:
#  - initial config of rtorrent and screen
#  - create rtorrent user if it doesn't exist

if [[ $EUID -ne 0 ]]; then
    echo "Must be run as root"
    exit 1
fi

aptitude -y install build-essential pkg-config
# libtorrent deps
aptitude -y install libssl-dev libsigc++-2.0-dev
# rotorrent deps
aptitude -y install libxmlrpc-core-c3-dev ncurses-dev libcurl4-openssl-dev

cd /usr/local/src
wget http://libtorrent.rakshasa.no/downloads/libtorrent-0.12.9.tar.gz
wget http://libtorrent.rakshasa.no/downloads/rtorrent-0.8.9.tar.gz
tar xzf libtorrent-0.12.9.tar.gz
tar xzf rtorrent-0.8.9.tar.gz
cd libtorrent-0.12.9
./configure --prefix=/usr/local
# need to check the exit code on previous command (maybe just add -e to top?)
make
make install

#rtorrent
cd ../rtorrent-0.8.9
wget http://www.fateyev.com/files/coding/rtorrent-0.8.9-ip_filter_no_boost-fast-bsd2.patch
patch -p1 <rtorrent-0.8.9-ip_filter_no_boost-fast-bsd2.patch
./configure --prefix=/usr/local --with-xmlrpc-c
# these two weren't needed?
#aptitude install libcppunit-dev
#autoreconf
make && make install

echo "# rtorrent" >>/etc/rc.local
echo "su -c 'cd /home/rtorrent && screen -dmS rtorrent rtorrent' rtorrent" >>/etc/rc.local

exit 0

