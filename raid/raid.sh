#!/bin/bash

############################################################
# raid manager
# History:
#   2013/03/28 v1.0.0 Dennis Create
############################################################

############################################################
# Version
############################################################
VERSION=1.0.0

############################################################
# Debug Configs
############################################################
DEBUG=0
_ERR_HDR_FMT="%.23s %s[%s]: "
_ERR_MSG_FMT="${_ERR_HDR_FMT}%s\n"

############################################################
# Global configs
############################################################
MDADM=${MDADM:-/sbin/mdadm}
MOUNT=${MOUNT:-/bin/mount}
UMOUNT=${UMOUNT:-/bin/umount}
FUSER=${FUSER:-/sbin/fuser}
INPUT=$*
PROG=`basename $0`
DIR_RAID=/dev/md0
DIR_RAID_SED="\/dev\/md0"
DIR_RAID_MOUNT=/mnt/raid1
CONF_RAID=/etc/mdadm.conf
HOME_HOST=u2baynas
FS_TYPE=ext3
FSTAB=/etc/fstab
############################################################
# Load deps into array
############################################################
DEPS=($MDADM $MOUNT $UMOUNT $FUSER )
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
    echo "      $PROG a raid manager tool, include create, delete and so on."
    echo " "
    echo "SYNOPSIS"
    echo "      $PROG [-c create [all]] [-d delete] [-f mkfs] [-l list raid] [-m mount] [-s status] [-h help] [-v version]"
    echo " "
    echo "COMMAND LINE OPTIONS"
    echo "      -c create [all]"
    echo "            Create raid."
    echo "            Use [all] option to do create, make file system and mount together."
    echo " "
    echo "      -d delete"
    echo "            Delete raid."
    echo " "
    echo "      -f mkfs"
    echo "            Make linux file system."
    echo " "
    echo "      -l list raid"
    echo "            List raid."
    echo " "
    echo "      -m mount"
    echo "            Mount	raid."
    echo " "
    echo "      -s status"
    echo "            View raid status."
    echo " "
    echo "      -h help"
    echo "            Show the help message."
    echo " "
    echo "      -v version"
    echo "            Show the version."
    echo " "
    echo "EXAMPLES"
	echo "      create a raid and format as ext3, then mount"
    echo "            $PROG -c"
	echo "            $PROG -f"
	echo "            $PROG -m"
    echo "        The follow command will do all above things:"
	echo "            $PROG -c all"
    echo " "
	echo "      delete raid"
	echo "            $PROG -d"
    echo " "
	echo "      view raid status"
	echo "            $PROG -s"
    echo " "
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
# Checks the dependencies
############################################################
checkdeps() {
    echo -n "Checking for root privs ... "
    if [ `whoami` = "root" ] ; then
        echo -e "Passed"
    else
        echo -e "Failed! you need root privs"
		return 1
    fi

    for x in "${DEPS[@]}" ; do
        echo -n "Checking for "$x" ... "
        which $x >/dev/null 2>&1
        if [ $? != 0 ] ; then
            echo -e "Failed! "$x" not found"
			return 1
        else
            echo -e "Passed"
        fi
    done
	return 0
}

############################################################
# list harddisk
############################################################
hdd_list() {
	#ls -d /sys/block/sd* | awk '{print $0}' | grep -v -E '.*[[:digit:]]'
	ls /dev/sd* | awk '{print $0}' | grep -v -E '.*[[:digit:]]'
}

############################################################
# clean hdd data
############################################################
hdd_clean() {
	# check hdd exist or not
	dir_hdd=$1

	# 1. exist partition table
	# dd if=/dev/zero of=$dir_hdd bs=512 count=1
	ls /dev/sd* | awk '{print $0}' | grep -E '[1-9]$' >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "Exist partiton table"
	fi

	# 2. exist raid data
	# 3. hardisk don't have same size
}

