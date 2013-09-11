#!/usr/bin/sh
################################################################################
# git clone repositories
# History:
#        2013/04/23 Dennis Create
################################################################################

url=https://github.com/matrix207/
repostories=(matrix207.github.com shell config unpv3 vim VC C ldd emacs.d euler note pyfunny batch)
repos_size=${#repostories[@]}

for ((i=0;i<$repos_size;i++))
do
    if [ ! -d "${repostories[${i}]}" ]; then
        git clone ${url}${repostories[${i}]}.git
    fi
done
