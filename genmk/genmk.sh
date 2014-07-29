#!/bin/bash
############################################################
# Auto generate configure file
#
# History:
#   2014/07/29 v0.2 Dennis Use which to check dependencies
#   2014/07/29 v0.1 Dennis Create
############################################################

############################################################
# Version
############################################################
VERSION=0.2

############################################################
# Debug Configs
############################################################
DEBUG=0
_ERR_HDR_FMT="%.23s %s[%s]: "
_ERR_MSG_FMT="${_ERR_HDR_FMT}%s\n"

############################################################
# Global configs
############################################################
PROG=`basename $0`
NEED_ROOT=0

############################################################
# Load deps into array
############################################################
DEPS=(autoscan autoconf automake)
DEPLEN=${DEPS[@]} 

############################################################
# Debug echo
############################################################
decho() {
	if test $DEBUG -eq 1 ; then
		printf "$_ERR_MSG_FMT" $(date +%F.%T.%N) ${BASH_SOURCE[1]##*/} ${BASH_LINENO[0]} "${@}"
		#echo ">>>>> $* <<<<<"
	else
		echo "${@}"
	fi
}

############################################################
# Display proper usage
############################################################
usage() {
cat << EOF
NAME
      $PROG v$VERSION
      $PROG a shell script for generate configure file.
 
SYNOPSIS
      $PROG [-t target] [-s src_dir] [-i inc_dir] [-l library] [-d define] [-h help] [-v version]
 
COMMAND LINE OPTIONS
      -t target 
            Point the target name, which is the bin name after linking.

      -s source_files
            and tell where to the sources should be compiled.
            If -s option is not used, will use all the c files in 
            current directory.

      -i include directory

      -l library 
            Such as pthread

      -d define
            -d DLINUX

      -h help
            Show the help message.
 
      -v version
            Show the version.
 
EXAMPLES
      $PROG -t hello
      $PROG -t hello -s ./
      $PROG -t thrpool -s ./threadpool -l -lpthread -i -I./threadpool -d -DLINUX
EOF
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
	if test $NEED_ROOT -eq 1 ; then
		decho "Checking for root privs ... "
		if [ `whoami` = "root" ] ; then
			decho "Passed"
		else
			decho -e "Failed! you need root privs"
			#exit 0
			return 1
		fi
	fi

    for x in "${DEPS[@]}" ; do
        decho "Checking for "$x" ... "
        which $x 1> /dev/null 2> /dev/null
        if [  $? != 0  ] ; then
            decho "Failed! "$x" not found"
            #exit 0
			return 1
        else
            decho "Passed"
        fi
    done
	return 0
}

############################################################
# WARNING, NOT USE THIS FUNCTION
# generate configure
############################################################
gen_configure() {
    while getopts ":l:i:t:s:" opt; do
		echo $opt
		case $opt in
			l)
				;;
			i)
				;;
			t)
				;;
			s)
				;;
			'?')
				echo "Invalid parameters for connection!"
				return 1
				;;
		esac
	done
echo $lib
echo $bin
echo $src
	#shift 1
	#src=$@

	return 0

	return 0
}

############################################################
# clean temporary files
############################################################
clean_temporary() {
	rm -rf .deps
	rm -rf autom4te.cache
	rm -f aclocal.m4  autoscan.log config.log config.status \
	configure configure.in configure.scan depcomp install-sh \
	Makefile.am Makefile.in missing Makefile
}

############################################################
# Handles input
############################################################
input_getopts() {
    while getopts ":chvt:i:l:s:d:" opt; do
		case $opt in
			c)
				clean_temporary
				exit 0
				;;
			t)
				bin=$OPTARG
				;;
			i)
				inc=$OPTARG
				;;
			l)
				lib=$OPTARG
				;;
			d)
				def=$OPTARG
				;;
			s)
				src_dir=$OPTARG
				;;
			h)
				usage
				;;
			v)
				version
				;;
			'?')
				echo "$0: invalid option -$OPTARG" >&2
				usage
				;;
		esac
	done

	checkdeps
	if [ $? -eq 1 ]; then
		exit 0
	fi

	if [ $src_dir"yes" == "yes" ];then
		echo "no sources is specified,I will use all the current directory c files"
		src=`ls *.c|xargs echo `

	else
		echo "after shift the sources file is $src"
		src=`ls ${src_dir}/*.c|xargs echo `
	fi

	autoscan

cat configure.scan | awk '{if($0 ~ /AC_INIT/){print $0;insert=1};if(insert)\
{print("AM_INIT_AUTOMAKE($bin,1.0)");insert=0;next;}if($0 ~ /AC_CONFIG_/)next;\
if($0 ~ /AC_OUTPUT/){print("AC_OUTPUT(Makefile)");next}print $0}' >configure.in

	aclocal
	autoconf

echo "
AUTOMAKE_OPTIONS = foreign
INCLUDES = $inc $def
LIBS = $lib
bin_PROGRAMS = $bin
$bin"_SOURCES" = $src" >Makefile.am

	automake -a -c
	#./configure
}

input() {
	if [ $# -lt 1 ]; then
		usage
	fi
 
	input_getopts $*
}

############################################################
# Main
############################################################
input $*

