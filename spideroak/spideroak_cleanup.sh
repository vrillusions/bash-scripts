#!/bin/bash -e
#
# As the backups run you'll notice certain files that change often but are not
# really important to back up.  For example the .bash_history file changes
# often but not really important.  Run this for those files and directories and
# it will exclude that file or directory and then completely purge it from
# spideroak.  NOTE: This only purges it from spideroak and not the local file.
# Of course make sure you backup anything important before running this just in
# case.
#
# Note: I intentionally don't use the --force option. This means if you try to
# exclude a folder that doesn't exist it will complain. I do this assuming I
# typed the path in wrong. If it's expected then you can add "--force" to the
# functions

SPIDEROAK='/usr/bin/SpiderOak'

echodate () {
    echo "$(date +"%Y-%m-%dT%H:%M:%S%z") $@"
}

spideroak_cleanup_dir() {
    echodate "Exclude and Purge directory: $1"
    $SPIDEROAK --exclude-dir=$1 >/dev/null
    $SPIDEROAK --purge=$1 >/dev/null
}

spideroak_cleanup_file() {
    echodate "Exclude and Purge file: $1"
    $SPIDEROAK --exclude-file=$1 >/dev/null
    $SPIDEROAK --purge=$1 >/dev/null
}

# I typically keep these around but comment them out after I run them once.
spideroak_cleanup_dir /root/.cache

spideroak_cleanup_file /root/.bash_history
spideroak_cleanup_file /root/.viminfo


# Print out current selection
$SPIDEROAK --selection

exit 0
