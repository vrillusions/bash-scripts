#!/bin/bash
# Updates dynamic dns record at dns.he.net.
# Password is the keyphrase generated for that record
#
# This will auto-detect your external ip.  If you run into problems add a new
# -d paremeter like `-d "myip=10.0.0.0"`.  Using ssl helps with detecting the
# right external ip and not an intermediate proxy.
#
# To use, set the following two environment variables:
#   HE_HOSTNAME = The hostname you're updating
#   HE_PASSWORD = Keyphrase given on web interface
#
# Example:
#   HE_HOSTNAME='w.example.com' HE_PASSWORD='secret' ./update_dns.sh
#
# Alternatively you can hardcode the values into this script
#
# Some known responses (replace aa.bb.cc.dd with new ip):
#   'nochg aa.bb.cc.dd' - there was no change necessary
#   'good aa.bb.cc.dd'  - the change was made successfully
#   'badauth'           - authentication failed (this response is handled)

set -e
set -u

HE_HOSTNAME=${HE_HOSTNAME:-'host.example.com'}
HE_PASSWORD=${HE_PASSWORD:-'SecretPassword'}


script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# They use a self-signed certificate. Cert obtained from running
#   echo | openssl s_client -connect 'dyn.dns.he.net:443' >dyn.dns.he.net.crt
# The remove everything but the server certificate
cacert="${script_dir}/dyn.dns.he.net.crt"

# Update IPv4 IP
result=$(curl -4 --silent "https://dyn.dns.he.net/nic/update" \
    -d "hostname=${HE_HOSTNAME}" \
    -d "password=${HE_PASSWORD}" \
    --cacert "${cacert}")

if [[ "${result}" == "badauth" ]]; then
    echo "Bad authentication, dns has not been updated" >&2
    exit 1
else
    echo "${result}"
fi

# Update IPv6 IP if applicable. Commented out by default
## If you use IPv6 then uncomment this block (or change the '-4' to '-6' if you
## want to update just IPv6)
#curl -6 --silent "https://dyn.dns.he.net/nic/update" \
#    -d "hostname=${HE_HOSTNAME}" \
#    -d "password=${HE_PASSWORD}" \
#    --cacert "${cacert}"

exit 0

