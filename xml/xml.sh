#!/bin/sh
################################################################################
# 解析xml配置文件
# 历史记录:
#   2013-03-05    v1.0    Dennis  Create
################################################################################

xml_file=/etc/mytest/tmp.xml

# function: set item value
setitemvalue ()
{
	if [ $# -lt 2 ]; then
		echo Usage: setitemvalue item value
		return 1
	fi

	# sed 中使用变量，要用单引号围起来
	case $1 in
		"name" | "ip" | "port")
			#vi -e -s -c ":%s#$1=\"\S*\"#$1=\"$2\"#g" -c ":wq" $xml_file
			# 修改所有匹配行
			#sed -i 's#'$1'=\"\S*\"#'$1'="'$2'"#g' $xml_file
			# 只修改第一个匹配行
			sed -i '1,/'$1'/{s#'$1'=\"\S*\"#'$1'="'$2'"#g}' $xml_file 
			;;
		*)
			#vi -e -s -c ":%s#<$1>.*</$1>#<$1>$2</$1>#g" -c ":wq" $xml_file
			sed -i 's#<'$1\>'.*<#<'$1'\>'$2'<#g' $xml_file 
			;;
	esac
	return 0
}

# function: dispaly item value
show()
{
	# parse special item
	# 方式1, 可能出现重复行, 命令过长
	  #name=`grep "Remote name" $xml_file | head -n 1 | awk '{print $2}' | cut -d"=" -f2 | cut -d'"' -f2`
	# 方式2, 使用 -m 参数解决重复行问题，但整个命令比较长
	  #name=`grep -m 1 "Remote name" $xml_file | awk '{print $2}' | cut -d"=" -f2 | cut -d'"' -f2`
	# 方式3, 可能出现重复行
	  #name=`sed -n '/Remote name/p' $xml_file | cut -d'"' -f2`
	# 方式4, 解决重复行,并且简化命令
	name=`grep -m 1 "Remote name" $xml_file | cut -d'"' -f2`
	  ip=`grep -m 1 "Remote name" $xml_file | cut -d'"' -f4`
	port=`grep -m 1 "Remote name" $xml_file | cut -d'"' -f6`
	echo name:$name
	echo ip:$ip
	echo port:$port

	# parse general item
	awk -F'<|>' '{if(NF>3){print $2 ":" $3}}' $xml_file
}

# function: help
help ()
{
	echo "Usage:  xml.sh [--show] [--set] "
	echo "  --show display all item info "
	echo "  --set  set values of items "
	echo "    e.g: xml.sh --set ip=192.168.1.38 port=1394"
}

# main
if [ $# -lt 1 ]; then
	help
	exit 1
else
	case $1 in
		"--show")
			show
			;;
		"--set")
			# 删掉第一个参数
			shift
			# 循环所有参数
			for i in $* ; do
				item=`echo $i | cut -d"=" -f1`
				value=`echo $i | cut -d"=" -f2`
				if [ $item ] && [ $value ]; then
					setitemvalue $item $value
				else
					echo parameters "$i" error!
					exit 1
				fi
			done
			;;
		*)
			help
			exit 1
			;;
	esac
fi

exit 0
