#!/bin/bash -e

if [[ $EUID -ne 0 ]]; then
    echo "Must be run as root"
    exit 1
fi

echo "Installing nginx from ppa"
add-apt-repository ppa:nginx/stable
apt-get update
apt-get install -y nginx

echo
echo "nginx is installed, now you will need to configure the server manually"

exit 0

