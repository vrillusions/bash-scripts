#!/bin/bash -e
echo "Not to be run in shell, view file instead"
exit 0

sudo su -
apt-get install backupninja hwinfo
cp /usr/share/doc/backupninja/examples/example.sys /etc/backup.d/10-sysinfo.sys
# if mysql is installed
#cp /usr/share/doc/backupninja/examples/example.mysql /etc/backup.d/50-databases.mysql
cp /usr/share/doc/backupninja/examples/example.rdiff /etc/backup.d/90-to_auron.rdiff
cd /etc/backup.d
chown root:root *
chmod 600 *
# disable it for now
mv 90-to_auron.rdiff 90-to_auron.rdiff.disabled
vi 10-sysinfo.sys
# set partitions = no on openvz containers
vi 90-to_auron.rdiff.disabled
# may want to turn off version check
# set hostname
# add any other folders needed.  usually at least /srv but for mumble you'll need
#   /var/lib/mumble-server as well
# for destination you can leave the defaults
ssh-kegen -t rsa -b 2048
vi ~/.ssh/config
    Host backhost
      HostName auron.vrillusions.com
      User backupuser
# copy the contents of ~/.ssh/id_rsa.pub to ~/.ssh/authorized_keys for the backupuser on auron
# can reenable it now
mv 90-to_auron.rdiff.disabled 90-to_auron.rdiff
vi /etc/backupninja.conf
# leave reportsuccess on for a day or two
# can change the backup time if you want
