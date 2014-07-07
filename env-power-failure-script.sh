#!/bin/bash

##Command Definition 

ADMIN_EMAIL=support@cfms.org.uk

#Received Notice of Failure: Email out to Admins Power Failure event has occurred
FAIL1=mail -s "Power Failure Notice" $ADMIN_EMAIL < /root/power-failure/admin-notice

# Send Email to Admins, power failure > 3 minutes Starting Power off of Compute
FAIL2=mail -s "Power Failure Notice - 3 Minutes" $ADMIN_EMAIL < /root/power-failure/compute-power-off

#QSTAT Email to Admins
QSTAT_EMAIL=mail -s "QSTAT Report - Outage Alert" $ADMIN_EMAIL < /root/power-failure/outage-'date "+%Y%m%d"'.out

#Compute Off
POWER_OFF_NODES=$POWER_OFF_COMPUTE|$POWER_OFF_PPN|$POWER_OFF_GPU|$POWER_OFF_CMC1|$POWER_OFF_CMC2
POWER_OFF_COMPUTE=ssh mgt01 /opt/xcat/bin/rpower compute off
POWER_OFF_PPN=ssh mgt01 /opt/xcat/bin/rpower ppn off
POWER_OFF_GPU=ssh mgt01	/opt/xcat/bin/rpower gpu off
POWER_OFF_CMC1=ssh mgt01 snmpset -v 1 -c community cmc1 .1.3.6.1.4.1.107.206.1.3.1.2.1.1.2.$SLOT i 2
POWER_OFF_CMC2=ssh mgt01 snmpset -v 1 -c community cmc2 .1.3.6.1.4.1.107.206.1.2.1.2.1.1.2.$SLOT i 2
QSTAT_CAPTURE=ssh login01 'module load sge62u5; qstat -u "*" > /root/power-failure/outage.out'
QSTAT_SCP=scp login01:/root/power-failure/outage.out /root/power-failure/outage-'date "+%Y%m%d"'.out
POWER_OFF_HEAD=ssh mgt01 /opt/xcat/bin/rpower head off
POWER_OFF_LOGIN=ssh mgt01 /opt/xcat/bin/rpower login off

#Compute On
POWER_ON_I_NODES=$POWER_ON_GPU|$POWER_ON_PPN|$POWER_ON_HEAD|$POWER_ON_LOGIN
POWER_ON_GPU=ssh mgt01 /opt/xcat/bin/rpower gpu on
POWER_ON_PPN=ssh mgt01 /opt/xcat/bin/rpower ppn on
POWER_ON_HEAD=ssh mgt01 /opt/xcat/bin/rpower head on
POWER_ON_LOGIN=ssh mgt01 /opt/xcat/bin/rpower login on
NODE_LS=ssh mgt01 nodels > /root/power-failure/nodels.out
NODE_LIST_SCP=scp mgt01:/root/power-failure/nodels-'date "+%Y%m%d"'.out

##Actual Script



# Check Power Outage is still occuring
[Power outage check command]
if ^answer=yes
then do $POWER_ON
else

# Wait 5 minutes for next set of instructions