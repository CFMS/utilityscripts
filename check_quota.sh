#
# ## Description:
#
# This plugin users repquota command to get the quota values
# From the repqut output see the quota state as to what  ( ++ , +- , -- ) and identifies the Exit Stats for nagios
#
# ## Output:
#
# The plugin prints "ok" or either "warning" or "critical"
#
# Exit Codes
# 0 OK
# 1 Warning
# 2 Critical
# 3 Unknown  Invalid command line arguments or could not determine used space

PROGNAME="MMLSfilequota check"
VERSION="0.1"
AUTHOR="(c) 2014 Cullum JP"

# Exit codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

print_version() {
    echo "$PROGNAME $VERSION $AUTHOR"
}

print_usage() {
    echo "Usage: $PROGNAME [-h|-V]"; echo ""
    echo "  -h, --help"; echo "          print the help message and exit"
    echo "  -V, --version"; echo "          print version and exit"
}
print_help() {
    print_version
    echo ""
    echo "Plugin for Nagios to check user quota"
    echo ""
    print_usage
    echo ""
}

# Grab the command line arguments

exitstatus=$STATE_WARNING #default
while test -n "$1"; do
    case "$1" in
        --help)
            print_help
            exit $STATE_OK
            ;;
        -h)
            print_help
            exit $STATE_OK
            ;;
        --version)
            print_version
            exit $STATE_OK
            ;;
        -V)
            print_version
            exit $STATE_OK
            ;;
        *)
            echo "Unknown argument: $1"
            print_usage
            exit $STATE_UNKNOWN
            ;;
    esac
    shift
done

OKUSERS=""
WARNUSER=""
CRITUSER=""
PREVUSER=""


FILESET=($(mmlsfileset mogpfs))

for item in ${FILESET[@]:2}
do
    
USAGE_VAL=`mmlsquota -j $item mogpfs | grep mogpfs | awk -v N=3 '{print $N}'`
        
if [ $USAGE_VAL == 'no' ]; then usage="0" ; else usage=`expr $USAGE_VAL / 1024 / 1024`; fi
    

HARD_VAL=`mmlsquota -j $item mogpfs | grep gpfs | awk -v N=5 '{print $N}'`
        
if [ -z $HARD_VAL ] ; then hard="0" ; else hard=`expr $HARD_VAL / 1024 / 1024`; fi
    

if [ -z $HARD_VAL ] ; then percentage="0" ; else percentage=`echo scale=2 "$usage*100/$hard" | bc`; fi


if [ "$percentage" -eq "95" ]
        then
             WARNUSER=$WARNUSER:$PREVUSER
        fi
if [ "$percentage" -eq "100" ]
        then
         CRITUSER=$CRITUSER:$PREVUSER
        fi
if [ "$percentage" -ne "95" ]
       then
          OKUSERS=$OKUSERS:$PREVUSER
       fi

    PREVUSER=$percentage
done
if [ $CRITUSER ]; then
    mesg="CRITICAL - $usage, $hard, $percentage"
    exitstatus=$STATE_CRITICAL
elif [ $WARNUSER ]; then
    mesg="WARNING - $usage, $hard, $percentage"
    exitstatus=$STATE_WARNING
else
    mesg="OK - $usage, $hard, $percentage"
    exitstatus=$STATE_OK
fi

##msgs="CRITUSER : $CRITUSER \nWARNUSER : $WARNUSER \nOKUSERS : $OKUSERS"
echo -e "$mesg $msgs"
exit $exitstatus

 # vim: autoindent number ts=4