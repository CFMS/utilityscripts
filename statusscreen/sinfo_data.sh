#!/bin/bash

#Login to Login02
ssh Login02 bash -c "'
data=`/usr/bin/sinfo`
export $data
'"
echo $data >> /var/www/html/statusscreen/data/sinfo.html

exit 0
