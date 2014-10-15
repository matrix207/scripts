#!/bin/bash
LOG_PATH=/root/log

log_prepare() {
	test -d $LOG_PATH || mkdir $LOG_PATH
}

pro_mem() { 
	mem_usage=`ps -o vsz -p $1|grep -v VSZ` 
	(( mem_usage /= 1000)) 
	echo $mem_usage 
}

pro_fd() {
	des=`ls /proc/$1/fd |wc -l` 
	echo $des 
}

log_res() {
	local pro_name=StoreTest

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
	# mem, 内存信息
	mem=`pro_mem $ps_num` 
    echo "used memory $mem MB">>$LOG_PATH/${pro_name}.log
	# fd, 文件描述符
	fd=`pro_fd $ps_num` 
    echo "used fd $fd ">>$LOG_PATH/${pro_name}.log
	# wchan
	local pro_wchan=$(cat /proc/$ps_num/wchan)
	echo "balcok function call: " $pro_wchan>>$LOG_PATH/${pro_name}.log
	# FD, 只记录最后一次的信息
	#echo "+++++++++++++++++++++++++++++++++">>$LOG_PATH/${pro_name}.fd.log
	#echo "[ $(date +%F.%T) ps ]: ">>$LOG_PATH/${pro_name}.fd.log
	ls -l /proc/$ps_num/fd >$LOG_PATH/${pro_name}.fd.log
}

do_log_loop() {
	while :
	do
		log_res
		sleep 60
	done
}

############################################################
# Main
############################################################
log_prepare
do_log_loop
