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

# write the current fileset quota usage to a file at the root of the fileset
IFS=$'\n'
for i in $(cat $TMPDIR/filesets.out)
	do 
		# define the fileset name
		FILESETNAME=`echo $i | awk -F: '{print $1}'`
		# define the fileset root
		FILESETROOT=`echo $i | awk -F: '{print $3}'`
		# find the fileset and write the quota to a file in the root
		echo "cat $TMPDIR/mmlsfilesetj.out | awk -v fsname=$FILESETNAME '$1==fsname{printf "%-15s %s\n",  $3/1048576 "GB",$3/$5*100"% Used"}' > $FILESETROOT/gpfsquotause.txt"
	done
		
		
unset IFS
# work through the list of users and create a report for each
IFS=$'\n'
for i in $(cat $TMPDIR/getent.out)
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
				FILESETDIR=`echo ${userdeets[3]} | awk -F/ '{print "/"$2"/" $3}'`
				echo "cat $FILESET/gpfsquota.txt > ${userdeets[3]}/gpfsquota.txt"
		elif [ ${userdeets[1]} = 702 ] # groups is Airbus
			then
				FILESETDIR=`echo ${userdeets[3]} | awk -F/ '{print "/"$2"/" $3}'`
				echo "cat $FILESET/gpfsquota.txt > ${userdeets[3]}/gpfsquota.txt"
		elif [ ${userdeets[0]} = de1 ] # user is de1
			then
				FILESETDIR=/gpfs/thirdparty/de/de1
		else
			echo "testing123"
		fi
	done
unset IFS

# work through the filesets to find out who belongs in it
#IFS=$'\n'
#for i in $(cat $TMPDIR/filesets.out)
#	do
#		fileset[0]=`echo $i | awk '{print $1}'`
#		fileset[1]=`echo $i | awk '{print $3}'`
#		echo ${fileset[1]}
#		FILESETHOME={fileset[1]}
#		cat $TMPDIR/getent.out | awk -F: '$6==$FILESETHOME{print $1}'
#	done
#unset IFS
