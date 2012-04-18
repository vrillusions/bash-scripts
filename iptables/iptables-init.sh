#!/bin/bash
# this is meant to do the initial setup of iptables.  On startup and shutdown should use the
# iptables-save and iptables-load scripts.
#
# TODO: ipv6 (ip6tables) support

# Start from scratch
/sbin/iptables --flush
/sbin/iptables -Z
/sbin/iptables -X

# allow existing connections
# NOTE: in openvz need to modprobe xt_tcpudp, ip_conntrack, and xt_state
# conntrack is supposed to be "better" but doesn't work with openvz providers a lot
#/sbin/iptables -I INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# allow local interface
/sbin/iptables -A INPUT -i lo -j ACCEPT

# some ports to allow
/sbin/iptables -A INPUT -p tcp --dport 22 -j ACCEPT
/sbin/iptables -A INPUT -p tcp --dport 80 -j ACCEPT
#/sbin/iptables -A INPUT -s 192.231.162.0/23 -j ACCEPT

# ok icmp codes
/sbin/iptables -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
/sbin/iptables -A INPUT -p icmp --icmp-type source-quench -j ACCEPT
/sbin/iptables -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
/sbin/iptables -A INPUT -p icmp --icmp-type parameter-problem -j ACCEPT
/sbin/iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

# by default allow outgoing traffic, no incoming
/sbin/iptables -P INPUT DROP
/sbin/iptables -P FORWARD DROP
/sbin/iptables -P OUTPUT ACCEPT

echo "Active rules:"
/sbin/iptables --list -v
