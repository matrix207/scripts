#!/bin/sh
################################################################################
# From: http://hi.baidu.com/wylhistory/item/4e9d213bfdb0898bf5e4adad 
# 实现wifi的自动连接的，根据不同的加密方式提供不同的脚本，
# 并最后调用wpa_supplicant来实现自动连接
################################################################################

echo "this is wifi_connect para number is $#"
echo "the first para is $1"

if [ $1 == "off" ];then
	killall -9 wpa_supplicant 2>/dev/null
	exit;
fi

if [ $# -lt 3 ];then
	echo "Usage:$0 interface essid enc"
	exit;
fi

interface=$1
ssid=$2;
enc=$3
passwd=$4

echo "the ssid is $ssid,the passwd is $passwd,the enc is $enc"

wpa_file=/etc/wpa.conf

if [ ${enc} == "OPEN" ];then
	echo -e "network={                                                     
					ssid=\"$ssid\"                                         
					key_mgmt=NONE
			}" >$wpa_file
	sync;
elif [ ${enc} == "WEP" ];then
	echo -e "network={
					ssid=\"$ssid\"
					key_mgmt=NONE
					wep_key0=$passwd
					wep_key1=$passwd
					wep_key2=$passwd
					wep_key3=$passwd
					wep_tx_keyidx=0 1 2 3
			}" >$wpa_file
	sync;
elif [ ${enc} == "WEP_ASCII" ];then
	echo -e "network={
					ssid=\"$ssid\"
					key_mgmt=NONE
					wep_key0=\"$passwd\"
					wep_key1=\"$passwd\"
					wep_key2=\"$passwd\"
					wep_key3=\"$passwd\"
					wep_tx_keyidx=0 1 2 3
			}" >$wpa_file
	sync;
elif [ ${enc} == "WEP_HEX" ];then
	echo -e "network={
					ssid=\"$ssid\"
					key_mgmt=NONE
					wep_key0=$passwd
					wep_key1=$passwd
					wep_key2=$passwd
					wep_key3=$passwd
					wep_tx_keyidx=0 1 2 3
			}" >$wpa_file
	sync;
elif [ ${enc} == "WPA_PSK" ];then
	echo -e "network={
					ssid=\"$ssid\"
					proto=WPA
					key_mgmt=WPA-PSK
					psk=\"$passwd\"
			}" >$wpa_file
	sync;
elif [ ${enc} == "WPA2_PSK" ];then
	echo -e "network={
					ssid=\"$ssid\"
					proto=WPA2
					key_mgmt=WPA-PSK
					psk=\"$passwd\"
			}" >$wpa_file
	sync;
elif [ ${enc} == "WPA_WPA2_PSK" ];then
	echo -e "network={
					ssid=\"$ssid\"
					proto=WPA
					key_mgmt=WPA-PSK
					psk=\"$passwd\"
			}" >$wpa_file
	sync;
elif [ ${enc} == "WPA_EAP" ];then
	echo "this is WPA_EAP case"
fi

ps >/tmp/wifi_connect.log
nums=`cat /tmp/wifi_connect.log|grep -c "wpa_supplicant"`
echo "the nums is $nums"
if [ $nums -lt 1 ];then
	echo "below is to invoke wpa_supplicant"
	#wpa_supplicant -w -Dwext -c $wpa_file -i $interface -B  
	wpa_supplicant -w -Dwext -c $wpa_file -i $interface &
else
	echo "here send a signal to wpa_supplicant"
	killall -SIGHUP wpa_supplicant
fi
