#!/bin/bash

#arr_folder=($(ls | awk '{print $0}'))
#arr_size=${#arr_folder[@]}
#
#for ((i=0;i<$arr_size;i++))
#do
#{
#	if [ -d ${arr_folder[${i}]} ]; then
#		( cd ${arr_folder[${i}]}; echo update `pwd`; git pull )
#	fi
#}
#done

#for i in ${arr_folder[@]}
#do
#{
#	if [ -d $i ]; then
#		(cd $i; echo update `pwd`; git pull)
#	fi
#}
#done

for i in `ls`
do
{
	if [ -d $i ]; then
		(cd $i; echo update `pwd`; git pull)
	fi
}
done
