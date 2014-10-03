#!/bin/bash
#Login to Login02

ssh login02 bash -c "'
sinfodata=`/usr/bin/sinfo`
export $sinfodata"

echo $sinfodata

exit 0