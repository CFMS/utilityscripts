#!/bin/bash

#Run the list command and create array

FILESET=($(mmlsfileset mogpfs | awk '{print $1}'))

#Show the array Size

echo "Array size: ${#FILESET[*]}"

#Show the items in the Array

echo "Array items:"
for item in ${FILESET[*]}
do
    printf "   %s\n" $item
done

#Create the Array Indexes

echo "Array indexes:"
for index in ${!FILESET[*]}
do
    printf "   %d\n" $index
done

#Show the Array Items and Indexes

echo "Array items and indexes:"
for index in ${!FILESET[*]}
do
    printf "%4d: %s\n" $index ${FILESET[$index]}
done

#For Item in Fileset define Usage, Hard Quota and Percentage used

echo "quota for fileset"


for item in ${FILESET[@]:2}
do
	echo $item "your current usage is"
	USAGE_VAL=`mmlsquota -j $item mogpfs | grep mogpfs | awk -v N=3 '{print $N}'`
	if [ $USAGE_VAL == 'no' ]; then usage="0" ; else usage=`expr $USAGE_VAL / 1024 / 1024`; fi
	echo $usage"GB"
	
	echo $item "your hard quota is"
	HARD_VAL=`mmlsquota -j $item mogpfs | grep gpfs | awk -v N=5 '{print $N}'`
	if [ -z $HARD_VAL ] ; then hard="0" ; else hard=`expr $HARD_VAL / 1024 / 1024`; fi
	echo $hard"GB"
	
	echo $item "your percentage usage is"
	if [ -z $HARD_VAL ] ; then percentage="0" ; else PERCENTAGE_VAL= echo "scale=2; $usage*100/$hard" | bc | echo "%"; fi
done

