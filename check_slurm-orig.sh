#!/bin/bash

PROGNAME="Slurm check"
VERSION="0.1"
AUTHOR="(c) 2014 Cullum JP"

# Exit codes
#STATE_OK=0
#STATE_WARNING=1
#STATE_CRITICAL=2
#STATE_UNKNOWN=3

print_version() {
    echo "$PROGNAME $VERSION $AUTHOR"
}

print_usage() {
    echo "Usage: $PROGNAME [-h|-V]"; echo ""
    echo "  -h"; echo "          print the help message and exit"
    echo "  -V"; echo "          print version and exit"
}
print_help() {
    print_version
    echo ""
    echo "Plugin for Nagios to check Slurm"
    echo ""
    print_usage
    echo ""
}

#SLURM CHECK

QUEUE=($(/usr/bin/sinfo | awk '{print $1}'))

for item in ${QUEUE[@]:1}
do
#Get SINFO Status'
NODE_STATE=($(/usr/bin/sinfo | grep $item | awk -v N=5 '{print $N}'))
	for state in ${NODE_STATE[@]}
	do
		NODE_NO=`/usr/bin/sinfo | grep $state | awk -v N=4 '{print $N}'`
		NODE_LIST=`/usr/bin/sinfo | grep $state | awk -v N=6 '{print $N}'`
	done
#IF statements for Node states
if [ $state -ne 'idle' ] && [ $state -ne 'alloc' ]
then	
	ITEM_STATE=warning
elif [ $state == 'drain' ]
then
	ITEM_STATE=critical
else
	ITEM_STATE=ok
fi

#echo -e "there are $NODE_NO in $NODE_STATE: $NODE_LIST"
echo -e "$item $ITEM_STATE $NODE_NO $state $NODE_LIST" 
done
if [[ $ITEM_STATE == 'critical' ]]
	then
		exitstatus=2
elif
	[[ $ITEM_STATE == 'warning' ]]
	then
		exitstatus=1
else
		exitstatus=0

fi

#Email settings
#export ADMIN_EMAIL="support@cfms.org.uk"

#EMAIL_DRAINED_SUPPORT=echo "$NODE_LIST are in $NODE_STATE state, please look at them asap" | mail $ADMIN_EMAIL -s "Node Drained - please check node" 

#EMAIL_DOWN_SUPPORT=echo "$NODE_LIST are in $NODE_STATE state, please look at them asap" | mail $ADMIN_EMAIL -s "Node Down - Please check node"

exit $exitstatus