#!/bin/bash

############################################################
# Handle wireless network
# History:
#   2013/03/11 v1.0.0 Dennis Create
#   2013/03/22 v1.0.3 Dennis 编码并完善功能
#   2013/03/26 v1.0.4 Dennis 解决无线网络没有真正断开的问题
#                            解决-s参数无结果显示问题
#                            DHCP增加超时设置
#   2013/03/27 v1.0.5 Dennis 修改-d参数输出,解决-s扫描漏掉第
#                            一个无线网络
############################################################

############################################################
# Version
############################################################
VERSION=1.0.4

############################################################
# Debug Configs
############################################################
DEBUG=0
_ERR_HDR_FMT="%.23s %s[%s]: "
_ERR_MSG_FMT="${_ERR_HDR_FMT}%s\n"

############################################################
# Global configs
############################################################
IWLIST=${IWLIST:-/sbin/iwlist}
WPA_SUPPLICANT=${WPA_SUPPLICANT:-/usr/sbin/wpa_supplicant}
WPA_CLI=${WPA_CLI:-/usr/sbin/wpa_cli}
WPA_PASSPHRASE=${WPA_PASSPHRASE:-/usr/sbin/wpa_passphrase}
DHCP_CLIENT=${DHCP_CLIENT:-/sbin/dhclient}
DHCP_LEASE=${DHCP_LEASE:-/var/lib/dhcp3/dhclient.leases}
IFCONFIG=${IFCONFIG:-/sbin/ifconfig}
CONFIG_FILE=${CONFIG_FILE:-/etc/wpa_supplicant/wpa_supplicant.conf}
INPUT=$*
PROG=`basename $0`
WIFI_INTERFACE=wlan0

############################################################
# Load deps into array
############################################################
DEPS=($IWLIST $WPA_SUPPLICANT $WPA_CLI $DHCP_CLIENT $IFCONFIG $IFCONFIG )
DEPLEN=${DEPS[@]} 

