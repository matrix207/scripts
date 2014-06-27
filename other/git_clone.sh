#!/usr/bin/sh
################################################################################
# git clone repositories
# History:
#        2014/06/27 Dennis  Run "/bin/bash git_clone.sh" for ubuntu, because dash 
#                           is default shell on ubuntu
#        2013/04/23 Dennis  Create
################################################################################

url=https://github.com/matrix207/

REPOS=(matrix207.github.com batch scripts config unpv3 vim VC C ldd )

for i in "${REPOS[@]}" ;
do
    if [ ! -d "$i" ]; then
        git clone ${url}$i.git
    else
        echo exist $i
    fi
done

