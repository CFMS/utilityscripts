#!/bin/bash

GPFS_SIZE=($(ssh login02 df -h /gpfs | awk '{print $2}'))

echo ${GPFS_SIZE[2]}

exit 0