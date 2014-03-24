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

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
script_name="$(basename $0)"

export TMPDIR=${TMPDIR:-"${HOME}/temp"}
tmpfile=$(mktemp --tmpdir ${script_name}.XXXXXXXXX)
echo "Using temp file ${tmpfile}"

trap "rm -f $tmpfile" EXIT

uptime >>"${tmpfile}"
w >>"${tmpfile}"
cat "${tmpfile}"

exit 0
