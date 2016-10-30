#!/bin/bash
#
# Installs shellcheck using the precompiled ones at
# https://github.com/caarlos0/shellcheck-docker
#
# Environment Variables:
#   SHELLCHECK_VERSION: version of shellcheck to use, defaults to 0.4.3
#
# Exit codes:
#    0  No error
#   96  Problem while parsing options
#


set -e
set -u


# -- script constants --
# set script_dir to location this script is running in
readonly script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


# -- env variables --
SHELLCHECK_VERSION="${SHELLCHECK_VERSION:-"0.4.3"}"


# -- logging functions --
# Usage: log "What to log"
log () {
    # logger will output to syslog, useful for background tasks
    #logger -s -t "${script_name}" -- "$*"
    # printf is good for scripts run manually when needed
    printf "%b\n" "$(date +"%Y-%m-%dT%H:%M:%S%z") $*"
}


if [[ "$(uname -s)" == "Darwin" ]]; then
    log "OS X detected, attempting install with homebrew"
    brew update
    brew install shellcheck
else
    log "Performing linux environment install"
    if [[ ! -d "${HOME}/bin" ]]; then
        mkdir ~/bin
    fi
    curl -Ls \
        -o "${HOME}/bin/shellcheck" \
        "https://github.com/caarlos0/shellcheck-docker/releases/download/v${SHELLCHECK_VERSION}/shellcheck"
    chmod +x "${HOME}/bin/shellcheck"
fi

log 'Install process finished'

exit 0
