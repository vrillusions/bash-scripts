#!/bin/bash
#
# Disable SpiderOak Hive share
#
# On headless systems I don't have a need for the default sync folder called
# "SpiderOak Hive" that comes with every spideroak installation. This uses some
# recent (2014) additions to client that allows you to set a preferences file
# with all the options that you can't set via CLI.

set -e
set -u

preference_file=/etc/SpiderOak/Preferences

# Make sure SpiderOak is in path or exit
which SpiderOak &>/dev/null || exit 2

# Since this file isn't created automatically if it exists then someone must
# have had a good reason for it. So just be safe and exit
if [[ -f "${preference_file}" ]]; then
    echo "${preference_file} exists. See script for manual instructions."
    exit 3
fi

# Create preference file and disable GlobalSync (what they call spideroak hive)
echo "Creating preference file"
mkdir "${preference_file%/*}"
cat > "${preference_file}" <<"_EOF_"
{
    "GlobalSyncEnabled": false
}
_EOF_
echo

# Debated making this automated as well but for the people that just copy and
# paste something they find on the web I don't want to just be removing stuff
# off the system (granted it's "Their Own Fault" for doing that but). So just
# going to say what to do.

cat <<"_EOF_"
Preference file created. At this point SpiderOak Hive will no longer be synced
to spideroak. You may now choose to remove the local folder as well as all
history as seen from this system by running the following commands. Be aware
that the purge command will permanently remove all traces of the file from your
spideroak account.

These commands assume you are root

rm -rf "/root/SpiderOak Hive"
SpiderOak --purge "/root/SpiderOak Hive"
SpiderOak --verbose --batchmode
_EOF_

exit 0
