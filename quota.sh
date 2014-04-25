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
	echo "your current usage is"
	USAGE_VAL=`mmlsquota -j $item mogpfs | grep mogpfs | awk -v N=3 '{print $N}'`
	if [ $USAGE_VAL == 'no' ]; then usage="No Limit" ; else usage=`expr $USAGE_VAL / 1024 / 1024`; fi
	echo $usage"GB"
done

for item in ${FILESET[@]:2}
do
	echo "your hard quota is"
	HARD_VAL=`mmlsquota -j $item mogpfs | grep mogpfs | awk -v N=5 '{print $N}'`
	if [ $HARD_VAl == 'no' ]; then hard="No Limit" ; else hard=`expr $HARD_VAL / 1024 / 1024`; fi
	echo $hard"GB"
done	

for item in ${FILESET[@]:2}
do	
	echo "your percentage usage is"
	PERCENTAGE_VAL=`expr $usage / $hard`
	if [ $HARD_VAL == 'no' ]; then percentage="No Limit" ; else percentage=$PERCENTAGE_VAL; fi
	echo $percentage"%"
done
