#!/bin/bash

echo '-------------------------'
echo '|  Loading htcNet ...   |'
echo '-------------------------'

sysctl -w net.ipv4.conf.all.rp_filters=0
sysctl -w net.ipv4.conf.default.rp_filter=0

DEF_ROUTE=`ip route get 8.8.8.8 | grep 8.8.8.8 | cut -d ' ' -f 2-`

service vnstat start
service quagga start

ipsec start

function stop_htcnet {
    ipsec stop
    service vnstat stop
    service quagga stop
}

trap 'echo "Exiting..." ; exit 0' SIGTERM

while true ; do
    sleep 60
    /sbin/keep-vpn.sh &
done