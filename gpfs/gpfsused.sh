#!/bin/bash

GPFS_USED=($(ssh login02 df -h /gpfs | awk '{print $3}'))

echo ${GPFS_USED[2]}

exit 0