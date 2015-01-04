#!/bin/bash

PROG=`basename $0`
VERSION=1.0
BUILD_TIME="compiled 2015-01-04 19:10"
COPY_RIGHT="Copyright (C) 2015. All rights reserved."

function logout_all()
{
	lsscsi |wc -l
	iscsiadm -m node -U all
	iscsiadm -m node -o delete
	iscsiadm -m node
}

function login_all()
{
	ip=$1
	iscsiadm -m discovery -t st -p $ip
	iscsiadm -m discovery -t st -p $ip
	iscsiadm -m node -L all
}

############################################################
# Usage
############################################################
usage() {
	echo "Usage: $PROG [-U ] [-L ip_addr] [-h] [-v]"
	echo "            -U, logout all"
	echo "            -L ipaddr, login all"
	echo "            -h, show help"
	echo "            -v, show version"
	echo " "
	echo "EXAMPLES"
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
    while getopts ":L:Uv" opt; do
		case $opt in
			L)
				local ip=$OTPARG
				login_all $ip
				;;
			U)
				logout_all
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

