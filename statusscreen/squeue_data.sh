#!/bin/bash

#Login to Login02
ssh Login02 bash -c "'
data=`/usr/bin/squeue`
export $data
'"
echo $data >> /var/www/html/statusscreen/data/squeue.html

exit 0

