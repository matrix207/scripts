#!/bin/bash

############################################################
# monitor system info
#
# How to auto run script
#       1.run by crontab
#         1.1.crontab -e 
#             */10 * * * *  /root/dmon.sh
#         1.2.service crond restart
#       2.run /etc/rc.local
#         echo "/root/dmon.sh &" >>/etc/rc.local
#
# History:
#       2014-10-15  v0.2  Dennis  Add log /proc/pid/fd 
#       2014-10-14  v0.1  Dennis  Create
#
# TODO:
############################################################

############################################################
# Global configs
############################################################
PROG=`basename $0`
VERSION=0.2
BUILD_TIME="compiled 2014-10-14 15:03"
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
# log network info
############################################################
log_net() {
	log "log network info"
	if [ ! -f $LOG_PATH/ustat.log ];then
		ustat 1 1 >$LOG_PATH/ustat.log
	fi
	ustat 1 1 |awk 'END{print $0}' >>$LOG_PATH/ustat.log
}

############################################################
# log io info
############################################################
log_io() {
	log "log io info"
	date +%F.%T.%N >>$LOG_PATH/iostat.log
	iostat >>$LOG_PATH/iostat.log
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
	#log_interval_time=$1
	while :
	do
		log_all
		sleep 5
	done
}


############################################################
# Main
############################################################
log_prepare
do_log_loop
