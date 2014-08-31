# SCRIPT LIBRARY
# ------ -------

# Note:
# No "#!" here.
# No "live code" either.

# let not work for dash shell, just work for bash shell

# Reference
# 1. [Bash shell-scripting libraries](http://dberkholz.com/2011/04/07/bash-shell-scripting-libraries/)

# Useful variable definitions

ROOT_UID=0    # Root has $UID 0.
E_NOTROOT=101 # Not root user error.
MAXRETVAL=255 # Maximum (positive) return value of a function.
SUCCESS=0
FAILURE=-1

# Functions
Usage ()
{
  if [ -z "$1" ]
  then
  msg=filename
  else
  msg=$@
  fi
  # "Usage:" message.
  # No arg passed.
  echo "Usage: `basename $0` "$msg""
}

# Check if root running script.
Check_if_root ()
{
  if [ "$UID" -ne "$ROOT_UID" ]
  then
    echo "Must be root to run this script."
    exit $E_NOTROOT
  fi
}

# Creates a "unique" temp filename.
CreateTempfileName () 
{
  prefix=temp
  suffix=`eval date +%s`
  Tempfilename=$prefix.$suffix
}

# Tests whether *entire string* is alphabetic.
isalpha2 ()
{
  [ $# -eq 1 ] || return $FAILURE
  case $1 in
    *[!a-zA-Z]*|"") return $FAILURE;;
    *) return $SUCCESS;;
  esac
}

# Absolute value.
# Caution: Max return value = 255.
abs ()
{
  E_ARGERR=-999999
  if [ -z "$1" ] # Need arg passed.
  then 
    return $E_ARGERR 
  fi 
  if [ "$1" -ge 0 ]
  then
    absval=$1
  else
    let "absval = (( 0 - $1 ))" #
  fi 
  return $absval
}

# Converts string(s) passed as argument(s) to lowercase.
tolower ()
{
  if [ -z "$1" ]
    then
  echo "(null)"
    return
  fi

  echo "$@" | tr A-Z a-z
  # Translate all passed arguments ($@).

  return
# Use command substitution to set a variable to function output.
# For example:
# oldvar="A seT of miXed-caSe LEtTerS"
# newvar=`tolower "$oldvar"`
# echo "$newvar"
# a set of mixed-case letters
#
# Exercise: Rewrite this function to change lowercase passed argument(s)
# to uppercase ... toupper() [easy].
}

multiply ()
{
  # Multiplies params passed.
  # Will accept a variable number of args.
  local product=1
  until [ -z "$1" ] # Until uses up arguments passed...
  do 
    #let "product *= $1" 
    #For dash
    product=$((product*$1))
    shift 
  done 
  echo $product # Will not echo to stdout,
                #+ since this will be assigned to a variable.
}

testmsg ()
{
  local str="$@" 
  echo "ttt111$str" # 输出到stdout.
}

debecho () {
  if [ ! -z "$DEBUG" ]; then
    echo "$1" >&2
    #         ^^^ to stderr
  fi
}


