#!/bin/bash
# Test script for common.sh

DIR=`pwd`

. ${DIR}/common.sh

ps |grep $$ |awk '{print $4}'  

newstring=`testmsg "every sentence should start with a capital letter."`
echo "$newstring"

debecho "123"

debecho "abc"

m1=10; m2=3; m3=5;
#var1=`multiply $m1 $m2 $m3`
#debecho $var1
