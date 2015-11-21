#!/bin/bash
# src: https://raw.githubusercontent.com/vrillusions/bash-scripts/master/bench/bench.sh
# home: https://github.com/vrillusions/bash-scripts (in bench subfolder)
#
# runs various benchmarks on a server. Commonly done to test VPS machines
# improvements include better formatting and make it easier to add more
# download sites.  Also CPU frequency should be taken off the fastest core
# since it's possible they're in speedstep to save energy
#
# LICENSE: Public Domain / do whatever you want just don't sue me if something
# blows up.
#
# Environment variables:
#
# BENCH_OPENSSL_EC - run speed tests against a couple elliptic curve algorithms.
#   Anything other than 'true' will skip them (may be needed on older systems).
#   Default is 'true'

_version='2.0'


# -- setup some functions --
# usage: log "What you want to log"
log () {
    # Usually I include a timestamp but not needed here
    # Still have this function since printf is theoretically better than echo
    #printf "%b\n" "$(date +"%Y-%m-%dT%H:%M:%S%z") $*"
    printf "%b\n" "$*"
}

# usage: logerror "What to log to stderr"
logerror () {
    log "$*" >&2
}

# usage: logfatal "What to log to stderr and exit"
logfatal () {
    logerror "$*"
    exit 1
}

# usage: command_exists "command_name" || echo "the command wasn't found"
command_exists () {
    local command_name
    command_name="${1-}"

    if [[ "${command_name}" == "" ]]; then
        echo "ERROR: command_exists(): no command specified" >&2
        return 1
    fi

    if command -v "${command_name}" 1>/dev/null; then
        return 0
    else
        return 1
    fi
}

# usage: speedtest "Friendly name" "url"
# Keep the friendly name under 30 characters so formatting stays pretty
speedtest () {
    if [[ $# -ne 2 ]]; then
        echo "ERROR: speedtest(): incorrect number of arguments specified"
        return 1
    fi
    local friendly_name
    local url
    local speedtest_result
    friendly_name="$1"
    url="$2"

    # The log function adds a linebreak at the end we don't want so call printf
    # directly
    printf "%30b: " "${friendly_name}"
    speedtest_result="$(($(curl -s -o /dev/null --write-out %\{speed_download\} \
        "${url}" | cut -d'.' -f1) / 1000)) KB/sec"
    printf "%-15b\n" "${speedtest_result}"
}

# usage: pingtest "Friendly name" "address"
pingtest () {
    if [[ $# -ne 2 ]]; then
        echo "ERROR: pingtest(): incorrect number of arguments specified"
        return 1
    fi
    local friendly_name
    local server
    friendly_name="$1"
    server="$2"

    log "${friendly_name}"
    ping -q -c5 "${server}" | tail -3
    log
}



# -- make sure we have needed commands --
command_exists "curl" || logfatal "Please install curl"
command_exists "openssl" || logfatal "Please install OpenSSL"


# -- gather info --
cpu_name="$(grep "model name" /proc/cpuinfo \
    | uniq \
    | sed -e "s/^model name\s*: //")"
cpu_cores="$(grep -c "processor" /proc/cpuinfo)"
cpu_freq="$(grep "cpu MHz" /proc/cpuinfo \
    | sort \
    | uniq \
    | head -1 \
    | sed -e "s/^cpu MHz\s*: \(.*\)/\1 MHz/")"
ram="$(free -m \
    | grep "Mem" \
    | awk '{print $2 " MB"}')"
swap="$(free -m \
    | grep "Swap" \
    | awk '{print $2 " MB"}')"
uptime="$(uptime \
    | sed -e 's/^\W//')"


log "bench.sh v${_version}"
date
log
log "CPU model:            ${cpu_name}"
log "Number of cores:      ${cpu_cores}"
log "CPU frequency:        ${cpu_freq}"
log "Total amount of ram:  ${ram}"
log "Total amount of swap: ${swap}"
log "System uptime:        ${uptime}"
log


printf "%b" "Beginning I/O test:  "
log "$( ( dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync \
    && rm -f test_$$ ) 2>&1 \
    | awk -F, '{io=$NF} END { print io}' )"
log


log "Beginning ping tests:"
pingtest "google.com, USA" "google.com"
pingtest "linode.com, USA" "linode.com"
pingtest "Rakuten, JPN" "rakuten.co.jp"
pingtest "BBC, GBR" "bbc.co.uk"
pingtest "Whirlpool Broadband News, AUS" "whirlpool.net.au"


log "Beginning download speed tests:"
speedtest "CacheFly" "http://cachefly.cachefly.net/100mb.test"
speedtest "Linode, Newark, NJ, USA" "http://speedtest.newark.linode.com/100MB-newark.bin"
speedtest "Linode, Atlanta, GA, USA" "http://speedtest.atlanta.linode.com/100MB-atlanta.bin"
speedtest "Linode, Dallas, TX, USA" "http://speedtest.dallas.linode.com/100MB-dallas.bin"
speedtest "Linode, Tokyo, JPN" "http://speedtest.tokyo.linode.com/100MB-tokyo.bin"
speedtest "Linode, London, GBR" "http://speedtest.london.linode.com/100MB-london.bin"
speedtest "Leaseweb, Haarlem, NLD" "http://mirror.leaseweb.com/speedtest/100mb.bin"
speedtest "Softlayer, SGP" "http://speedtest.sng01.softlayer.com/downloads/test100.zip"
speedtest "Softlayer, Seattle, WA, USA" "http://speedtest.sea01.softlayer.com/downloads/test100.zip"
speedtest "Softlayer, San Jose, CA, USA" "http://speedtest.sjc01.softlayer.com/downloads/test100.zip"
speedtest "Softlayer, Washington, DC, USA" "http://speedtest.wdc01.softlayer.com/downloads/test100.zip"
speedtest "OVH, FRA" "http://proof.ovh.net/files/100Mio.dat"
speedtest "OVH, Quebec, CAN" "http://proof.ovh.ca/files/100Mio.dat"
log


if [[ "${BENCH_OPENSSL_EC:-true}" == 'true' ]]; then
    ciphers='sha256 aes-128-cbc aes-256-cbc ecdsap256 ecdhp256'
else
    ciphers='sha256 aes-128-cbc aes-256-cbc'
fi
log "Beginning CPU tests (won't see output for 1 or 2 minutes):"
# ${ciphers} can't be enclosed in quotes so disable shellcheck warning about it
#shellcheck disable=SC2086
openssl speed ${ciphers} 2>/dev/null | tail -n +6
log

log "Finished benchmark. Have a nice day!"

exit 0
