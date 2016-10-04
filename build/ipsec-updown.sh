#!/bin/bash

LOG_FILE=/var/log/ipsec-tunnel.log

function htcnet_log {
	LOG="`date` : $1"
	echo "$LOG"
	echo "$LOG" >> $LOG_FILE
}

htcnet_log "$PLUTO_VERB"

ETH_IF=$PLUTO_INTERFACE
LEFT=$PLUTO_ME
RIGHT=$PLUTO_PEER
LEFT_IP=`echo "$PLUTO_MY_ID" | cut -d '=' -f 2`
RIGHT_IP=`echo "$PLUTO_PEER_ID" | cut -d '=' -f 2`
MY_ID=`echo "$LEFT_IP" | cut -d '.' -f 4`
ID=`echo "$RIGHT_IP" | cut -d '.' -f 4`
TUN_IF="ipsec$ID"

if [ $PLUTO_VERB == "up-host" ] || [ $PLUTO_VERB == "down-host" ]; then
	IP="ip -4"
	MODE=ipip
else
	IP="ip -6"
	MODE=ipip6
fi

eval $IP tunnel | grep "$TUN_IF:"
if [ [ $PLUTO_VERB == down* ] ^ $? ]; then 
	exit 0
fi

case $PLUTO_VERB in
	down-host|down-host-v6)
		htcnet_log "del $TUN_IF $RIGHT"
		vtysh -c "configure terminal" -c "interface $TUN_IF" -c "shutdown"
		ip addr del $LEFT_IP peer $RIGHT_IP dev $TUN_IF
		eval $IP tunnel del $TUN_IF
		;;

	up-host|up-host-v6)
		htcnet_log "add $TUN_IF $RIGHT"
		eval $IP tunnel add $TUN_IF mode $MODE local $LEFT remote $RIGHT dev $ETH_IF ttl 255
		sysctl -w "net.ipv6.conf.$TUN_IF.disable_ipv6=1"

		ip addr add $LEFT_IP peer $RIGHT_IP dev $TUN_IF
		ip link set $TUN_IF up mtu 1392
		ip route add $RIGHT_IP dev $TUN_IF table default
		ip route flush cache

		vtysh -c "configure terminal" -c "router ospf" \
			-c "ospf router-id $LEFT_IP" -c "network $LEFT_IP/32 area 0" -c "network $RIGHT_IP/32 area 0"
		vtysh -c "configure terminal" -c "interface $TUN_IF" \
			-c "ip ospf network point-to-point" -c "no shutdown"
		vtysh -c "write"

		ping $RIGHT_IP -c 1
		;;
esac

