#!/bin/bash

# This script will parse some GPFS reporting information to get GPFS quotas for all users

#TMPDIR=/tmp/gpfsquotas
#GPFSFS=prgpfs
#SCHEDNOD=head01

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
export IFS=$'\n'
for i in $(cat $TMPDIR/filesets.out | tail -n +3)
	do
		# define the fileset name
		FILESETNAME=`echo $i | awk '{print $1}'`
		echo $FILESETNAME
		# define the fileset root
		FILESETROOT=`echo $i | awk '{print $3}'`
		echo $FILESETROOT
		# find the fileset and write the quota to a file in the root
		cat $TMPDIR/mmlsfilesetj.out | awk -v fsname=$FILESETNAME '$1==fsname{printf "%-5.2f %5-s %.2f  %s\n",  $3/1048576,"GB",$3/$5*100,"% Used"}' > $FILESETROOT/filesetquotause.txt
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
#   this can output the users total GPFS use.  Not helpful though, as will aggregate across all filesets
#		cat $TMPDIR/mmlsfilesetu.out | awk -v username=${userdeets[0]} '$1==username{printf "%-5.2f %5-s\n",  $3/1048576,"GB"}' > ${userdeets[3]}/userquotause.txt
		if [ ${userdeets[1]} = 701 ] # group is RR
			then
				FILESETDIR=`echo ${userdeets[3]} | awk -F/ '{print "/"$2"/" $3}'`
				cat $FILESETDIR/filesetquotause.txt > ${userdeets[3]}/groupquota.txt
		elif [ ${userdeets[1]} = 702 ] # groups is Airbus
			then
				FILESETDIR=`echo ${userdeets[3]} | awk -F/ '{print "/"$2"/" $3}'`
				cat $FILESETDIR/filesetquotause.txt > ${userdeets[3]}/groupquota.txt
		elif [ ${userdeets[0]} = de1 ] # user is de1
			then
				FILESETDIR=/gpfs/thirdparty/de/de1
				cat $TMPDIR/mmlsfilesetu.out | awk -v username=de1 '$1==username{printf "%-5.2f %5-s\n",  $3/1048576,"GB"}' > ${userdeets[3]}/groupquota.txt
		elif [ ${userdeets[1]} = 698 ] # groups is asrc
			then
				FILESETDIR=`echo ${userdeets[3]} | awk -F/ '{print "/"$2"/" $3}'`
				cat $FILESETDIR/filesetquotause.txt > ${userdeets[3]}/groupquota.txt
		else
				FILESETDIR=`echo ${userdeets[3]} | awk -F/ '{print "/"$2"/" $3"/"$4}'`
				cat $FILESETDIR/filesetquotause.txt > ${userdeets[3]}/groupquota.txt
		fi
	done
unset IFS
