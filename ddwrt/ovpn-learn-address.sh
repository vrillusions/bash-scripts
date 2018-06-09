#!/bin/sh
# Set this to openvpn's learn-address option to add vpn clients to hosts file for dnsmasq
# You also may want to have the start script touch /tmp/hosts-openvpn
#
# Add the following extra option to dnsmasq:
#
#     addn-hosts=/tmp/hosts-openvpn
#
# parameters received (note you may receive a network range depending on server type
# add 1.2.3.4 client-name-goes-here
# update 1.2.3.4 client-name-goes-here
# delete 1.2.3.4
#
# TODO: this doesn't make sure it's just an ip before modifying it

domain_suffix='vpn.EXAMPLE.COM'

hostfile=/tmp/hosts-openvpn
#lockfile=/tmp/learn-address.lock

# WARNING: CURRENTLY CAN ENTER RACE CONDITION
#
# What that means is it's possible for openvpn to call this script multiple
# times.  Thus the file could be modified multiple times.
#
# Probably best approach would be to check a lock file and to keep checking
# every second until it's released, failing after maybe a minute or two.  This
# could cause an issue with a lot of processes being created that are waiting
# for a lock to release
#
# There's also the flock command that does this all for you, but doesn't exist
# in ddwrt
#
# Haven't run in to issues with this yet and perhaps it may actually not be an
# issue.  Haven't tested if openvpn will only run the command once and wait for
# it to exit before running it again

[ -f "$hostfile" ] || /bin/touch "$hostfile"

case "$1" in
    add|update)
        /bin/sed -i -e "/$2/d" "$hostfile"
        /bin/echo "$2 ${3}.${domain_suffix}" >>"$hostfile"
        ;;
    delete)
        /bin/sed -i -e "/$2/d" "$hostfile"
        ;;
esac

# signal dnsmasq to reread hosts file
/bin/kill -HUP "$(cat /var/run/dnsmasq.pid)"

exit 0

