#! /bin/bash
# Create by Dennis
# 2014-08-08

FGRED=`printf "\033[31m"`
FGCYAN=`printf "\033[36m"`
BGRED=`printf "\033[41m"`
FGBLUE=`printf "\033[35m"`
BGGREEN=`printf "\033[42m"`

NORMAL=`printf "\033[m"`

get_net_speed() {
	if [ "x$1" = "x" ] ; then
		inf=eth0
	else
		inf=$1
	fi

	 in_old=`grep $inf /proc/net/dev |awk '{ print $2 }'`
	out_old=`grep $inf /proc/net/dev |awk '{ print $10 }'`

	while true
	do
		sleep 1
		 in=`grep $inf /proc/net/dev |awk '{ print $2 }'`
		out=`grep $inf /proc/net/dev |awk '{ print $10 }'`
		dif_in=$((in-in_old))
		dif_out=$((out-out_old))
		echo -ne "Interface:$1 IN: ${FGRED}${dif_in}${NORMAL}bytes OUT: ${FGBLUE}${dif_out}${NORMAL} bytes\r"
		#echo "IN: ${dif_in} bytes OUT: ${dif_out} bytes"
		 dif_in1=$((dif_in  * 8 / 1024 / 1024 ))
		dif_out1=$((dif_out * 8 / 1024 / 1024 ))
		#echo -ne "IN: ${dif_in1} mbps OUT: ${dif_out1} mbps\r"
		in_old=${in}
		out_old=${out}
	done
}

get_net_speed $*
