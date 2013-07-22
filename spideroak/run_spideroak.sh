#!/bin/bash
# don't add -e or pgrep will cause it to exit early
#
# This is meant to be run via cron nightly. It finishes all tasks and then
# exists (--batchmode).  It also goes through and cleans up old versions and
# trash.

SPIDEROAK='/usr/bin/SpiderOak'

# Check if SpiderOak is already running and cancel if it is
pgrep SpiderOak &>/dev/null
SPIDEROAK_NOT_RUNNING=$?
if [[ "$SPIDEROAK_NOT_RUNNING" -eq "0" ]]; then
    echo "SpiderOak is already running, not rerunning" 1>&2
    exit 1
fi

# Get a list of selections since you can't easily pull this from SpiderOak
$SPIDEROAK --selection >/root/spideroak_selection.txt

# Purposely made it overwrite the log or else it would get too large. could cause an issue
# if this runs multiple times though.
$SPIDEROAK --verbose --batchmode >/var/log/spideroak.log

# Does default schedule:
#   - hourly for last 24 hours
#   - daily for last month
#   - weekly thereafter
$SPIDEROAK --verbose --purge-historical-versions >>/var/log/spideroak.log

# Remove items from trash after 30 days. To keep forever comment or remove line 
$SPIDEROAK --verbose --purge-deleted-items=30 >>/var/log/spideroak.log

exit 0
