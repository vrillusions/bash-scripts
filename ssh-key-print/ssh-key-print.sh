#!/bin/bash
#
# Reads the system's public keys and prints out hashes which can be used to
# verify you are connecting to the correct server


### Bash options
# exit upon receiving a non-zero exit code
set -e
# enable debuging
#set -x
# upon attempt to use an unset variable, print error and exit
set -u
# fail on first command in pipeline that fails, not last
#set -o pipefail


### Logging functions
# Usage: log "What to log"
log () {
    printf "%b\n" "$(date +"%Y-%m-%dT%H:%M:%S%z") $*"
}


### Option Handling
while getopts ":h" opt; do
    case $opt in
    h)
        printf "usage: %s\n" "$(basename $0)"
        printf "%s\n\n" "prints ssh key fingerprints to screen"

        printf "options:\n"
        printf "  -%1s  %s\n" "h" "this help message"
        exit 0
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    esac
done
shift `expr $OPTIND - 1`


# Centers text. if second param isn't given then 72 is assumed
# Usage: center "This is my text" 50
center () {
    local width
    local padding
    local result
    if [[ $# -eq 1 ]]; then
        width=74
    elif [[ $# -eq 2 ]]; then
        width=$2
    else
        log "(center) ERROR: must specify one or two arguments"
        exit 1
    fi
    padding=$[${width} / 2 + ${#1} / 2]
    printf "%*s" ${padding} "${1}"
}

# Takes two arguments. Type of key and then filename
# Usage: process_key "ECDSA" "/etc/ssh/ssh_host_ecdsa_key.pub"
# TODO:2013-12-15:teddy: the type can be extracted from ssh-keygen
process_key () {
    local filename
    local key_bytes
    local fingerprint
    local sha1
    local sha256
    if [[ $# -ne 2 ]]; then
        log "(process_key) ERROR: requires exactly two arguments"
        exit 1
    fi
    if [[ -f $2 ]]; then
        filename="$2"
        key_bytes="$(awk '{print $2}' ${filename} | openssl base64 -d -A)"
        fingerprint="$(ssh-keygen -l -f ${filename} | awk '{print $2}')"
        sha1="$(echo -n "${key_bytes}" | openssl sha1 | awk '{print $2'})"
        sha256="$(echo -n "${key_bytes}" | openssl sha256 | awk '{print $2'})"
        printf "\n %-7s %s\n" "$(center "${1}:" 7)" "${fingerprint}"
        printf " SHA1:   %s\n" "${sha1}"
        printf " SHA256: %s\n" "${sha256}"
    fi
}

### Actual script begins here
#printf "%74s\n" "74 charaters end here|"
HOSTUPPER=$(hostname -f | tr '[:lower:]' '[:upper:]')
printf "\n%s\n" "$(center "SSH KEYS FOR HOST ${HOSTUPPER}")"
process_key "DSA" "/etc/ssh/ssh_host_dsa_key.pub"
process_key "RSA" "/etc/ssh/ssh_host_rsa_key.pub"
process_key "ECDSA" "/etc/ssh/ssh_host_ecdsa_key.pub"

exit 0

