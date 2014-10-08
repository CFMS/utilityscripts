#!/bin/bash

SQUEUE_FILE=/var/www/html/statusscreen/data/squeue.html

rm -r $SQUEUE_FILE
touch $SQUEUE_FILE

#Get Lines of Data from squeue command

JOBID=($(ssh login02 squeue | awk '{print $1}'))
PARTI=($(ssh login02 squeue | awk '{print $2}'))
USER=($(ssh login02 squeue | awk '{print $4}'))
TIME=($(ssh login02 squeue | awk '{print $6}'))
NODES=($(ssh login02 squeue | awk '{print $7}'))

#for (( JOB = 0 ; JOB < ${#JOBID[@]:2} ; i++ ))

#for item in ${NODES[@]}
#do
#  sum=$(($sum + ${NODES[*]}))
#done

sum=$(awk 'BEGIN {t=0; for (i in ARGV) t+=ARGV[i]; print t}' "${NODES[@]}")

cat << EOF > $SQUEUE_FILE
<html>
<body>
<table>
 <tr>
 	<th>${JOBID[0]}</th>
 	<th>${PARTI[0]}</th>
 	<th>${USER[0]}</th>
 	<th>${TIME[0]}</th>
 </tr>

 <tr>
 	<td>${JOBID[1]}</td>
 	<td>${PARTI[1]}</td>
 	<td>${USER[1]}</td>
 	<td>${TIME[1]}</td>
 </tr>
 <tr>
 	<td>${JOBID[2]}</td>
 	<td>${PARTI[2]}</td>
 	<td>${USER[2]}</td>
 	<td>${TIME[2]}</td>
 </tr>
 <tr>
 	<td>${JOBID[3]}</td>
 	<td>${PARTI[3]}</td>
 	<td>${USER[3]}</td>
 	<td>${TIME[3]}</td>
 </tr>
 <tr>
 	<td>${JOBID[4]}</td>
 	<td>${PARTI[4]}</td>
 	<td>${USER[4]}</td>
 	<td>${TIME[4]}</td>
 </tr>
 <tr>
 	<td>${JOBID[5]}</td>
 	<td>${PARTI[5]}</td>
 	<td>${USER[5]}</td>
 	<td>${TIME[5]}</td>
 </tr>
<tr>
 	<td>${JOBID[6]}</td>
 	<td>${PARTI[6]}</td>
 	<td>${USER[6]}</td>
 	<td>${TIME[6]}</td>
 </tr>
 <tr>
 	<td>${JOBID[7]}</td>
 	<td>${PARTI[7]}</td>
 	<td>${USER[7]}</td>
 	<td>${TIME[7]}</td>
 </tr>
 <tr>
 	<td>${JOBID[8]}</td>
 	<td>${PARTI[8]}</td>
 	<td>${USER[8]}</td>
 	<td>${TIME[8]}</td>
 </tr>
</table>

Nodes currently utilised: $sum

</body>
</html>
EOF


exit 0