############################################################
# Debug echo
############################################################
decho() {
	if test $DEBUG -eq 1 ; then
		printf "$_ERR_MSG_FMT" $(date +%F.%T.%N) ${BASH_SOURCE[1]##*/} ${BASH_LINENO[0]} "${@}"
		#echo ">>>>> $* <<<<<"
	fi
}

############################################################
# Display proper usage
############################################################
usage() {
    echo "NAME"
    echo "      $PROG v$VERSION"
    echo "      $PROG a wireless network tool, use for scan and connect network."
    echo " "
    echo "SYNOPSIS"
    echo "      $PROG [-c connect -e encryption {0|1|2} -n essid -p passwd] [-d detect] [-g getip] [-h help] [-p stop] [-s {1|2|3|4} scan] [-v version]"
    echo " "
    echo "COMMAND LINE OPTIONS"
    echo "      -c connect -e encryption {0|1|2} -n essid -p passwd"
    echo "            Connect wireless network by DHCP, output ip adrees if connect sucess."
    echo "            For -e parameter, only 0, 1 and 2 is available. 0 when encryption off, 1 for WEP and 2 for WPA encryption."
    echo "            If use -e 0, parameter -p is not need."
	echo "            If exist bank in essid, it need double quotation marks, look as -n \"my wifi name\" "
    echo " "
    echo "      -d detect"
    echo "            Check depencies and detect wireless network adapter. Default network adapter use wlan0."
    echo " "
    echo "      -g getip"
    echo "            Show wireless essid and ip address."
    echo " "
    echo "      -h help"
    echo "            Show the help message."
    echo " "
    echo "      -p stop"
    echo "            Stop wireless network."
    echo " "
    echo "      -s {1|2|3|4} scan"
    echo "            Scan for wireless networks, and specify the output format."
	echo "            1 format: \"essid\" encryption signal_level"
	echo "            2 format: \"essid\" \"encryption\" \"signal_level\""
	echo "            3 format: essid="
	echo "                      encryption="
	echo "                      signal_level="
    echo "            4 format: essid:encryption:signal_level"
    echo " "
    echo "      -v version"
    echo "            Show the version."
    echo " "
    echo "EXAMPLES"
    echo "      $PROG -d"
    echo "      $PROG -s 3"
    echo "      $PROG -c -e 0 -n wifi-enc-off"
    echo "      $PROG -c -e 2 -n wifi-wpa -p 0123456789"
    echo "      $PROG -c -e 2 -n \"wifi wpa\" -p 0123456789"
	echo "      $PROG -g"
	echo "      $PROG -p"
    exit 0
}

############################################################
# Display version
############################################################
version() {
    echo "version $VERSION"
    exit 0
}

############################################################
# Kill process by name
############################################################
killprocfunc() {
	NAME=$1
	ID=`ps -ef | grep "$NAME" | grep -v "grep" | awk '{print $2}'`
	for id in $ID 
	do
		kill -9 $id
		decho "killed $id"
	done
}

############################################################
# Checks the dependencies
############################################################
checkdeps() {
    decho -n "Checking for root privs ... "
    if [ `whoami` = "root" ] ; then
        decho "Passed"
    else
        decho -e "Failed! you need root privs"
		return 1
    fi

    for x in "${DEPS[@]}" ; do
        decho -n "Checking for "$x" ... "
        which $x >/dev/null 2>&1
        if [  $? != 0  ] ; then
            decho "Failed! "$x" not found"
			return 1
        else
            decho "Passed"
        fi
    done
	return 0
}

############################################################
# check wireless network adapter is enable or not
############################################################
adaptercheck () {
	decho -n "Checking for "$WIFI_INTERFACE" ... "
	$IFCONFIG $WIFI_INTERFACE >/dev/null 2>&1
	if [  $? != 0  ] ; then
		decho "Failed! "$WIFI_INTERFACE" not found"
		return 1
	else
		decho "Passed"
	fi
	return 0
}

############################################################
# scan wireless essid's
# Output information:
#    essid encryption_type signal_level
############################################################
scan_wlan_network() {
	foramt=$2
	if [ "$foramt" = "" ]; then
		echo "Invalid parameters for scanning! "
		echo "Use : $PROG -s [1|2|3|4] to try again! "
		return 1
	fi
	
	echo "ctrl_interface=/var/run/wpa_supplicant" > $CONFIG_FILE
	keep_wpa_supplicant_daemon
	decho "do wpa_cli scan"
	ret=`$WPA_CLI -i$WIFI_INTERFACE scan 2>/dev/null`
	if [ "$ret" = "OK" ]; then
		retfile=/tmp/scan_result.wireless
		$WPA_CLI -i$WIFI_INTERFACE scan_results > $retfile 2>/dev/null
		# note,  because wpa_cli have a specify interface( use -i ) awk start 
		# analy from the first line( use NR>1 )
		case $foramt in
			1 )
				awk '{if(NR>1){a=5;enc="off";level=$3;if(/WPA2/){enc="WPA2";}else if(/WPA/){enc="WPA"}else if(/WEP/){enc="WEP"}else {a=4;}; essid=$a;for(i=a+1;i<=NF;i++) essid=essid" "$i; print "\""essid"\"",enc,level}}' $retfile
				;;
			2 )
				awk '{if(NR>1){a=5;enc="off";level=$3;if(/WPA2/){enc="WPA2";}else if(/WPA/){enc="WPA"}else if(/WEP/){enc="WEP"}else {a=4;}; essid=$a;for(i=a+1;i<=NF;i++) essid=essid" "$i; print "\""essid"\"","\""enc"\"","\""level"\""}}' $retfile
				;;
			3 )
				awk '{if(NR>1){a=5;enc="off";level=$3;if(/WPA2/){enc="WPA2";}else if(/WPA/){enc="WPA"}else if(/WEP/){enc="WEP"}else {a=4;}; essid=$a;for(i=a+1;i<=NF;i++) essid=essid" "$i; print "essid="essid;print "encryption="enc;print "signal_level="level;}}' $retfile
				;;
			4 )
				awk '{if(NR>1){a=5;enc="off";level=$3;if(/WPA2/){enc="WPA2";}else if(/WPA/){enc="WPA"}else if(/WEP/){enc="WEP"}else {a=4;}; essid=$a;for(i=a+1;i<=NF;i++) essid=essid" "$i; print essid":"enc":"level;}}' $retfile
				;;
			* )
				awk '{if(NR>1){a=5;enc="off";level=$3;if(/WPA2/){enc="WPA2";}else if(/WPA/){enc="WPA"}else if(/WEP/){enc="WEP"}else {a=4;}; essid=$a;for(i=a+1;i<=NF;i++) essid=essid" "$i; print "\""essid"\"",enc,level}}' $retfile
				;;
		esac
	else
		return 1
	fi
}

############################################################
# wpa_supplicant
# connect wireless network by config file
############################################################
wificonn() {
	decho "wificonn"

	decho "keep wpa_supplican daemon"
	keep_wpa_supplicant_daemon

	sleep 1
	$WPA_CLI -i$WIFI_INTERFACE disable_network 0
	$WPA_CLI -i$WIFI_INTERFACE remove_network 0

	essid=$1
	passwd="$2"
	decho "gen wireless config file"
	sed -i '2,$d' $CONFIG_FILE
	$WPA_PASSPHRASE $essid $passwd >> $CONFIG_FILE

	decho "enable network 0"
	$WPA_CLI enable_network 0

	decho "reconfigure"
	$WPA_CLI -i$WIFI_INTERFACE reconfigure

	decho "do dhcp"
	dhcp $WIFI_INTERFACE
}

