#!/bin/bash
####
# Very basic example of mktemp and trap
#
# The trap ensures that no matter what the reason the script exits it will
# remove the temporary file. A similar system could be used to setup a lock
# file. This would be done by creating a known file like /var/run/scriptname
# and then have the script check for the presence of that file before it
# continues.

set -e
set -u

script_name="$(basename "$0")"

# BUG: need to test if ~/temp exists
export TMPDIR=${TMPDIR:-"${HOME}/temp"}
tmpfile=$(mktemp --tmpdir "${script_name}.XXXXXXXXX")
echo "Using temp file ${tmpfile}"

trap 'rm -f "${tmpfile}"' EXIT

# Just some example stuff to put in file
uptime >>"${tmpfile}"
w >>"${tmpfile}"
cat "${tmpfile}"

# Note that we are just exiting without removing the tmpfile but it will be
# handled by trap command at top

exit 0
