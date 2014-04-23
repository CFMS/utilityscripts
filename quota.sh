#!/bin/bash

#Run the list command and create array

FILESET=($(ls))

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

#Create Array from each Item
for item in ${FILESET[@]}
	do
		
done

