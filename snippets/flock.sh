#!/bin/bash
#
# While there's an actual flock command it's not available on all systems.
# Instead we try to create a directory which will fail if the directory already
# exists.  We also create a trap to make sure that directory is removed when
# the script exits
#
# Important notes:
# - avoid using /tmp/ for lock files as some systems periodically clean that.
# - the order of the commands is important. the trap needs to come after you
#   try to mkdir. if not then when the test fails and the script exits it will
#   remove the directory.


set -e
set -u


# -- Script-wide variables --
readonly script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly script_name="$(basename $0)"


# -- Logging functions --
# Usage: log "What to log"
log () {
    # logger will output to syslog, useful for background tasks
    #logger -s -t "${script_name}" -- "$*"
    # printf is good for scripts run manually when needed
    printf "%b\n" "$(date +"%Y-%m-%dT%H:%M:%S%z") $*"
}


# -- create a flock dir --
_flockdir="${script_dir}/.flock_${script_name}"
__sig_exit () {
    rmdir "${_flockdir}"
}
if ! mkdir "${_flockdir}" 2>/dev/null ; then
    log "unable to create lock file, exiting" >&2
    exit 2
fi
trap __sig_exit EXIT


echo "simulate a long running process"
sleep 60
echo "end simulation"

exit 0
