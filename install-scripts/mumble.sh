#!/bin/bash -e
# yeah this is fairly simple :)

if [[ $EUID -ne 0 ]]; then
    echo "Must be run as root"
    exit 1
fi

if [ ! -x add-apt-repository ]; then
    # need to install missing package
    apt-get install -y python-software-properties
fi

add-apt-repository ppa:slicer
apt-get update
apt-get install -y mumble-server

# This installs ice library to interface with mumble on command line
apt-get install -y python-zeroc-ice

echo "Done"

exit 0

