#!/bin/bash -e

if [[ $EUID -ne 0 ]]; then
    echo "Must be run as root"
    exit 1
fi

echo "Installing puppet using puppetlabs ppa"

FILENAME="puppetlabs-release-$(lsb_release -cs).deb"
wget "http://apt.puppetlabs.com/${FILENAME}"
dpkg -i "${FILENAME}"
rm -f "${FILENAME}"
apt-get update
apt-get install -y puppet

echo
echo "puppet is installed"

exit 0

