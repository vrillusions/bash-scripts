#!/bin/bash
# This is meant to be run via cron nightly. It finishes all tasks and then
# exits (--batchmode).  It also goes through and cleans up old versions and
# trash.
#
# This outputs progress messages to STDOUT. When running through you'll want to
# redirect that to /dev/null. For example:  `./run_spideroak.sh >/dev/null`
#
# Exit codes used:
# 0   - no errors
# 1   - some unhandled error (this script won't using exit code of 1)
# 100 - script lockfile exists so not running
# 101 - SpiderOak is already running (SpiderOak checks this as well but it
#       still (wrongfully IMO) returns an exit code of 0 so can't rely on it)

set -e
set -u

# Command that is run, default should be fine
spideroak_cmd="/usr/bin/SpiderOak"

# The output from your .config/SpiderOak directory should be sufficient but you
# may also log the output from this script by having this point to some file
# instead of just /dev/null
logfile="/dev/null"

# This will save the output of `SpiderOak --selection` to this file. Default
# assumes SpiderOak is running as root
selection_backup="/root/spideroak_selection.txt"

# Remove items from SpiderOak that have delete from system after this many days.
purge_days=30

# Shouldn't have to change this unless for some reason you can't create files in
# /var/lock
lockfile="/var/lock/run_spideroak.lock"


# Usage: log "whatever you want to log"
log () {
    printf "%b\n" "$(date +"%Y-%m-%dT%H:%M:%S%z") $*"
}


# If the lockfile exists already, then this must be running already and so exit
[[ -f "${lockfile}" ]] && exit 100
# trap should cleanup lock file no matter how script exits
trap "rm -f \"${lockfile}\"" EXIT
touch "${lockfile}"


# Check if SpiderOak is already running and cancel if it is
spideroak_running="$(pgrep SpiderOak &>/dev/null; echo $?)"
if [[ "${spideroak_running}" -eq "0" ]]; then
    echo "SpiderOak is already running, not rerunning" 1>&2
    exit 101
fi


# Get a list of selections since you can't easily pull this from SpiderOak
log "Save backup selection to file"
"${spideroak_cmd}" --selection >"${selection_backup}"

# Purposely made it overwrite the log or else it would get too large. could
# cause an issue if this runs multiple times though.
log "Running SpiderOak"
"${spideroak_cmd}" --verbose --batchmode >"${logfile}"

# Does default schedule:
#   - hourly for last 24 hours
#   - daily for last month
#   - weekly thereafter
log "Purge historical versions"
"${spideroak_cmd}" --verbose --purge-historical-versions >>"${logfile}"

# Remove items from trash. To keep forever comment or remove line
log "Purge deleted items"
"${spideroak_cmd}" --verbose --purge-deleted-items=${purge_days} >>"${logfile}"

log "Finished successfully"
exit 0
