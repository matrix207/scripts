#!/bin/bash
INTERVAL="1"
if [ -z "$1" ]; then
	echo
	echo usage: $0 [ network interface ]
	echo
	echo $0 e.g. eth0
	echo
	exit
fi

IF=1

while true
do
	R1=`cat /sys/class/net/$1/statistics/rx_bytes`
	T1=`cat /sys/class/net/$1/statistics/tx_bytes`
	sleep $INTERVAL
	R2=`cat /sys/class/net/$1/statistics/rx_bytes`
	T2=`cat /sys/class/net/$1/statistics/tx_bytes`
	RBPS=`expr $R2 - $R1`
	TBPS=`expr $T2 - $T1`
	RKBPS=`expr $RBPS / 1024`
	TKBPS=`expr $TBPS / 1024`
	echo "TX $1: $TKBPS KB/s RX $1: $RKBPS KB/s"
done
