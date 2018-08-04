#!/bin/bash
#
# Reads the system's public keys and prints out hashes which can be used to
# verify you are connecting to the correct server


set -e
set -u


### Logging functions
# Usage: log "What to log"
log () {
    printf "%b\\n" "$(date +"%Y-%m-%dT%H:%M:%S%z") $*"
}


readonly script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly script_name="$(basename "$0")"


### Option Handling
while getopts ":h" opt; do
    case $opt in
    h)
        printf "usage: %s\\n" "${script_name}"
        printf "%s\\n\\n" "prints ssh key fingerprints to screen"

        printf "options:\\n"
        printf "  -%1s  %s\\n" "h" "this help message"

        printf "\\nWhat each type means:\\n"
        printf " %6s - %s\\n" "SSH" "fingerprint as ssh will show it upon first connect"
        printf " %6s - %s\\n" "SHA1" "SHA1 hash of key"
        printf " %6s - %s\\n" "SHA256" "SHA256 hash of key"
        printf " %6s - %s\\n" "DNS" "SSHFP records to place in dns"
        exit 0
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    esac
done
shift $(( OPTIND - 1 ))


tmpfile=$(mktemp --tmpdir "${script_name}.XXXXXXXXXX")
trap 'rm -f "${tmpfile}"' EXIT


# Given a key type will output the dns type value
# Usage: get_dns_type "ECDSA"
get_dns_type () {
    local key_type
    local dns_type
    if [[ -z "$1" ]]; then
        log "(get_dns_type) ERROR: must specify one argument"
        exit 1
    fi
    key_type="$(echo "$1" | tr '[:lower:]' '[:upper:]')"
    case "${key_type}" in
        RSA)
            dns_type=1
            ;;
        DSA)
            dns_type=2
            ;;
        ECDSA)
            dns_type=3
            ;;
        ED25519)
            dns_type=4
            ;;
        *)
            dns_type="UNKNOWN"
            ;;
    esac
    echo "${dns_type}"
}

# Takes one argument which is the filename of host's public key
# Usage: process_key "/etc/ssh/ssh_host_ecdsa_key.pub"
process_key () {
    local filename
    local pubkey
    local keygen_info
    local fingerprint
    local key_type
    local sha1
    local sha256
    local dns_sha1
    local dns_sha256

    if [[ $# -ne 1 ]]; then
        log "(process_key) ERROR: requires exactly one argument"
        exit 1
    fi

    filename="$1"

    if [[ -f "${filename}" ]]; then
        pubkey="$(awk '{print $2}' "${filename}")"
        # alternative method:
        #fingerprint="$(echo -n "${key_bytes}" | openssl md5 | awk '{print $2}' | sed -e 's/../&:/g' -e 's/:$//g')"
        #keygen_info=ssh-keygen -l -f /etc/ssh/ssh_host_rsa_key.pub | tr -d '()' | cut -d' ' -f 5
        keygen_info="$(ssh-keygen -l -f "${filename}")"
        fingerprint="$(echo "${keygen_info}" | cut -d' ' -f2)"
        # shellcheck disable=SC2001
        key_type="$(echo "${keygen_info}" | sed -e 's/^.*(\(.*\))$/\1/')"
        sha1="$(echo "${pubkey}" | openssl base64 -d -A | openssl sha1 | awk '{print $2}')"
        sha256="$(echo "${pubkey}" | openssl base64 -d -A | openssl sha256 | awk '{print $2}')"
        dns_sha1="$(hostname -f). 86400 IN SSHFP $(get_dns_type "${key_type}") 1 ${sha1}"
        dns_sha256="$(hostname -f). 86400 IN SSHFP $(get_dns_type "${key_type}") 2 ${sha256}"
        echo "${dns_sha1}" >>"${tmpfile}"
        echo "${dns_sha256}" >>"${tmpfile}"
        printf "\\n%s\\n" "${key_type}"
        printf " %6s: %s\\n" "SSH" "${fingerprint}"
        printf " %6s: %s\\n" "SHA1" "${sha1}"
        printf " %6s: %s\\n" "SHA256" "${sha256}"
        printf " %6s: %s\\n" "DNS" "${dns_sha1}"
        printf " %6s  %s\\n" ""    "${dns_sha256}"
    fi
}

### Actual script begins here
hostupper="$(hostname -f | tr '[:lower:]' '[:upper:]')"
printf "%s\\n" "SSH KEYS FOR HOST ${hostupper}"
process_key "/etc/ssh/ssh_host_rsa_key.pub"
process_key "/etc/ssh/ssh_host_dsa_key.pub"
process_key "/etc/ssh/ssh_host_ecdsa_key.pub"
process_key "/etc/ssh/ssh_host_ed25519_key.pub"
printf "\\n%s\\n" "ALL THE DNS RECORDS IN ONE BLOCK"
cat "${tmpfile}"

exit 0