_ERR_HDR_FMT="%.23s %s[%s]: "
_ERR_MSG_FMT="${_ERR_HDR_FMT}%s\n"
log() {
  if [ ! -z "$DEBUG" ]; then
    printf "$_ERR_MSG_FMT" $(date +%F.%T.%N) ${BASH_SOURCE[1]##*/} ${BASH_LINENO[0]} "${@}"
  fi
}


# Determines if user is root or not, return true (zero) value if user is root 
# else return nonzero value
isRootUser(){
  [ "$($ID -u)" == "0" ] && return $YES || return $NO
}
# Returns true if user account exists in /etc/passwd 
isUserExist(){
  [ "$1" == "" ] && exit 999 || u="$1"
  $GREP -E -w "^$u" $PASSWD_FILE >/dev/null
  [ $? -eq 0 ] && return $YES || return $NO
}
# Displays OS name for example FreeBSD, Linux etc
getOs(){
  echo "$($UNAME)"
}

# Display message and exit with exit code
die(){
  message="$1"
  exitCode=$2
  echo "$message"
  [ "$2" == "" ] && exit 1 || exit $exitCode
}
# Display hostname 
# host (FQDN hostname), for example, vivek (vivek.text.com)
getHostName(){
  [ "$OS" == "FreeBSD" ] && echo "$($HOSTNAME -s) ($($HOSTNAME))" || :
  [ "$OS" == "Linux" ] && echo "$($HOSTNAME) ($($HOSTNAME -f))" || :
  
}
# Display CPU information such as Make, speed
getCpuInfo(){
  if [ "$OS" == "FreeBSD" ]; then
    if ( isRootUser ); then # this is more reliable
      echo "$($GREP "CPU" /var/log/dmesg.today | $HEAD -1)"
    else # this may fail 
      echo "$($DMESG | $GREP "CPU" | $HEAD -1)"
    fi
  elif [ "$OS" == "Linux" ]; then
    :
  fi
}
# Display avilable RAM in system
getRealRamInfo(){
  if [ "$OS" == "FreeBSD" ]; then
    if ( isRootUser ); then # this is more reliable   
      echo "$($GREP -E "^real memory" /var/log/dmesg.today)|$CUT -d'(' -f2 | cut -d')' -f1)"
    else  
      echo "$($DMESG | $GREP -E '^real memory' | $CUT -d'(' -f2 | cut -d')' -f1)"
    fi
  elif [ "$OS" == "Linux" ]; then
    :
  fi
}
# Display system load for last 5,10,15 minutes
getSystemLoad(){
  [ "$OS" == "FreeBSD" ] && echo "$($UPTIME | $AWK -F'averages:' '{ print $2 }')" || :
  [ "$OS" == "Linux" ] && echo "$($UPTIME | $AWK -F'load average:' '{ print $2 }')" || :
}
# List total number of users logged in (both Linux and FreeBSD)
getNumberOfLoggedInUsers(){
  [ "$OS" == "FreeBSD" -o "$OS" == "Linux" ] && echo "$($W -h | $WC -l)" || :
}
# List total number of ethernet interface
getNumberOfInterfaces(){
  [ "$OS" == "FreeBSD" ] && echo "$($IFCONFIG | $GREP -Ew "\<UP" | $GREP -v lo0 | $WC -l)" || :
  [ "$OS" == "Linux" ] && echo "$($NETSTAT -i | $GREP -Ev "^Iface|^Kernel|^lo" | $WC -l)" || :
}
# Display Dynamically loaded kernel module aka drivers (both linux and FreeBSD)
getNumberOfKernelModules(){
  [ "$OS" == "FreeBSD" ] && echo "$($KLDSTAT | $GREP -vE "^Id Refs" | $WC -l)"
  [ "$OS" == "Linux" ] && echo "$($LSMOD | $GREP -vE "^Module" | $WC -l)"
}
# List total number of running process
getNumberOfRunningProcess(){
  [ "$OS" == "FreeBSD" ] && echo "$($PS -aux | $GREP -vE "^USER|ps -aux"|$WC -l)"
  [ "$OS" == "Linux" ] && echo "$($LSMOD | $GREP -vE "^Module" | $WC -l)"
}
# List number of mounted file system partition 
getNumberOfParittions() {
   if [ "$OS" == "FreeBSD" ]; then
     tmp="$($DF -aHt nonfs,nullfs,devfs| $GREP -vE "^Filesystem" | $AWK '{ print $1 " " }')"
     echo "$($DF -aHt nonfs,nullfs,devfs| $GREP -vE "^Filesystem" |$WC -l) ($tmp)"
   elif [ "$OS" == "Linux" ]; then
     tmp="$($DF -aHt ext3 -t ext2|$GREP -vE "^Filesystem" |$AWK '{ print $1 " " }')"
     echo "$($DF -aHt ext3 -t ext2|$GREP -vE "^Filesystem" |$WC -l) ($tmp)"
   fi
}
# Display current OS runlevel with Description of it
getOsRunLevel(){
  if [ "$OS" == "FreeBSD" ]; then
    r="$($SYSCTL -a | $GREP -wE "^kern.securelevel" | $AWK '{ print $2}')"
    case "$r" in
      -1) d="Permanently insecure mode";;
      0) d="Insecure mode";;
      1) d="Secure mode";;
      2) d="Highly secure mode";;
      3) d="Network secure mode";;
      *) d="Unknown runlevel";;
    esac
  elif [ "$OS" == "Linux" ]; then
    r="$($RUNLEVEL | $AWK '{ print $2}')"
    case "$r" in
      1) d="Single user mode";;
      2) d="Multi-user without NFS";;
      3) d="Full multi-user";;
      4) d="Unused/Experimental";;
      5) d="Multi-user with X11 windows";;
      *) d="Unknown runlevel";;
    esac
  fi
  echo "$r ($d)"
}
# List total number of SCSI/IDE disks connected to FreeBSD/Linux box
# along with device name includes CDROM, IDE/SCSI hard disk drive
# Example 3 (ad0 ad1 acd0)
getDiskDrives(){
  if [ "$OS" == "FreeBSD" ]; then  
    t="$($IOSTAT -d| $HEAD -1)"
    c="$(echo $t | $WC -w)" 
  elif [ "$OS" == "Linux" ]; then
    :    
  fi
  echo "$c ($t)"
}
