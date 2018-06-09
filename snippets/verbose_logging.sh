#!/bin/bash -e
#
# A way of implementing verbose levels to show more and more information.  This
# version expects the VERBOSE env variable to be set to the desired verbosity.
#

debug_echo() {
    # Display message if $VERBOSE >= 1
    if [ "$VERBOSE" -ge 1 ]; then
        echo "$1" 1>&2
    fi
}

# level 0 - quiet
# level 1 - shows debug_echo statements
# level 2 - shows output from commands
# level 3 - trace script output
# if not set make it 0
VERBOSE=${VERBOSE:-"0"}
debug_echo "verbose level $VERBOSE"
if [ "$VERBOSE" -le 1 ]; then
    # quiet for 0,1
    XSTDOUT=">/dev/null"
    XSTDERR="2>/dev/null"
else
    XSTDOUT=""
    XSTDERR=""
fi
if [ "$VERBOSE" -ge 3 ]; then
    # trace output
    set -x
fi

print "hello world" "${XSTDOUT}" "${XSTDERR}"
