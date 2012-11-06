#!/bin/bash
#
# src: unknown
###
# Clear out any and all existing rules
# Copied and pasted from time enternal
# It's uber-overkill, but hey, what good script isn't?
###
for a in `cat /proc/net/ip_tables_names`; do
/sbin/iptables -F -t $a
/sbin/iptables -X -t $a

if [ $a == nat ]; then
   /sbin/iptables -t nat -P PREROUTING ACCEPT
   /sbin/iptables -t nat -P POSTROUTING ACCEPT
   /sbin/iptables -t nat -P OUTPUT ACCEPT
elif [ $a == mangle ]; then
   /sbin/iptables -t mangle -P PREROUTING ACCEPT
   /sbin/iptables -t mangle -P INPUT ACCEPT
   /sbin/iptables -t mangle -P FORWARD ACCEPT
   /sbin/iptables -t mangle -P OUTPUT ACCEPT
   /sbin/iptables -t mangle -P POSTROUTING ACCEPT
elif [ $a == filter ]; then
   /sbin/iptables -t filter -P INPUT ACCEPT
   /sbin/iptables -t filter -P FORWARD ACCEPT
   /sbin/iptables -t filter -P OUTPUT ACCEPT
fi
done
