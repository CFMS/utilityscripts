#!/bin/bash

# this script will run to check the permissions on a users home directory.
# If it is anything other than 700 (ie only readable by the owner) then an error
# will be printed on login


# check for override first (simpler execution) and exit if present

if [ -e ~/.warningsuppress ]; then break; fi

# check the permissions

if [ `stat -t --format=%a ~` != 700 ]; then
  echo -e "\e[35m  The permissions on your home directory have been changed from the
  default allowing other users to view files.   This system is a shared
  system and you may have allowed users outside your organisation to
  view confidential information.  This may be in breach of your
  organisation's IT Security policy, and can cause some applications to
  behave in an unexpected way";
  echo -e  "\e[92m  For more information on how to work collaboratively, please
  see http://kb.cfms.org.uk/en/latest/workingcollaboratively.html";
  echo -e "\e[33m  To suppress this message, create an empty file in your home
  directory called '.warningsuppress'\e[0m"
fi
