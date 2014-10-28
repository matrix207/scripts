#!/bin/bash
############################################################
# Get Network Interface card speed
# History:
#   2014/10/28  v0.1  Dennis Create
############################################################

get_eth_speed() {
	local name=$1

	# whether ethX exist
    ls /sys/class/net/ |grep $name >/dev/null 2>&1
	test $? == 0 || ( echo "-1";return 0 )

	local eth_speed=`ethtool $name 2>/dev/null |awk -F':' '/Speed/{print $2}'`
	if [ "$eth_speed" == " Unknown!" ]; then
		# unlinked
		ethtool $name |grep '10000baseT' >/dev/null 2>&1
		test $? == 0 && echo "10000Mb/s";return 0
		ethtool $name |grep '1000baseT' >/dev/null 2>&1
		test $? == 0 && echo "1000Mb/s";return 0
		ethtool $name |grep '100baseT' >/dev/null 2>&1
		test $? == 0 && echo "100Mb/s";return 0
		ethtool $name |grep '10baseT' >/dev/null 2>&1
		test $? == 0 && echo "10Mb/s";return 0
	else
		# linked
		echo $eth_speed
	fi
}

speed=$(get_eth_speed $1)
echo $speed
