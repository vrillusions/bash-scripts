#!/bin/bash -e
#
# Initial setup steps on an OVH server.
#
# Used environment variables:
#   DEBUG - (default: false) if true will print more information on what it's 
#           doing
#   TRACE - (default: false) traces the entire execution of script. Only useful
#           if something really goes wrong
#

# set script_dir to location this script is running in
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ${SCRIPT_DIR}/functions/logging.sh

# Options:
# Turn on debug?
#DEBUG="true"

# Trace output?
#TRACE="true"

# Install iptables?
INSTALL_IPTABLES=${INSTALL_IPTABLES:-"yes"}

# Install puppet?
INSTALL_PUPPET=${INSTALL_PUPPET:-"yes"}


# uncomment this when you're happy with all the settings.
fail "Please read file before running it."

# Set defaults in case not set above or in environment
TRACE=${TRACE:-"false"}
# Want to turn on tracing as soon as possible if set
if [[ "$TRACE" == "true" ]]; then
    set -e
fi
DEBUG=${DEBUG:-"false"}


log "Done."
exit 0
