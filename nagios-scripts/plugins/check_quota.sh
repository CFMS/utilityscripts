#
# ## Description:
#
# This plugin is used to monitor fileset quota's for GPFS filesystems. It use's mmlsfileset and mmlsquota.
# You need to use this on a node that has permissions to use mmlsfileset and mmlsquota commands, such as a management node or a storage 
# node. It will output a general ok, warning or critical, but will also output each individual filesets current usage, hard quota and the
# percentage used.
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

print_version() {
    echo "$PROGNAME $VERSION $AUTHOR"
}

print_usage() {
    echo "Usage: $PROGNAME [-h|-V|-C]"; echo ""
    echo "  -C"; echo "		 Defines the Cluster Name of your GPFS Cluster"
    echo "  -h"; echo "          print the help message and exit"
    echo "  -V"; echo "          print version and exit"
}
print_help() {
    print_version
    echo ""
    echo "Plugin for Nagios to check mmlsquota"
    echo ""
    print_usage
    echo ""
}

# Grab the command line arguments

exitstatus=$STATE_WARNING #default

while getopts "h:V:C:" o; do
        case "${o}" in
                C)
                        export CLUSTERNAME=${OPTARG}
                        ;;
                h)
                        print_help
			exit $STATE_OK
			;;
                V)
                        print_version
			exit $STATE_OK
			;;
                *)
                        print_usage
			exit $STATE_UNKNOWN
                        ;;
        esac
done

FILESET=($(/usr/lpp/mmfs/bin/mmlsfileset $CLUSTERNAME | awk '{print $1}'))

for item in ${FILESET[@]:2}
do
    
USAGE_VAL=`/usr/lpp/mmfs/bin/mmlsquota -j $item $CLUSTERNAME | grep $CLUSTERNAME | awk -v N=3 '{print $N}'`
        
if [ $USAGE_VAL == 'no' ]; then usage="0" ; else usage=`expr $USAGE_VAL / 1024 / 1024`; fi
    

HARD_VAL=`/usr/lpp/mmfs/bin/mmlsquota -j $item $CLUSTERNAME | grep $CLUSTERNAME | awk -v N=5 '{print $N}'`
        
if [ -z $HARD_VAL ] ; then hard="0" ; else hard=`expr $HARD_VAL / 1024 / 1024`; fi
    

if [ -z $HARD_VAL ] ; then percentage="0" ; else percentage=$(($usage * 100 /$hard));  fi

if [[ $percentage -gt 90 && $percentage -lt 95 ]]
        then
		item_state="Warning"
		mesg="$usage GB used, $hard GB total, $percentage %"
	fi
if [[ $percentage -gt 98 ]]
        then
		item_state="critical"	
		mesg="$usage GB used, $hard GB total, $percentage %"
	fi
if [[ $percentage -lt 90 ]]
       then 
		item_state="ok"
		mesg="$usage GB used, $hard GB total, $percentage %"
	fi

echo -e "$item $item_state $mesg"

	if [[ $item_state == 'Warning' ]]
		then
			exitstatus=1
		else
			exitstatus=0
	fi
done
echo $exitstatus

exit $exitstatus

 # vim: autoindent number ts=4
