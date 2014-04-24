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
	USAGE=$(mmlsquota -j $item mogpfs | grep mogpfs |
		if [ $3 -eq no ]
		then echo "No Limit"
		else awk '{print $3/1024/1024}')
	printf "   %s\n" $USAGE
done

for item in ${FILESET[@]:2}
do
	echo "your hard quota is"
	HARD=$(mmlsquota -j $item mogpfs | grep mogpfs |
		if [ $3 -eq no ]
		then echo "No Limit" 
		else awk '{print $5/1024/1024}')
	printf "   %s\n" $HARD
done	
	
for item in ${FILESET[@]:2}
do	
	echo "your percentage usage is"
	PERCENTAGE=$(
	    if [ $HARD -eq No Limit ]
		then echo "No Percentage" 
		else awk '{print $USAGE/$HARD"%"}')
	printf "   %s\n" $PERCENTAGE
done
