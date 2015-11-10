#!/bin/bash
#
# All the SNMPv3 stuff I found usually just gave you a block of text without
# explaining it. So I made this. Edit any of the variables as needed but will
# work with defaults just fine.
#
# The snmpd.conf isn't a partial file. In looking this up and for the most
# common case of where you want to give a user full readonly access it only
# requires a single 'rouser' line
#
# TODO:2014-05-02:teddy: add commands to disable logging
#


### Bash options
set -e
set -u


# Make sure we have superuser access before continuing
if [[ $EUID -ne 0 ]]; then
    echo "Must be run as root or via sudo" >&2
    exit 1
fi


# Usage: log "What to log"
log () {
    printf "%b\n" "$(date +"%Y-%m-%dT%H:%M:%S%z") $*"
}

# Used to generate a random passphrase. Can replace the command with whatever
# method you prefer (pwgen, uuidgen, etc) but this should be the most
# compatible
# Usage: my_var="$(get_random_passphrase)"
get_random_passphrase () {
    dd if=/dev/urandom bs=32 count=1 2>/dev/null | openssl md5 -r | awk '{print $1}'
}


## Make sure snmpd is off before starting
service snmpd stop


## User setup
# auth_md - Message digest to use for authentication. SHA is preferred
#     over MD5
# encrypt_cipher - Cipher to use for encryption. AES is preferred over
#     DES
# rouser_name - the name of the user
# auth_passphrase - the passphrase used to authenticate the message
# encrypt_passphrase - the passphrase used to encrypt the message. This
#     can be the same as auth_passphrase but it's more secure if you
#     don't.
#
# By default the username is ROUser and passphrases are generated
auth_md=SHA
encrypt_cipher=AES
rouser_name=ROUser
auth_passphrase="$(get_random_passphrase)"
encrypt_passphrase="$(get_random_passphrase)"
# Alternatively can hardcode them although this isn't recommended.
#
# It is worth noting that snmpd upon startup will take the values added by
# net-snmp-config and replace them with derived keys based on unique server
# token. This means even if someone had access to the user databases from
# several systems they wouldn't be able to determine the actual values.
# Although if a bad guy has enough access rights to view the user db then snmp
# is the least of your concerns.
#auth_passphrase="SuperSecretAuth"
#encrypt_passphrase="SuperSecretEncrypt"
log "auth_passphrase: ${auth_passphrase}"
log "encrypt_passphrase: ${encrypt_passphrase}"


## Server setup
# min_security_level - The minimum level of security required for this user.
#     'priv' (default) requires both authentication and encryption. 'auth'
#     requires authentication and optionally encrypted. There's also 'noauth'
#     but at that point just go back to snmpv2. If you don't consider the
#     information private then 'auth' would still prevent tampering and ensure
#     the data get corrupted along the way.
min_security_level=priv

log "Creating ${rouser_name}"
# net-snmp-config would be nice if it didn't have so many dependencies so doing
# this the hard way:
echo "createUser ${rouser_name} ${auth_md} ${auth_passphrase} ${encrypt_cipher} ${encrypt_passphrase}" >>/var/lib/snmp/snmpd.conf

log "Backing up existing snmpd.conf"
cp -f /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.bak

log "Creating /etc/snmp/snmpd.conf"
cat > /etc/snmp/snmpd.conf <<_EOF_
# Listen on all addresses. This is the default. Access should be restricted via
# iptables or similar methods
agentAddress udp:161
# Alternatively this would restrict to localhost and another ip (for example if
# openvpn is running you can put that ip here)
#agentAddress udp:127.0.0.1:161,udp:172.16.0.14:161

# System info
syslocation Somewhere, USA
syscontact Your Name <YourEmail@example.com>

# priv - require authentication and encryption
# auth - require authentication. May be encrypted but optional
# noauth - no authentication, basically snmpv2
rouser -s usm ${rouser_name} ${min_security_level}

# Uncomment this to allow SNMPv1 and SNMPv2c requests using the default
# community string 'public' only for localhost. Remove localhost part if you
# want to allow it from anywhere
#rocommunity public localhost

#This line allows Observium to detect the host OS if the distro script is installed
# Install:
#     cd /usr/local/bin
#     wget http://www.observium.org/svn/observer/trunk/scripts/distro
#     chmod 0755 distro
extend .1.3.6.1.4.1.2021.7890.1 distro /usr/local/bin/distro
_EOF_
cd /usr/local/bin
wget http://www.observium.org/svn/observer/trunk/scripts/distro
chmod 0755 distro

log "Starting snmpd back up"
service snmpd start

exit 0