############################################################
# wpa_supplicant
# connect wireless network by wpa_cli
############################################################
add_network () {
	enc_type=
	essid_name=
	passwd=

    while getopts ":ce:n:p:" opt; do
		case $opt in
			c)
				;;
			e)
				enc_type=$OPTARG
				;;
			n)
				essid_name=$OPTARG
				;;
			p)
				passwd=$OPTARG
				;;
			'?')
				echo "Invalid parameters for connection!"
				return 1
				;;
		esac
	done

	network_id=0

	decho "step 1: wpa_cli disable_network $network_id "
	$WPA_CLI disable_network $network_id >/dev/null
	decho "step 2: wpa_cli remove_network $network_id "
	$WPA_CLI remove_network $network_id >/dev/null

	decho "step 3: wpa_cli add_network $network_id "
	$WPA_CLI add_network $network_id >/dev/null


	decho "step 4: wpa_cli set_network $network_id ssid ${essid_name} "
	$WPA_CLI set_network $network_id ssid \"${essid_name}\" >/dev/null
	#$WPA_CLI set_network $network_id ssid '"wifi-test"'

	decho "step 5: "
	case $enc_type in
		0 )
			# Ecryption off
			decho "Ecryption off"
			$WPA_CLI set_network $network_id key_mgmt NONE >/dev/null
			;;
		1 )
			# WEP
			decho "WEP"
			$WPA_CLI set_network $network_id key_mgmt NONE >/dev/null
			$WPA_CLI set_network $network_id wep_key0 \"${passwd}\" >/dev/null
			#$WPA_CLI set_network $network_id wep_tx_keyidx 0
			$WPA_CLI set_network $network_id 
			;;
		2 )
			# WPA-PSK/WPA2-PSK
			decho "WPA-PSK/WPA2-PSK"
			decho "wpa_cli set_network $network_id psk \"${passwd}\" "

			$WPA_CLI set_network $network_id psk \"${passwd}\" >/dev/null
			#$WPA_CLI set_network $network_id psk '"0987654321"'
			;;
		* )
			echo "Invalid encryption type $enc_type!"
			echo "Only 0, 1 and 2 is available." 
			return 1
			;;
	esac

	decho "step 6: wpa_cli enable_network $network_id "
	$WPA_CLI enable_network $network_id >/dev/null
}

connet_wireless_network() {
	decho "connet_wireless_network"

	decho "keep wpa_supplican daemon"
	keep_wpa_supplicant_daemon

	add_network $*

	if [ $? -eq 0 ]; then
		decho "do dhcp"
		killprocfunc dhclient
		sleep 1
		decho "dhclient $WIFI_INTERFACE "
		$DHCP_CLIENT -timeout 5 $WIFI_INTERFACE >/dev/null
	fi
}

############################################################
# stop
############################################################
wifistop() {
	#$IFCONFIG $WIFI_INTERFACE down

	network_id=0
	$WPA_CLI disable_network $network_id >/dev/null
	$WPA_CLI remove_network $network_id >/dev/null
	$DHCP_CLIENT -x $WIFI_INTERFACE
}

############################################################
# keep wpa_supplicant daemon
############################################################
keep_wpa_supplicant_daemon () {
	decho "keep_wpa_supplicant_daemon"
	ret=`ps aux | grep "$WPA_SUPPLICANT \-Dwext" | wc -l`
	if [ $ret -eq 0 ]; then
		sed -i '2,$d' $CONFIG_FILE
		$WPA_SUPPLICANT -Dwext -B -i${WIFI_INTERFACE} -c$CONFIG_FILE  2>/dev/null
	fi
}

############################################################
# Show ip address
############################################################
wifiip () {
	# get status
	conn_status=`$WPA_CLI status | grep wpa_state | cut -d"=" -f2`
	if [ "${conn_status}" = "COMPLETED" ]; then
		# print ip address
		conn_essid=`$WPA_CLI status | grep -E "^ssid" | cut -d"=" -f2`
		conn_ip=`$WPA_CLI status | grep ip_address | cut -d"=" -f2`
		echo ${conn_essid}":"${conn_ip}
	fi
}

############################################################
# Handles input
############################################################
input_getopts() {
    while getopts ":cdghpsv" opt; do
		case $opt in
			c)
				if [ $# -lt 5 ]; then
					echo "Invalid parameters for connection! Type $PROG -h for help."
					exit 1
				fi
				connet_wireless_network $*
				wifiip
				;;
			d)
				checkdeps
				if [ $? -eq 1 ]; then
					echo "Failed"
					exit 0
				fi

				adaptercheck
				if [ $? -eq 1 ]; then
					echo "Failed"
					exit 0
				fi

				echo "Passed"
				;;
			g)
				wifiip
				;;
			h)
				usage
				;;
			p)
				wifistop
				;;
			s)
				scan_wlan_network $*
				;;
			v)
				version
				;;
			'?')
				echo "$0: invalid option -$OPTARG" >&2
				usage
				exit 1
				;;
		esac
	done
}

input() {
	if [ $# -lt 1 ]; then
		usage
		exit 1
	fi

	input_getopts $*
}

############################################################
# Main
############################################################
input $*
