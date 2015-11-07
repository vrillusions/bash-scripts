#!/bin/bash
# This adds the current ip address to /etc/issue, which displays on console.
# Useful for local VMs to see the IP address without having to login to local
# console first.  Call this script from /etc/rc.local
#
# TODO: use more sources for ip (facter, ip addr) and add a --help option

set -e
set -u


# -- option handling --
# Defaults
dryrun="false"
interface="eth0"

while getopts ":hdi:" opt; do
    case ${opt} in
    h)
        echo "Usage: $(basename $0) [OPTION]"
        echo 'Update /etc/issue with system IP'
        echo
        echo 'Options:'
        echo '  -h  this help message'
        echo "  -d  dry run. Say what would have changed but don't do it"
        echo "  -i  interface that has the right ip (default: ${interface})"
        exit 0
        ;;
    i)
        interface=${OPTARG}
        ;;
    d)
        dryrun=true
        ;;
    \?)
        echo "Invalid option: -${OPTARG}" >&2
        exit 96
        ;;
    :)
        echo "Option -${OPTARG} requires an argument" >&2
        exit 96
        ;;
    esac
done
shift $(expr ${OPTIND} - 1)


ip_address="$(/sbin/ifconfig ${interface} \
    | sed '/Bcast/!d' \
    | awk '{print $2}' \
    | awk '{print $2}' FS=":")"

if [[ "${dryrun}" != 'true' ]]; then
    # cleanup current /etc/issue
    sed -i -e '/ IP Address/d' /etc/issue
    echo " IP Address: ${ip_address}" >>/etc/issue
else
    echo "Would have wrote ip ${ip_address} to /etc/issue"
fi

exit 0
