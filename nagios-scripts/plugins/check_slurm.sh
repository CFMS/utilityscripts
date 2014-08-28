#!/bin/bash

QUEUE=($(/usr/bin/sinfo | awk '{print $1}' | uniq)) 

NODE_STATE=($(/usr/bin/sinfo | awk -v N=5 '{print $N}')) 

STATE1=drain
STATE2=idle
STATE3=alloc

for item in ${QUEUE[@]:1}
do
        NODE_NO1=`/usr/bin/sinfo | grep $STATE1 | grep $item | awk -v N=4 '{print $N}'`
        NODE_NO2=`/usr/bin/sinfo | grep $STATE2 | grep $item | awk -v N=4 '{print $N}'`
        NODE_NO3=`/usr/bin/sinfo | grep $STATE3 | grep $item | awk -v N=4 '{print $N}'`
        NODE_LIST1=`/usr/bin/sinfo | grep $STATE1 | grep $item | awk -v N=6 '{print $N}'`
        NODE_LIST2=`/usr/bin/sinfo | grep $STATE2 | grep $item | awk -v N=6 '{print $N}'`
        NODE_LIST3=`/usr/bin/sinfo | grep $STATE3 | grep $item | awk -v N=6 '{print $N}'`

echo $item $NODE_NO1 $STATE1 $NODE_NO2 $STATE2 $NODE_NO3 $STATE3

done

	if [[ -z "$NODE_NO1" ]]
		then
		ITEM_STATE=ok
	elif [[ $NODE_NO1 -lt 2 ]]
		then
		ITEM_STATE='warning'
	else
		ITEM_STATE='critical'
	fi

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


exit $exitstatus