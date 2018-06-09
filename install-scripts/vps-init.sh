#!/bin/bash -e
# This will probably be pointless for anyone other than me, but maybe worthwhile
#
# Requires:
# - ubuntu / debian os
# - a file called 'sshkeys.txt' that will be used to populate .ssh/authorized_keys

echo "WORK IN PROGRESS - DO NOT USE"
exit 1

if [[ $EUID -ne 0 ]]; then
    echo "Must be run as root"
    exit 1
fi

# Specify the package list. This should just be the minimum that you find yourself
# always installing anyway
APT_PKGS="aptitude wget curl whois vim dnsutils rsync"


echo "WARNING: THIS PROBABLY WON'T BE AS USEFUL FOR ANYONE OTHER THAN MYSELF. FEEL"
echo "FREE TO PICK OUT THE PARTS YOU LIKE THOUGH."
echo

# initial Q&A
echo "Give the name of the new user to create:"
read -r USER
echo

# ---
# Make sure locale settings are correct
# Even when setup the only one that's set is $LANG so unsure how to verify this
echo "Setting locale"
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales
echo

# ---
# DISABLED FOR NOW
## TODO: actually regen the keys and don't rely on ssh init script to do it
## regenerate ssh server keys - more than likely all vps guests have the same ssh
## keys which isn't as secure as if you make your own
## This affects new connections only so safe to run while connected via ssh
#echo "Regenerate SSH Keys"
#rm -f /etc/ssh/ssh_host_*
## ecdsa doesn't regen automatically
#ssh-keygen -t ecdsa -f ssh_host_ecdsa_key -N ""
#/etc/init.d/ssh restart
#echo

# ---
echo "Disabling root login"
sed -e "s/^PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config >/tmp/sshd_config
mv /tmp/sshd_config /etc/ssh/sshd_config
/etc/init.d/ssh restart
echo

# ---
# Create normal user
# TODO: check if user already exists, assume we created it already
echo "Creating user ${USER}, You will be asked to input extra details and password"
adduser "${USER}"
echo

# ---
# And add to admin groups
echo "Adding user ${USER} to sudo and adm groups"
adduser "${USER}" sudo
adduser "${USER}" adm
echo

# ---
# SSH setup for new user
echo "Generating ssh key for user ${USER}"
echo "You'll be prompted for a password, typically this is left blank but feel"
echo "free to enter one"
mkdir "/home/${USER}/.ssh"
chown "${USER}":"${USER}" "/home/${USER}/.ssh"
chmod 700 "/home/${USER}/.ssh"
su -c "ssh-keygen -t rsa -b 2048 -f /home/${USER}/.ssh/id_rsa" "${USER}"
if [ -f "sshkeys.txt" ]; then
    cat sshkeys.txt >"/home/${USER}/.ssh/authorized_keys"
    chown "${USER}":"${USER}" "/home/${USER}/.ssh/authorized_keys"
    chmod 600 "/home/${USER}/.ssh/authorized_keys"
else
    echo "Could not find sshkeys.txt, skipping autopopulation of authorized_keys"
fi
echo

# ---
# setup apt
echo "Updating and configuring apt packages"
# dumps a list of packages prior to us messing about
dpkg --get-selections "*" >dpkg-original.txt
apt-get update
apt-get -y dist-upgrade
apt-get -y install "${APT_PKGS}"

# ---
# setup denyhosts
echo "Setting up denyhosts"
echo "TODO"
echo

# ---
# setup iptables
echo "Configuring iptables"
echo "TODO"
cd /root
wget -q https://raw.github.com/vrillusions/bash-scripts/master/iptables/iptables-init.sh
wget -q https://raw.github.com/vrillusions/bash-scripts/master/iptables/iptables-reset.sh
echo "Placed scripts in /root"
echo

# ---
# regenerate times that crontab uses for things like @daily or @hourly
# another one of those things that all vps guests probably have set to same thing
echo "Generating new times for crontab run-parts commands (eg @daily)"
echo "TODO"
echo

# ---
# Post Report
echo "Initial configuration completed!"
echo "You should reconnect all ssh connections to use the new ssh key (remember"
echo "your ssh client is going to complain about a new key, this is normal since"
echo "we did create new keys)"
echo
echo "You should verify that PermitRootLogin is set to no in /etc/ssh/sshd_config."
echo "Also once you verified ssh keys work you should disable PasswordAuthentication."
echo
echo "Since dist-upgrade was run it's recommended you restart the vps as there"
echo "may have been some system updates that require it."
echo
echo "While iptables wasn't configured the scripts were downloaded. Make them executable"
echo "and verify they work before adding to /etc/rc.local"

exit 0

