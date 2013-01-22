#!/bin/bash
# This adds the current ip address to /etc/issue, which displays on console.
# Useful for local VMs to see the IP address without having to login to local
# console first.  Call this script from /etc/rc.local

# cleanup current /etc/issue
grep -v "IP Address" /etc/issue >/tmp/issue
cp /tmp/issue /etc/issue
rm -f /tmp/issue

IPADD=`/sbin/ifconfig | sed '/Bcast/!d' | awk '{print $2}'| awk '{print $2}' FS=":"`
echo " IP Address: $IPADD" >>/etc/issue
