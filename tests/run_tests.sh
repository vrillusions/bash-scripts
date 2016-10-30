#!/bin/bash
#
# Runs tests. In this case it's shellcheck across all *.sh files
#


set -e
set -u


# -- script constants --
# set script_dir to location this script is running in
readonly script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


PATH="${HOME}/bin:${PATH}"


# -- logging functions --
# Usage: log "What to log"
log () {
    # logger will output to syslog, useful for background tasks
    #logger -s -t "${script_name}" -- "$*"
    # printf is good for scripts run manually when needed
    printf "%b\n" "$(date +"%Y-%m-%dT%H:%M:%S%z") $*"
}

log "Running shellcheck in $(pwd)"

if [[ "$(uname -s)" == "Darwin" ]]; then
    # OS X doesn't have the -r option
    xargs_custom_opts=''
else
    xargs_custom_opts='-r'
fi

# If you want a more verbose run then add after 'xargs -0' the options '-n1 -t'.
# This will test a single file at a time and print what file it's testing. Could
# be useful if you hit some weird issue and you don't know what file is causing
# it. Also without those options it doesn't list out the files so you're not
# certain if it's actually being picked up.
retcode=0
find . -type f -name "*.sh" -print0 \
    | xargs -0 ${xargs_custom_opts} shellcheck \
    || retcode=$?

log "Finished"

exit $retcode
