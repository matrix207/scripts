#!/usr/bin/bash
################################################################################
# 自动获取SVN版更新信息,并发送邮件通知
# 历史记录:
#   2012-12-20    v1.0    Dennis  Create
#   2012-12-21    v1.1    Dennis  增加注释,加入文件存在判断和写日志
#   2012-12-24    v1.2    Dennis  增加log日期注释,加入文件存在判断和写日志
################################################################################

conf_file=/etc/pmt.conf
log_file=/tmp/pmt.log

cur_time=`date "+%F %R:%S"`
echo $cur_time "pmt start" >> $log_file

# 如果配置文件不存在, 退出程序
if [ ! -f $conf_file ]
then
	echo "Not found $conf_file" >> $log_file
	goto _EXIT
fi

# Fields: project#url#revision#mail
# 每行列数目为4,使用#号作为分割符号提取行信息到数组arr 
field_size=4
arr=($(awk -F'#' '{print $1,$2,$3,$4}' $conf_file))

# 以4个元素为一个单位，获取数组大小, 以模仿二维数组
item_size=$[${#arr[@]}/$field_size]

while true 
do
	# 循环二维数组(模仿)
	for ((i=0;i<$item_size;i++))
	do
	{
	index=$[i*$field_size]

	prj=${arr[$[index+0]]}
	url=${arr[$[index+1]]}
	rev_old=${arr[$[index+2]]}
	# 提取最新版本号
	rev_new=$(svn info $url | awk 'NR==8{print $NF}')

	if (( $rev_new > $rev_old ))
	then
		# 更新版本号到数组
		arr[$[index+2]]=$rev_new

		# 提取log信息
		svn log $url -r $rev_new:$rev_old > svn.log

		subject="[svn monitor]"${arr[$[index+0]]}" update"
		to=${arr[$[index+3]]}

		# 发送邮件通知
		mail -s "$subject" $to < svn.log

		# 修改为最新版本号
		# sed中使用变量要加上单引号
		sed -i '/'$prj'/{s/\(.*#.*#\)[0-9]\+/\1'$rev_new'/}' $conf_file

		cur_time=`date "+%F %R:%S"`
		echo $cur_time "${arr[$[index+0]]} update, mail to $to" >> $log_file
	fi
	}
	done
	sleep 5
done

:_EXIT
cur_time=`date "+%F %R:%S"`
echo $cur_time "pmt exit" >> $log_file
exit 0
