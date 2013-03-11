#!/bin/bash
if [ $# -lt 1 ];then
    echo "you must specify a target parameter"
    exit
fi
target=$1
shift 1
sources=$@

if [ $sources"yes" == "yes" ];then
    echo "no sources is specified,I will use all the current directory c files"
    sources=`ls *.c|xargs echo `

#else
    #echo "after shift the sources file is $sources"
fi

if [ 0 == 0 ];then
autoscan
cat configure.scan | awk '{if($0 ~ /AC_INIT/){print $0;insert=1};if(insert){print("AM_INIT_AUTOMAKE($target,1.0)");insert=0;next;}if($0 ~ /AC_CONFIG_/)next;if($0 ~ /AC_OUTPUT/){print("AC_OUTPUT(Makefile)");next}print $0}' >configure.in
aclocal
autoconf
echo "
AUTOMAKE_OPTIONS = foreign
INCLUDES = `pkg-config --cflags gtk+-2.0`
LIBS = ` pkg-config --libs gtk+-2.0`
bin_PROGRAMS = $target
$target"_SOURCES" = $sources" >Makefile.am
automake -a -c
./configure
fi
