#!/bin/bash

configs=`cat /etc/ipsec.conf | egrep "conn [0-9]+" | cut -d' ' -f 2`

date
IFS=$'\n';
for config in $configs ; do
	ip a | grep "ipsec$config" 2>&1 > /dev/null
	if [ $? -ne 0 ]; then
		echo "ipsec$config down"
		timeout 40 ipsec up "$config" 2>&1 > /dev/null &
	else
		echo "ipsec$config up"
	fi
done

