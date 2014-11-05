#!/bin/bash

#Run the list command and create array

FILESET=($(mmlsfileset mogpfs | awk '{print $1}'))

#For Item in Fileset define Usage, Hard Quota and Percentage used

function myecho
{
  echo $1
}

for item in ${FILESET[@]:2}
do
	myecho $item "your current usage is"
	USAGE_VAL=`mmlsquota -j $item mogpfs | grep mogpfs | awk -v N=3 '{print $N}'`
	if [ $USAGE_VAL == 'no' ]; then usage="0" ; else usage=`expr $USAGE_VAL / 1024 / 1024`; fi
	myecho $usage"GB"
	
	myecho $item "your hard quota is"
	HARD_VAL=`mmlsquota -j $item mogpfs | grep gpfs | awk -v N=5 '{print $N}'`
	if [ -z $HARD_VAL ] ; then hard="0" ; else hard=`expr $HARD_VAL / 1024 / 1024`; fi
	myecho $hard"GB"
	
	myecho $item "your percentage usage is"
	if [ -z $HARD_VAL ] ; then percentage="0" ; else percentage=`echo scale=2 "$usage*100/$hard" | bc`; fi
	
	ITEMROOT=$(mmlsfileset mogpfs | grep -w $item | awk '{print $3}')
	echo "quota values= current usage: $usage GB, hard quota: $hard GB, percentage usage: $percentage %" > $ITEMROOT/quota.txt
	
done

