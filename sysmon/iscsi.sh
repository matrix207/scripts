#!/bin/bash

############################################################
# Global configs
############################################################
PROG=`basename $0`
LOG_PATH=/root/log
INTERVAL_TIME=5

############################################################
# Log message
############################################################
log() {
	if [ ! -z "$DEBUG" ]; then
		# print date time, line number and message
		HDR_FMT="%.23s [%s]: "
		MSG_FMT="${HDR_FMT}%s\n"
		printf "$MSG_FMT" $(date +%F.%T.%N) ${BASH_LINENO[0]} "${@}"
	fi
}

############################################################
# check
############################################################
check() {
	echo "do checking"
}

############################################################
# log system info, include cpu,mem and disk
############################################################
log_prepare() {
	test -d $LOG_PATH || mkdir $LOG_PATH
}

############################################################
# log system info, include cpu,mem and disk
############################################################
log_sys() {
	log "log system info"
	# CPU
	local cpu_info=$(top -b -n 1 | grep Cpu)
	echo "[ $(date +%F.%T) ]: " $cpu_info>>$LOG_PATH/cpu.log
	if [ ! -f $LOG_PATH/vmstat.log ];then
		vmstat >$LOG_PATH/vmstat.log
	fi
	vmstat |awk 'NR==3{print $0}'>>$LOG_PATH/vmstat.log
}

############################################################
# log io info
############################################################
log_io() {
	log "log io info"
	date +%F.%T.%N >>$LOG_PATH/iostat.log
	# iostat 的第一次记录是从系统启动到当前时间的平均值，不  
    # 能反映实时的io情况，所以要多次记录，从第二笔记录开始
    # 参数意义: 
    #    -x 统计详细信息
    #    2  每隔2秒做一次统计
    #    3  总共做3次统计
	iostat -x 2 3 >>$LOG_PATH/iostat.log
}

############################################################
# log network info
############################################################
log_net() {
	log "log network info"
: <<COMMENTBLOCK
	if [ ! -f $LOG_PATH/ustat.log ];then
		ustat 1 1 >$LOG_PATH/ustat.log
	fi
	ustat 1 1 |awk 'END{print $0}' >>$LOG_PATH/ustat.log
COMMENTBLOCK
	echo "route information" >>$LOG_PATH/network.log
	ip addr >>$LOG_PATH/network.log
	netstat -rn >>$LOG_PATH/network.log
	netstat -apn >>$LOG_PATH/network.log
	ifconfig -a >>$LOG_PATH/network.log
}

############################################################
# log kernel message
############################################################
log_kmsg() {
	log "log kernel message"
	dmesg >$LOG_PATH/dmesg.log

	# 保证日志文件是比较全的，防止重启后被新的覆盖了
	local tmpfile=$LOG_PATH/dmesg.log
	local bakfile=$LOG_PATH/dmesg.log.bak
	if [ ! -f $bakfile ]; then
		cp $tmpfile $bakfile
	else
		lc1=$(cat $tmpfile |wc -l)
		lc2=$(cat $bakfile |wc -l)
		if [ $lc1 -gt $lc2 ]; then
			cp $tmpfile $bakfile
		fi
	fi
}

############################################################
# log resource of specify process
############################################################
log_res() {
	log "log resource info"
	local pro_name=StoreServer

	pgrep $pro_name 1>/dev/null 2>&1
	if [ $? == 1 ]; then 
		return 1
	fi

	local ps_num=$(pgrep $pro_name |awk 'END{print $0}')

	# CPU, 如果有多行，只打印第一行
	local pro_cpu_info=$(top -b -n 1 | grep -i $pro_name |awk 'NR==1{print $0}')
	echo "[ $(date +%F.%T) cpu]: " $pro_cpu_info>>$LOG_PATH/${pro_name}.log
	# PS, 如果有多行，只打印最后一行
	local pro_ps_info=$(ps aux |grep -i $pro_name |grep -v grep |awk 'END{print $0}')
	echo "[ $(date +%F.%T) ps ]: " $pro_ps_info>>$LOG_PATH/${pro_name}.log
	# FD
	echo "+++++++++++++++++++++++++++++++++">>$LOG_PATH/${pro_name}.fd.log
	echo "[ $(date +%F.%T) ps ]: ">>$LOG_PATH/${pro_name}.fd.log
	ls -l /proc/$ps_num/fd >>$LOG_PATH/${pro_name}.fd.log
}

############################################################
# log iscsi info
############################################################
log_iscsi() {
	if [ -d /proc/net/iet ]
	then
		mkdir -p $LOG_PATH/iscsi
		local iscsi_path=$LOG_PATH/iscsi
		cat /proc/net/iet/session  >$iscsi_path/session
		cat /proc/net/iet/volume >$iscsi_path/volume
		netstat -anp | grep 3260 >$iscsi_path/iscsi_conninfo
		local conn_ip=$(grep cid /proc/net/iet/session |awk -F' |:' '{print $4}')
		if [ ! -z "$conn_ip" ]; then
			ping -c 5 $conn_ip >$iscsi_path/ping
		fi
	fi	
	cp -f /etc/{ietd.conf,initiators.allow,exports,krb5.conf,iscsi.user,initiators.deny,ietd.portal} $iscsi_path >&/dev/null
	tcpdump -U port 3260 -w $LOG_PATH/tcpdump.pcap &
}

############################################################
# log all
############################################################
log_all() {
	log_io
	log_kmsg
	log_net
	#log_res
	log_sys
}

do_log_loop() {
	while :
	do
		log_all
		sleep ${INTERVAL_TIME}
	done
}


############################################################
# Main
############################################################
log_prepare
log_iscsi
do_log_loop
