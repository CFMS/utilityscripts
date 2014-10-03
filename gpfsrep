#!/bin/bash

# This script will parse some GPFS reporting information, creating a report for Yoon Ho et al

TMPDIR=/tmp/gpfsreport
GPFSFS=prgpfs
SCHEDNOD=head01

TMPDIR=/tmp/gpfsreport
GPFSFS=mogpfs
SCHEDNOD=mologin01

if [ ! -e $TMPDIR ]
	then 
		mkdir $TMPDIR
		
fi

# get a list of RR users (looking for GID of 701

getent passwd | awk -F: '$4==701{print $1}' > $TMPDIR/rrusers.out

# get a list of RR filesets

mmlsfileset $GPFSFS | grep rr > $TMPDIR/rrfilesets.out

# define RRFILESETS

RRFILESETS=`awk '{print $1}' $TMPDIR/rrfilesets.out`

#
#   GET MMREPQUOTA - FILESETS INTO A FILE

mmrepquota -j $GPFSFS > $TMPDIR/mmlsfilesetj.out

#
#   GET MMREPQUOTA - USERS INTO A FILE

mmrepquota -u $GPFSFS > $TMPDIR/mmlsfilesetu.out

# get fileset quotas using mmrepquota

cat $TMPDIR/mmlsfilesetj.out | grep rr | awk 'BEGIN { printf "%-10s %-15s %-10s\n", "Group", "Storage Used", "Used"}{ printf "%-10s %-15s %s\n", $1, $3/1048576 "GB",$3/$5*100"%"}'


# get user usage 

cat $TMPDIR/mmlsfilesetu.out | grep -f $TMPDIR/rrusers.out | sort -rnk 3| awk 'BEGIN { printf "%-20s %-10s\n", "User", "Storage Used"; printf "%-20s %-10s\n", "========", "========"}{ printf "%-20s %-10s\n", $1,$3/1048576"GB"}'

# get userset lists from SGE

ssh $SCHEDNOD "module load sge62u5; qconf -sul | grep rr  " > $TMPDIR/rrusersets.out

# get rr accounts from SLURM

ssh $SCHEDNOD "sacctmgr show accounts | grep rr- | awk '{print \$2}'" > $TMPDIR/rraccounts.out

# get list of both SGE and SLURM groups

cat $TMPDIR/rrusersets.out $TMPDIR/rraccounts.out  > $TMPDIR/rrgroups.out


mkdir $TMPDIR/filesetworking

# get users for each SGE group

for i in $(cat $TMPDIR/rrusersets.out)
	do
		ssh $SCHEDNOD "module load sge62u5; qconf -su $i | grep -A 20 entries | xargs | sed \"s/,/\n/g\" | sed \"s/\ /\n/\" | tail -n +2 | sort | grep -v '^$'" > $TMPDIR/filesetworking/$i.sge.members
	done

# get users for each SLURM group

for i in $(cat $TMPDIR/rraccounts.out)
	do
		ssh $SCHEDNOD "sacctmgr -p show users | grep $i | awk -F\\| '{print \$1}'" > $TMPDIR/filesetworking/$i.slurm.members
	done

for i in $(ls $TMPDIR/filesetworking)	
	do
		echo "$i usage"
		echo "=========="
		cat $TMPDIR/mmlsfilesetu.out | grep -f $TMPDIR/filesetworking/$i | sort -rnk 3| awk 'BEGIN { printf "%-20s %-10s\n", "User", "Storage Used"; printf "%-20s %-10s\n", "========", "========"}{ printf "%-20s %-10s\n", $1,$3/1048576"GB"}'
		echo ""
		done
