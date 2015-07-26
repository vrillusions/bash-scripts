#!/bin/bash
# src: https://raw.github.com/vrillusions/bash-scripts/master/bench/bench.sh
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
#
# TODO: make in python since bash is so clunky to do advanced stuff in

_version='1.1'

# make sure we have everything we need
# TODO: I'm sure there's a better way to do this
CURL=$(which curl) || eval "echo 'Please install curl'; exit 1"
CURL=$(which openssl) || eval "echo 'Please install openssl'; exit 1"

# Gather info
CPU_NAME=$(cat /proc/cpuinfo | grep "model name" | uniq | sed -e "s/^model name\s*: //")
CPU_CORES=$(cat /proc/cpuinfo | grep "processor" | wc -l)
CPU_FREQ=$(cat /proc/cpuinfo | grep "cpu MHz" | sort| uniq | head -1 | sed -e "s/^cpu MHz\s*: \(.*\)/\1 MHz/")
RAM=$(free -m | grep "Mem" | awk '{print $2 " MB"}')
SWAP=$(free -m | grep "Swap" | awk '{print $2 " MB"}')
UPTIME=$(uptime | sed -e "s/.*up \(.*\), .* users.*/\1/")

echo "bench.sh v${_version}"
date
echo
echo "CPU model:            $CPU_NAME"
echo "Number of cores:      $CPU_CORES"
echo "CPU frequency:        $CPU_FREQ"
echo "Total amount of ram:  $RAM"
echo "Total amount of swap: $SWAP"
echo "System uptime:        $UPTIME"
echo

echo -n "Beginning I/O test:   "
echo$( ( dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' )
echo

echo "Beginning ping tests:"
echo "google.com, US"
ping -q -c5 google.com | tail -3
echo
echo "linode.com, US"
ping -q -c5 linode.com | tail -3
echo
echo "Rakuten, Japan"
ping -q -c5 rakuten.co.jp | tail -3
echo
echo "BBC, UK"
ping -q -c5 bbc.co.uk | tail -3
echo
echo "Whirlpool Broadband News, Australia"
ping -q -c5 whirlpool.net.au | tail -3
echo

# now for downloads
# first off load up our array of sites, format is:
# FriendlyName|URL
TEST_FILES[0]="CacheFly|http://cachefly.cachefly.net/100mb.test"
TEST_FILES[1]="Linode, Atlanta GA, US|http://atlanta1.linode.com/100MB-atlanta.bin"
TEST_FILES[2]="Linode, Dallas, TX, US|http://dallas1.linode.com/100MB-dallas.bin"
TEST_FILES[3]="Linode, Tokyo, JP|http://tokyo1.linode.com/100MB-tokyo.bin"
TEST_FILES[4]="Linode, London, UK|http://london1.linode.com/100MB-london.bin"
TEST_FILES[5]="Leaseweb, Haarlem, NL|http://mirror.leaseweb.com/speedtest/100mb.bin"
TEST_FILES[6]="Softlayer, Singapore|http://speedtest.sng01.softlayer.com/downloads/test100.zip"
TEST_FILES[7]="Softlayer, Seattle, WA, US|http://speedtest.sea01.softlayer.com/downloads/test100.zip"
TEST_FILES[8]="Softlayer, San Jose, CA|http://speedtest.sjc01.softlayer.com/downloads/test100.zip"
TEST_FILES[9]="Softlayer, Washington, DC|http://speedtest.wdc01.softlayer.com/downloads/test100.zip"
TEST_FILES[10]="OVH, France|http://proof.ovh.net/files/100Mio.dat"

echo "Beginning download speed tests:"
for TEST_FILE in "${TEST_FILES[@]}"; do
    NAME=$(echo $TEST_FILE | cut -d'|' -f1)
    URL=$(echo $TEST_FILE | cut -d'|' -f2)
    echo -n "$NAME:  "
    echo "$(($(curl -s -o /dev/null --write-out %{speed_download} $URL | cut -d'.' -f1) / 1000)) KB/sec"
done
echo

if [[ "${BENCH_OPENSSL_EC:-true}" != 'true' ]]; then
    ciphers='sha256 aes-128-cbc aes-256-cbc ecdsap256 ecdhp256'
else
    ciphers='sha256 aes-128-cbc aes-256-cbc'
fi
echo "Beginning CPU tests (won't see output for 1 or 2 minutes):"
openssl speed ${ciphers} 2>/dev/null | tail -n +6

exit 0
