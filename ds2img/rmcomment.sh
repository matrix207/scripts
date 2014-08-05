#!/bin/bash

#cp $1{,.bak}
#filename=$1.bak
filename=$1

#delete the comment line begin with '//comment'
sed -i "/^[ \t]*\/\//d" $filename

#delete the commnet line end with '//comment'
sed -i "s/\/\/[^\"]*//" $filename

#delete the comment only occupied one line '/* commnet */'
sed -i "s/\/\*.*\*\///" $filename  

#delete the comment that occupied many lines '/*comment
#                                              *comment
#                                              */
sed -i ":begin; { /\*\//! { $! { N; b begin }; }; s/\/\*.*\*\// /; };"  $filename

#???
sed -i "/^[ \t]*\/\*/,/.*\*\//d" $filename

#delete blank lines
sed -i '/^$/d' $filename

#delete the macro begin with '#', e.g '#define ' '#if '
sed -i '/\#.*/d' $filename

