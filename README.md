
##My shell scripts
================================================================================

###skill for bash 
================================================================================

1.show line number

	export PS4='+${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]}: '


2.debug apart of code

	set -x
	THE CODE BE DEBUGED
	set +x

3.add debug flag

code like this:

	DEBUG=0
	_ERR_HDR_FMT="%.23s %s[%s]: "
	_ERR_MSG_FMT="${_ERR_HDR_FMT}%s\n"

	_log() {
		if test $DEBUG -eq 1 ; then
			printf "$_ERR_MSG_FMT" $(date +%F.%T.%N) ${BASH_SOURCE[1]##*/} ${BASH_LINENO[0]} "${@}"
		fi
	}

and run as this:

	DEBUG=1 ./test.sh


4. add text to the head of file, using `cat - $file`, link stdout to the head of $file  

	file=data.txt
	echo "test text to head of file" | cat - $file >$file.new

5. merge two lines to one

	sed 'N;s/\n/ /' 1.txt

6. print the next line of match line

	sed '/33/{n;p}' 1.txt

7. merge all line to one

	sed ':a;N;s/\n/ /;ba;' 1.txt

8. print the last line

	tail -n 1 1.txt
	tail -1 1.txt
	sed -n '$p' 1.txt
	awk 'END{print}' 1.txt

9. output multiple lines

	cat <<TT-Test-111
	This is line 1 of message
	This is line 2 of message
	This is line 3 of message
	TT-Test-111

10. comment block code, it is useful for debuging

	: <<COMMENTBLOCK
	# Test code here
	echo "abc"
	echo "123"
	COMMENTBLOCK

	: <<DEBUGXXX
	for file in *
	do
	  cat "$file"
	done
	DEBUGXXX

11. array

	DISKS=($(ls /dev/sd*))
	LENGTH=${DISKS[@]}
    for x in "${DISKS[@]}" ; do
		echo $x
	done

for more info:

* <http://coolshell.cn/articles/1379.html>
* <http://www.ibm.com/developerworks/cn/linux/l-cn-shell-debug/>

###Advance skill
================================================================================

1.cursor moving

	"\033[<L>;<C>H"  move curse to specify position, <L> is line number, <C> is crow number
	"\033[<N>A"      move the current curse up N lines.(remember to replace <N> to digits)
	"\033[<N>B"      move down
	"\033[<N>C"      move right
	"\033[<N>D"      move left

2.change color

	syntax:
		echo -e '\E[COLOR1;COLOR2mSome text goes here.'

	FGRED=`printf "\033[31m"`
	FGCYAN=`printf "\033[36m"`
	BGRED=`printf "\033[41m"`
	FGBLUE=`printf "\033[35m"`
	BGGREEN=`printf "\033[42m"`
	 
	NORMAL=`printf "\033[m"`
	 
	echo "${FGBLUE} Text in blue ${NORMAL}"
	echo "Text normal"
	echo "${BGRED} Background in red"
	echo "${BGGREEN} Background in Green and back to Normal ${NORMAL}"

	code color/编码 颜色/动作
	0  重新设置属性到缺省设置
	1  设置粗体
	2  设置一半亮度（模拟彩色显示器的颜色）
	4  设置下划线（模拟彩色显示器的颜色）
	5  设置闪烁
	7  设置反向图象
	22 设置一般密度
	24 关闭下划线
	25 关闭闪烁
	27 关闭反向图象
	30 设置黑色前景
	31 设置红色前景
	32 设置绿色前景
	33 设置棕色前景
	34 设置蓝色前景
	35 设置紫色前景
	36 设置青色前景
	37 设置白色前景
	38 在缺省的前景颜色上设置下划线
	39 在缺省的前景颜色上关闭下划线
	40 设置黑色背景
	41 设置红色背景
	42 设置绿色背景
	43 设置棕色背景
	44 设置蓝色背景
	45 设置紫色背景
	46 设置青色背景
	47 设置白色背景
	49 设置缺省黑色背景

	echo -e "\033[1mThis is bold text.\033[0m"
	echo -e "\033[4mThis is underlined text.\033[0m"
	echo -e '\E[34;47mThis prints in blue.'; tput sgr0
	echo -e '\E[33;44m'"yellow text on blue background"; tput sgr0
	echo -e '\E[1;33;44m'"BOLD yellow text on blue background"; tput sgr0

reference:
* [Linux的shell中echo改变输出显示样式](http://www.cnblogs.com/276815076/archive/2011/05/11/2043367.html)
* [ABS-Guide 36.5. "Colorizing" Scripts]()

###pdf
================================================================================
reference:  
* [Remove passwords from PDF files](http://blog.marcus-brinkmann.de/2011/06/08/remove-password-from-pdf/)

###wifi module
================================================================================
reference:  
* [getwifi (a bash script)] (http://sourceforge.net/projects/getwifi/)
* [Linux 下的wpa_supplicant工具关联无线网络命令行] (www.ixpub.net/blog-16986440-414984.html)
* [wpa_supplicant无线网络配置] (http://blog.csdn.net/simeone18/article/details/8580592)
* [wpa_cli调试工具的使用] (http://blog.csdn.net/ylyuanlu/article/details/7634925)
* [用wpa_cli 连接无线网络] (http://blog.csdn.net/yuzaipiaofei/article/details/6620084)
* [无线 编程] (http://blog.csdn.net/wl_haanel/article/details/5312295)

###raid module
================================================================================
Reference:  
* [鳥哥的 Linux 私房菜 軟體磁碟陣列 (Software RAID)](http://linux.vbird.org/linux_basic/0420quota.php#raid)
* [Linux建立Raid](http://page.renren.com/600235506/note/486081565?op=pre&curTime=1282876355000)
* [mdadm详解](http://blog.csdn.net/sense5/article/details/3888249)
* [How to determine RAID controller type and a model](http://supportex.net/2010/11/determine-raid-controller-type-model/)
* [Linux: How to delete a partition with fdisk command](www.cyberciti.biz/faq/linux-how-to-delete-a-partition-with-fdisk-command/)
* [Linux DD命令删除掉分区shell](www.51chongdian.net/bbs/thread-35739-1-1.html)
* [使用libparted库写个程序来打印我们的设备信息](blog.csdn.net/fjb2080/article/details/5032274)
* [linux fdisk 分区、格式化、挂载！](yuetao.org/linux-fdisk/)
* [关于删除软raid设备md0](www.ixpub.net/thread-763965-1-1.html)
* [Linux软Raid配置](http://david0341.iteye.com/blog/382399)
* [mdadm使用详解及RAID 5简单分析](http://blog.csdn.net/sense5/article/details/1828868)

###genmk
================================================================================
a script for generating configure file, which can use to generate Makefile

###ds2img
================================================================================
A python script transfer c header file which contains lots of data structures 
to a dot script, and then convert to a image file

###pmt
================================================================================
Project MoniTor, for windows and linux platform

###sysmon
================================================================================
System infor monitor (cpu,mem,ps,FD,network)

###netspeed
================================================================================
Get network RT speed and NIC speed
