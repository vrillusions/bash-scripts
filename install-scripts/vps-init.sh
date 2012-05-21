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
read USER

# ---
# regenerate ssh server keys - more than likely all vps guests have the same ssh
# keys which isn't as secure as if you make your own
# This affects new connections only so safe to run while connected via ssh
echo "Regenerate SSH Keys"
rm -f /etc/sshd/ssh_host_*
/etc/init.d/ssh restart
echo

# ---
echo "Disabling root login"
sed -e "s/^PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config >/tmp/sshd_config
mv /tmp/sshd_config /etc/ssh/sshd_config
/etc/init.d/ssh restart
echo

# ---
# Create normal user
# TODO: check if user already exists, assume we created it already
echo "Creating user $USER, You will be asked to input extra details and password"
adduser $USER
echo 

# ---
# SSH setup for new user
echo "Generating ssh key for user $USER"
echo "You'll be prompted for a password, typically this is left blank but feel"
echo "free to enter one"
mkdir /home/$USER/.ssh
chown $USER:$USER /home/$USER/.ssh
chmod 700 /home/$USER/.ssh
su -c "ssh-keygen -t rsa -b 2048 -f /home/$USER/.ssh/id_rsa"
if [ -f "sshkeys.txt" ]; then
    cat sshkeys.txt /home/$USER/.ssh/authorized_keys
    chown $USER:$USER /home/$USER/.ssh/authorized_keys
    chmod 600 /home/$USER/.ssh/authorized_keys
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
apt-get -y install "$APT_PKGS"

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

exit 0

