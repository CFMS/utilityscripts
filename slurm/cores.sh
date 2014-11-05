#!/bin/bash

#Array Definitions - Get Current Core Usage from Slurm and SGE for all the Queues
sge_cores_compa_1=($(ssh services@login02 qstat -u "*" -s r -q all.q,rr.batch.q,fluent.q,rr.interactive.q | awk '$4 !="hyao" {print $9}'))
sge_cores_compb=($(ssh services@login02 qstat -u "*" -s r -q highmem.q | awk '{print $9}'))
sge_cores_compc=($(ssh services@login02 qstat -u "*" -s r -q highmem.q | awk '{print $9}'))
SLURMCORE=($(ssh login02 squeue -S -D --format=%C))
sge_cores_compa_2=($(ssh services@login02 qstat -u "*" -s r -q all.q,rr.batch.q,fluent.q,rr.interactive.q | awk '$4 =="hyao" {print $9*2}'))

# Totalling Up the number of cores in each array
sge_cores_compa_1_total=$(awk 'BEGIN {t=0; for (i in ARGV) t+=ARGV[i]; print t}' "${sge_cores_compa_1[@]}")
sge_cores_compa_2_total=$(awk 'BEGIN {t=0; for (i in ARGV) t+=ARGV[i]; print t}' "${sge_cores_compa_2[@]}")
sge_cores_compb_total=$(awk 'BEGIN {t=0; for (i in ARGV) t+=ARGV[i]; print t}' "${sge_cores_compb[@]}")
sge_cores_compc_total=$(awk 'BEGIN {t=0; for (i in ARGV) t+=ARGV[i]; print t}' "${sge_cores_compc[@]}")
slurm_cores_total=$(awk 'BEGIN {t=0; for (i in ARGV) t+=ARGV[i]; print t}' "${SLURMCORE[@]}")

total_cores=$(($sge_cores_compa_1_total + $sge_cores_compa_2_total + $sge_cores_compb_total + $sge_cores_compc_total + $slurm_cores_total))

echo $total_cores

exit 0