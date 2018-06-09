
# only intended to be sourced, not run directly so no `#!/bin/bash`
# shellcheck shell=bash
#
# Several function to print out to screen with a date stamp
#
# Usage:
#   source ./log_function.sh
#
# Don't have a 'shebang' at top because this should always be sourced from main
# script. Also doesn't need to be executable.
#
# Expected environment variables:
#   VERBOSE - verbose function will only print out of this is 'true'
#

# log "What to log"
log () {
    printf "%b\\n" "$(date +"%Y-%m-%dT%H:%M:%S%z") $*"
}

# verbose "What to log if verbose is true"
verbose () {
    if [[ "x$VERBOSE" == "xtrue" ]]; then
        log "$*"
    fi
}

# warn "What to log to STDERR but not exit"
warn () {
    log "$*" >&2
}

# fail "Message to print to STDERR before exiting"
# Purposely don't use warn function just in case you want this to go to STDOUT
fail () {
    log "$*" >&2
    exit 1
}
