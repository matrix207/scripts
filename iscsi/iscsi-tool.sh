#!/bin/bash

PROG=`basename $0`
VERSION=1.0
BUILD_TIME="compiled 2015-01-04 19:10"
COPY_RIGHT="Copyright (C) 2015. All rights reserved."

function iscsi_discovery()
{
	local ip=$1
	iscsiadm -m discovery -t st -p $ip
}

function iscsi_logout_all()
{
	lsscsi |wc -l
	iscsiadm -m node -U all
	iscsiadm -m node -o delete
	iscsiadm -m node
}

function iscsi_login_all()
{
	local ip=$1
	iscsi_discovery $ip
	iscsiadm -m node -L all
}

############################################################
# Usage
############################################################
usage() {
	echo "Usage: $PROG [-D ip] [-U ] [-L ip] [-h] [-v]"
	echo "            -D ip, discovery"
	echo "            -U, logout all"
	echo "            -L ip, login all"
	echo "            -h, show help"
	echo "            -v, show version"
	echo " "
	echo "EXAMPLES"
	echo "      $PROG -D 172.16.130.100"
	echo "      $PROG -U "
	echo "      $PROG -L 172.16.130.100"
	echo "      $PROG -h"
	echo "      $PROG -v"
	exit 0
}

############################################################
# version
############################################################
version() {
	echo $PROG -v$VERSION $BUILD_TIME
	echo $COPY_RIGHT
	exit 0
}

# Main
############################################################
# Handles input
############################################################
input_getopts() {
    while getopts ":D:L:Uv" opt; do
		case $opt in
			D)
				local ip=$OPTARG
				iscsi_discovery $ip
				;;
			L)
				local ip=$OPTARG
				iscsi_login_all $ip
				;;
			U)
				iscsi_logout_all
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

