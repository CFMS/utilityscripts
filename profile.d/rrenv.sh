#!/bin/bash

# This script will set certain environment variables and modulepaths based upon
# group membership

GROUPLIST=`groups`
GROUPLIST="rr  rrcfd cfms"
PRIMARYGROUP=`echo $GROUPLIST | awk '{print $1}'`

# check to see if a user is in RR or not

if [[ $PRIMARYGROUP != "rr" ]]
  then
    exit
fi


# check for the existence of .flexlmrc, and create it with RR config if not
if [ ! -f ~/.flexlmrc ]; then
        echo "RR_LD_LICENSE_FILE=6915@b02" > ~/.flexlmrc
        echo "Creating .flexlmrc license configuration file"
fi
# is the user a member of RRCFD

if [[ $GROUPLIST == *" rrcfd "* ]]
  then
    echo "module use /gpfs/rr/rrcfd/nlr/apps/modulefiles"
fi

if [[ $GROUPLIST == *" rrfea "* ]]
  then
    echo "module use /gpfs/rr/rrfea/nlr/apps/modulefiles"
fi
