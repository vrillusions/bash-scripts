#!/bin/bash
# add -x to print out each line (helps with debugging)
# this is meant to do the initial setup of iptables.  On startup and shutdown should use the
# iptables-save and iptables-load scripts.

# setup IPv6 as well?
IPV6=no

if [[ $EUID -ne 0 ]]; then
    echo "Must be run as root"
    exit 1
fi

if [ "$IPV6" == "yes" ]; then
    IP6TABLES=$(which ip6tables) || eval "echo 'Please install ip6tables'; exit 1"
fi
IPTABLES=$(which iptables) || eval "echo 'Could not find iptables'; exit 1"


# Start from scratch
$IPTABLES -F
$IPTABLES -Z
$IPTABLES -X

# LIMIT chain, used as endpoint of limited connections
$IPTABLES -N LIMIT
$IPTABLES -A LIMIT -m limit --limit 3/min -j LOG --log-prefix "[LIMIT BLOCK] " 
$IPTABLES -A LIMIT -j REJECT --reject-with icmp-port-unreachable 

# allow existing connections
# NOTE: in openvz need to modprobe xt_tcpudp, ip_conntrack, and xt_state
# conntrack is supposed to be "better" but doesn't work with openvz providers a lot
#$IPTABLES -I INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$IPTABLES -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# allow local interface
$IPTABLES -A INPUT -i lo -j ACCEPT

# limit how fast incoming ssh connections can happen
$IPTABLES -A INPUT -p tcp -m tcp --dport 22 -m state --state NEW -m recent --set --name DEFAULT --rsource 
$IPTABLES -A INPUT -p tcp -m tcp --dport 22 -m state --state NEW -m recent --update --seconds 30 --hitcount 6 --name DEFAULT --rsource -j LIMIT
$IPTABLES -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT

# some ports to allow
# ssh is handled above
#$IPTABLES -A INPUT -p tcp --dport 22 -j ACCEPT
$IPTABLES -A INPUT -p tcp --dport 80 -j ACCEPT
# example to allow full access from a single ip
#$IPTABLES -A INPUT -s 192.231.162.0/23 -j ACCEPT

# ok icmp codes
$IPTABLES -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
$IPTABLES -A INPUT -p icmp --icmp-type source-quench -j ACCEPT
$IPTABLES -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
$IPTABLES -A INPUT -p icmp --icmp-type parameter-problem -j ACCEPT
# can lower this if you're paranoid but 1 ping a second is fine.  If someone is trying
# to ping flood they're going to do several a second
$IPTABLES -A INPUT -p icmp --icmp-type echo-request -j ACCEPT -m limit --limit 60/minute

# log unhandled packets
$IPTABLES -A INPUT -m limit --limit 15/min -j LOG --log-prefix "[UNHANDLED INPUT PKT] " 


# by default allow outgoing traffic, no incoming
$IPTABLES -P INPUT DROP
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT ACCEPT

#echo "Active rules:"
#$IPTABLES --list -v

if [ "$IPV6" == "yes" ]; then
    echo "Setting IPv6 rules"
    # Only commenting on differences
    $IP6TABLES -F
    $IP6TABLES -Z
    $IP6TABLES -X

    # again, choose either conntrack or state, don't need both
    #$IP6TABLES -I INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    $IP6TABLES -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    $IP6TABLES -A INPUT -i lo -j ACCEPT
    # allow link-local communications
    $IP6TABLES -A INPUT -s fe80::/10 -j ACCEPT
    # for stateless autoconfiguration (restrict NDP messages to hop limit of 255)
    # commented out on openvz containers
    #$IP6TABLES -A INPUT -p icmpv6 --icmpv6-type neighbor-solicitation -m hl --hl-eq 255 -j ACCEPT
    #$IP6TABLES -A INPUT -p icmpv6 --icmpv6-type neighbor-advertisement -m hl --hl-eq 255 -j ACCEPT
    #$IP6TABLES -A INPUT -p icmpv6 --icmpv6-type router-solicitation -m hl --hl-eq 255 -j ACCEPT
    #$IP6TABLES -A INPUT -p icmpv6 --icmpv6-type router-advertisement -m hl --hl-eq 255 -j ACCEPT
    $IP6TABLES -A INPUT -p tcp --dport 22 -j ACCEPT
    $IP6TABLES -A INPUT -p tcp --dport 80 -j ACCEPT
    $IP6TABLES -A INPUT -p icmpv6 --icmpv6-type destination-unreachable -j ACCEPT
    $IP6TABLES -A INPUT -p icmpv6 --icmpv6-type packet-too-big -j ACCEPT
    $IP6TABLES -A INPUT -p icmpv6 --icmpv6-type time-exceeded -j ACCEPT
    $IP6TABLES -A INPUT -p icmpv6 --icmpv6-type parameter-problem -j ACCEPT
    $IP6TABLES -A INPUT -p icmpv6 --icmpv6-type echo-request -j ACCEPT -m limit --limit 60/minute
    # need this for ip6tables but not iptables
    $IP6TABLES -A INPUT -p icmpv6 --icmpv6-type echo-reply -j ACCEPT

    $IP6TABLES -P INPUT DROP
    $IP6TABLES -P FORWARD DROP
    $IP6TABLES -P OUTPUT ACCEPT
fi

exit 0