############################################################
# create raid 1
############################################################
raid_create() {
	# get harddisk
	arr_hdd=($(ls /dev/sd* | awk '{print $0}' | grep -v -E '.*[[:digit:]]'))
	hdd_1=${arr_hdd[0]}
	hdd_2=${arr_hdd[1]}

	# check if null
	if [ ! -n "$hdd_1" -o ! -n "$hdd_2" ]; then
		echo "Please check if there are two harddisk plugged in the device!"
		return 1
	fi

	# create raid 1 by two hdd
	echo yes | $MDADM -C $DIR_RAID -l 1 -n 2 $hdd_1 $hdd_2 --assume-clean --homehost=$HOME_HOST

	echo "DEVICE ${hdd_1} ${hdd_2}" > $CONF_RAID
	$MDADM -Ds >> $CONF_RAID

	return 0
}

############################################################
# make linux file system, use ext3 format
# It will need about 7 minutes to done.
# Use command "time" to calculate elapsed time as the follow:
#    real	7m26.174s
#    user	0m5.690s
#    sys	4m43.550s
############################################################
raid_mk_fs() {
	mkfs -t $FS_TYPE -q $DIR_RAID
}

############################################################
# raid mount
############################################################
raid_mount() {
	if [ ! -d $DIR_RAID_MOUNT ]; then
		mkdir -p $DIR_RAID_MOUNT
	fi
	$MOUNT $DIR_RAID $DIR_RAID_MOUNT

	# auto mount at boot
	grep "${DIR_RAID}" $FSTAB
	if [ $? -eq 1 ]; then
		echo "$DIR_RAID $DIR_RAID_MOUNT     $FS_TYPE   defaults  0 0" >> $FSTAB
	fi
}

############################################################
# raid status
############################################################
raid_status() {
	# [UU] : run ok
	# [_U] : fun fault
	cat /proc/mdstat | grep "md" >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		cat /proc/mdstat | grep -E "\[UU\]" >/dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "OK"
		else
			echo "Fail"
			#get more detail
			#DADM --detail $DIR_RAID
		fi
	else
		echo "Not found raid"
	fi
}

############################################################
# raid stop and clear superblock
############################################################
raid_stop() {
	#-bash-4.0# cat /proc/mdstat 
	#Personalities : [linear] [raid0] [raid1] 
	#md0 : active raid1 sdb[1] sda[0]
	#      976761424 blocks super 1.2 [2/2] [UU]
	#      
	#unused devices: <none>


	#-bash-4.0# cat /proc/mdstat 
	#Personalities : [linear] [raid0] [raid1] 
	#md127 : inactive sdb[0](S)
	#      976761560 blocks super 1.2

	md_name=$(cat /proc/mdstat | grep "md" | awk '{print $1}')
	if [ -n "$md_name" ]; then
		$MDADM -S /dev/${md_name}
		if [ $? -eq 1 ]; then
			return 1
		fi
	fi

	arr_hdd=($(cat /proc/mdstat | grep "md" | awk '{for(i=1;i<=NF;i++){print $i}}' | grep sd* | awk -F'[' '{print $1}'))
	if [ -n "$arr_hdd" ]; then
		arr_size=${#arr_hadd[@]}
		for ((i=0;i<$arr_size;i++))
		do
		{
			# clear superblock
			$MDADM --misc --zero-superblock ${arr_hdd[${i}]}
			if [ $? -eq 1 ]; then
				return 1
			fi
		}
		done
	fi
}

############################################################
# delete raid
############################################################
raid_delete() {
	# kill user
	$FUSER -k $DIR_RAID_MOUNT

	# umount
	$UMOUNT $DIR_RAID_MOUNT >/dev/null 2>&1

	# clear auto mount configure
	sed -i "/${DIR_RAID_SED}/d" $FSTAB

	raid_stop

	# clear raid config
	> $CONF_RAID
}

############################################################
# Handles input
############################################################
input_getopts() {
    while getopts ":cdfhmlstv" opt; do
		case $opt in
			c)
				if [ "$2" = "all" ]; then
					raid_create
					raid_mk_fs
					raid_mount
				else
					raid_create
				fi
				;;
			d)
				raid_delete
				;;
			f)
				raid_mk_fs
				;;
			l)
				hdd_list
				;;
			h)
				usage
				;;
			m)
				raid_mount
				;;
			s)
				raid_status
				;;
			t)
				hdd_clean
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
#Check dependencies
checkdeps >/dev/null
if [ $? -eq 1 ]; then
	echo "Check dependencies failed"
	exit 1
fi

input $*
