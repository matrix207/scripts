#!/usr/bin/bash
################################################################################
# Copy files, and show progress bar
#
# History:
#        2013/01/04 Dennis Create
#                          Only work on copy one file
#        2013/04/22 Dennis Change for copy directory
################################################################################

DEBUG=0
decho() {
	if [ $DEBUG -eq 1 ]; then
		echo ">>> $* <<<"
	fi
}

print_bar() {		# print the bar 

	local Count=$1
	local Max=$2
	local Remain=$3
	local Elapsed=$4
	local Speed=$5
	local LenBar=50
	if [ $# -eq 6 ]; then
		LenBar=$6
	fi
	if [ ${Count} -gt ${Max} ]; then
		Count=${Max}
	fi
	local Percent=$(((100*Count)/Max))
	local BarPercent=$(((LenBar*Percent)/100))

	if [ ${Percent} -eq 100 ]; then
		Remain=0
	fi
	
	local BarProgress=$(for i in $(seq ${BarPercent}); do echo -n '='; done)
	BarProgress="${BarProgress:0:${#BarProgress}}>"
	local Nxt=$((LenBar-BarPercent))
	local BarPad=$(for i in $(seq ${Nxt}); do echo -n '.'; done)

	local TElapsed=$(date -u -d @$Elapsed +%Hh%Mm%Ss)
	TElapsed=$(echo ${TElapsed} | sed -e "s/^00h//" -e "s/^00m//")

	local TRemain=$(date -u -d @$Remain +%Hh%Mm%Ss)
	TRemain=$(echo ${TRemain} | sed -e "s/^00h//" -e "s/^00m//")

	local larg=$(tput cols)
	if [ ${TimeElapsed} -gt ${TimeDiff} ] && [ ${EndBar} -eq 0 ] && [ ${Remain} -gt 0 ]; then		
		local mess0="[ ${Percent}% ][${BarProgress}${BarPad}] (${Speed}K/s) [ Remain: ${TRemain} Spent: ${TElapsed} ]"
		local mess=" :: ${mess0}"
		local mess1="${TAB_}${mess0}"
		echo -en "\r${mess1}\033[K"
		if [ ${#mess} -gt ${larg} ]; then
			echo -ne "\r\033[1A"
		fi
	else
		echo -en "\r${TAB_}[ ${Percent}% ][${BarProgress}${BarPad}][ Time: ${TElapsed} ]\033[K"
	fi
}

################################################################################
# Main
################################################################################
size_org_total=0
size_dst_old=$(du -s ${!#} | awk '{print $1}')
decho "size_dst_old = $size_dst_old"
size_dst_cur=0
size_cp_minus=0
for i in $@
do
	if [ -f $i -o -d $i ]; then
		size_tmp=$(du -s $i | awk '{print $1}')
		size_org_total=$(( size_org_total + size_tmp))
	fi
	# if copy directory, the size of total copy need to minus 8 bytes
	if [ -d $i ]; then
		size_cp_minus=8
	fi
done
# if copy directory, the size of total copy need to minus 8 bytes
size_org_total=$(( size_org_total - size_dst_old - size_cp_minus ))
decho "size_org_total = $size_org_total"

# Start cp 
cp $@ &

TimeDiff=10
EndBar=0
TimeStart=$(date +%s)
size_have_cp=0
while [ ${size_org_total} -gt ${size_have_cp} ] && sleep 1
do
	#file_size_dst=$(du $2 | awk '{print $1}')
	size_dst_cur=$(du -s ${!#} | awk '{print $1}')
	decho "size_dst_cur = $size_dst_cur"
	size_have_cp=$(( size_dst_cur - size_dst_old ))
	decho "size_have_cp = $size_have_cp"

	TimeNow=$(date +%s)
	TimeElapsed=$(( TimeNow-TimeStart ))
	Speed=$(( size_have_cp/TimeElapsed ))
	TimeRemain=$(( ( size_org_total - size_have_cp ) / Speed ))
	print_bar ${size_have_cp} ${size_org_total} ${TimeRemain} ${TimeElapsed} ${Speed}
#	print_bar ${BytesLoadNow} ${BytesLoadMax} ${TimeRemain} ${TimeElapsed} ${Speed} ${LenBar}
done
echo

exit 0
