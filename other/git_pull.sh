#!/bin/bash
################################################################################
# git clone repositories
# History:
#        2013/04/23 Dennis  Create
################################################################################

exclude_dir="-I test"

for i in `ls $exclude_dir`
do
{
	if [ -d $i ]; then
		(cd $i; echo update `pwd`; git pull)
	fi
}
done
