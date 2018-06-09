#!/bin/bash
#
# Downloads all the releases from 8bitpeoples.com
#
# Environment Variables:
#     VERBOSE: Set to 'true' to output more information. Default is 'false'
#


set -e
set -u


### Options not modifiable via command line options
# Typically stuff that shouldn't be changed
# Sleep this long between each fetch
sleeptime=5

# User agent sent to server. Begin with Wget in case server checks for a common
# user agent.
useragent="Wget/custom_(https://github.com/vrillusions/bash-scripts/site_downloaders/8bitpeoples.sh)"

# Options to wget
# --continue - continue partial downloads
# --no-directories - don't create directories
# --user-agent "${useragent}" - user agent from above
#
# Options set further down
# -q or -nv - depends if user wants no output (-q) or some output (-nv)
#
wget_opts=" \
    --continue \
    --user-agent ${useragent} \
    --no-directories"

echo "THIS NO LONGER WORKS DUE TO A SITE REDESIGN" >&2
exit 1


### Logging functions
# Usage: log "What to log"
log () {
    printf "%b\\n" "$(date +"%Y-%m-%dT%H:%M:%S%z") $*"
}
# Usage: verbose "What to log if VERBOSE is true"
verbose () {
    if [[ "${VERBOSE}" == "true" ]]; then
        log "$*"
    fi
}
# Usage: logerror "Mesage to log to STDERR"
logerror () {
    log "$*" >&2
}
# Usage: logexit "Message to log to STDERR and then exit"
logexit () {
    logerror "$*"
    exit 4
}


# set script_dir to location this script is running in
readonly script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# set this here or can't use after getopts
#script_name="$(basename $0)"
# full command which can be printed out if needed
#script_cmd="$*"


### Option Handling
# Defaults
latest_release="100"
destination_dir="${script_dir}"
output_level=""
VERBOSE=${VERBOSE:-"false"}

while getopts ":hvqd:r:" opt; do
    case ${opt} in
    h)
        echo "Usage: $(basename "$0") [OPTION]"
        echo 'Download discography from 8bitpeoples.com'
        echo
        echo 'Options:'
        echo '  -h  this help message'
        echo "  -d  destination directory (default: ${destination_dir})"
        echo "  -r  latest release number (default: ${latest_release})"
        echo '  -q  be quiet'
        echo '  -v  be verbose'
        exit 0
        ;;
    d)
        destination_dir=${OPTARG}
        ;;
    r)
        latest_release=${OPTARG}
        ;;
    q)
        output_level="--quiet"
        ;;
    v)
        VERBOSE=true
        output_level="--verbose"
        ;;
    \?)
        logexit "Invalid option: -${OPTARG}"
        ;;
    :)
        logexit "Option -${OPTARG} requires an argument"
        ;;
    esac
done
shift $(( OPTIND - 1 ))
verbose "Additional arguments after options: $*"


if [[ ! -d "${destination_dir}" ]]; then
    logerror "Destination directory (${destination_dir}) doesn't exist"
    logexit "Please correct and rerun script. Remember to check permissions"
fi

declare -i exit_status
declare -i release_number
release_number=${latest_release}

# releases 001 and 002 aren't availble to download
while [[ $release_number -gt 2 ]]; do
    printf -v catalog_number "%03u" "${release_number}"
    source_url="http://www.8bitpeoples.com/discography/zip/8BP${catalog_number}"
    output_file="${destination_dir}/8BP${catalog_number}.zip"
    # wget_opts and output_level can't be quoted
    # shellcheck disable=SC2086
    wget ${wget_opts} ${output_level} "${source_url}" -O "${output_file}"
    exit_status=$?
    if [[ ${exit_status} -eq 4 ]]; then
        logerror "Network failure, possibly file doesn't exist. Attempted url:"
        logerror "${source_url}"
    fi
    printf -v release_number "%u" $((release_number - 1))
    sleep $sleeptime
done

# SECONDS is a bash builtin
verbose "Script ran for ${SECONDS} seconds"

exit 0

