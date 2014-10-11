#!/bin/bash

# This script will parse some GPFS reporting information to get GPFS quotas for all users

TMPDIR=/tmp/gpfsquotas
GPFSFS=prgpfs
SCHEDNOD=head01

export TMPDIR=/tmp/gpfsquotas
GPFSFS=mogpfs
SCHEDNOD=mologin01

if [ ! -e $TMPDIR ]
	then mkdir $TMPDIR
		
fi

# get a list of all users from SSSD

getent passwd --service=sss > $TMPDIR/getent.out

# get a list of filesets

mmlsfileset $GPFSFS > $TMPDIR/filesets.out

#   GET MMREPQUOTA - FILESETS INTO A FILE

mmrepquota -j $GPFSFS > $TMPDIR/mmlsfilesetj.out

#
#   GET MMREPQUOTA - USERS INTO A FILE

mmrepquota -u $GPFSFS > $TMPDIR/mmlsfilesetu.out

# work through the list of users and create a report for each
IFS=$'\n'
for i in cat $TMPDIR/getent.out
	do
		# first is username
		userdeets[0]=`echo $i | awk -F: '{print $1}'`
		# second is GID
		userdeets[1]=`echo $i | awk -F: '{print $4}'`
		# third is their actual name
		userdeets[2]=`echo $i | awk -F: '{print $5}'`
		# fourth is their homedir
		userdeets[3]=`echo $i | awk -F: '{print $6}'`
		if [ ${userdeets[1]} = 701 ] # group is RR
			then 
		elsif [ ${userdeets[1]} = 702 ] # groups is Airbus
			then
		elsif [ ${userdeets[0]} = de1 ] # user is de1
			then

# work through the filesets to find out who belongs in it
IFS=$'\n'
for i in $(cat $TMPDIR/filesets.out)
	do
		fileset[0]=`echo $i | awk '{print $1}'`
		fileset[1]=`echo $i | awk '{print $3}'`
		echo ${fileset[1]}
		FILESETHOME={fileset[1]}
		cat $TMPDIR/getent.out | awk -F: '$6==$FILESETHOME{print $1}'
	done
unset IFS