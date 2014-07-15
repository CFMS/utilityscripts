#!/bin/bash

##Command Definition 

ADMIN_EMAIL=support@cfms.org.uk

#Notice of failure
FAIL1=mail -s "Power Failure Notice" $ADMIN_EMAIL < /root/power-failure/admin-notice

#power failure > 3 minutes Starting Power off of Compute
FAIL2=mail -s "Power Failure Notice - 3 Minutes" $ADMIN_EMAIL < /root/power-failure/compute-power-off

#QSTAT Email to Admins
QSTAT_EMAIL=mail -s "QSTAT Report - Outage Alert" $ADMIN_EMAIL < /root/power-failure/outage-'date "+%Y%m%d"'.out

#Powered-OFF-Compute email
PO_COMPUTE_EMAIL=mail -s "Cluster Powered Off" $ADMIN_EMAIL < /root/power-failure/Cluster-off

#Powered off MO and HP gear email
BO_COMPUTE_EMAIL1=mail -s "HP and MO Powered Off" $ADMIN_EMAIL < /root/power-failure/mo-off

#GPFS Shutdown Imminent
GPFS_SHUTDOWN_EMAIL1=mail -s "GPFS going Offline" $ADMIN_EMAIL < /root/power-failure/gpfs-warn

#Compute Off
POWER_OFF_COMPUTE=ssh mgt01 /opt/xcat/bin/rpower compute off
POWER_OFF_PPN=ssh mgt01 /opt/xcat/bin/rpower ppn off
POWER_OFF_GPU=ssh mgt01	/opt/xcat/bin/rpower gpu off
POWER_ASLEEP_CMC1=ssh mgt01 snmpset -v 1 -c community cmc1 .1.3.6.1.4.1.107.206.1.3.1.1.1.0 i 2
POWER_ASLEEP_CMC2=ssh mgt01 snmpset -v 1 -c community cmc2 .1.3.6.1.4.1.107.206.1.3.1.1.1.0 i 2
QSTAT_CAPTURE=ssh login01 'module load sge62u5; qstat -u "*" > /root/outage.out'
QSTAT_SCP=scp login01:/root/power-failure/outage.out /root/power-failure/outage-'date "+%Y%m%d"'.out
POWER_OFF_HEAD=ssh mgt01 /opt/xcat/bin/rpower head off
POWER_OFF_LOGIN=ssh mgt01 /opt/xcat/bin/rpower login off
POWER_OFF_MO_COMPUTE=ssh momgt01 /opt/xcat/bin/rpower compute off
POWER_OFF_MO_LOGIN=ssh momgt01 /opt/xcat/bin/rpower login off
POWER_OFF_CLUSTER_STOR=ssh mgt01 /opt/xcat/bin/rpower storage off
POWER_OFF_MO_STOR=ssh momgt01 /opt/xcat/bin/rpower storage off
CHECK_CLUSTER_POWER=ssh mgt01 /opt/xcat/bin/rpower all status > /root/power-check-outage.out
CHECK_CLUSTER_POWER_STATUS=scp mgt01:/root/power-check-outage.out /root/power-failure/power-check-outage-'date "+%Y%m%d"'.out
HOSTB08-VMWARE1_GUEST_SHUTDOWN=ssh 172.20.5.48 'for vm in `/usr/bin/vmware-cmd -l`; do /usr/bin/vmware-cmd "${vm}" stop trysoft; done'
HOSTB17-VMWARE2_GUEST_SHUTDOWN=ssh 172.20.5.57 'for vm in `/usr/bin/vmware-cmd -l`; do /usr/bin/vmware-cmd "${vm}" stop trysoft; done'
HOSTB18-VMWARE3_GUEST_SHUTDOWN=ssh 172.20.5.58 'for vm in `/usr/bin/vmware-cmd -l`; do /usr/bin/vmware-cmd "${vm}" stop trysoft; done'
HOSTB07-VMWARE4_GUEST_SHUTDOWN=ssh 172.20.5.47 'for vm in `/usr/bin/vmware-cmd -l`; do /usr/bin/vmware-cmd "${vm}" stop trysoft; done'



HOSTB08_SHUTDOWN=ssh 172.20.5.48 shutdown now
HOSTB17_SHUTDOWN=ssh 172.20.5.57 shutdown now
HOSTB18_SHUTDOWN=ssh 172.20.5.58 shutdown now


#Compute On
POWER_ON_GPU=ssh mgt01 /opt/xcat/bin/rpower gpu on
POWER_ON_PPN=ssh mgt01 /opt/xcat/bin/rpower ppn on
POWER_ON_HEAD=ssh mgt01 /opt/xcat/bin/rpower head on
POWER_ON_LOGIN=ssh mgt01 /opt/xcat/bin/rpower login on
NODE_LS=ssh mgt01 nodels > /root/power-failure/nodels.out
NODE_LIST_SCP=scp mgt01:/root/power-failure/nodels-'date "+%Y%m%d"'.out
POWER_AWAKE_CMC1=ssh mgt01 snmpset -v 1 -c community cmc1 .1.3.6.1.4.1.107.206.1.3.1.1.1.0 i 1
POWER_AWAKE_CMC2=ssh mgt01 snmpset -v 1 -c community cmc2 .1.3.6.1.4.1.107.206.1.3.1.1.1.0 i 1

##Function Definitions
function POWER_OFF_NODES
{
	$POWER_OFF_COMPUTE
	$POWER_OFF_PPN
	$POWER_OFF_GPU
	sleep 1m
	$POWER_ASLEEP_CMC1
	$POWER_ASLEEP_CMC2
	sleep 10s
	$QSTAT_CAPTURE
	sleep 5s
	$QSTAT_SCP
	sleep 5s
	$QSTAT_EMAIL
	$POWER_OFF_HEAD
	$POWER_OFF_LOGIN
}
function CONTINUE_SHUTDOWN
{
	SHUTDOWN_HP_GEAR
	sleep 30s
	SHUTDOWN_MO
	$BO_COMPUTE_EMAIL1
	sleep 10m
	$GPFS_SHUTDOWN_EMAIL1
	SHUTDOWN_GPFS_MO
	SHUTDOWN_GPFS_CLUSTER
	sleep 3m
	SHUTDOWN_STOR
	sleep 10s
	CHECK_POWER
	VMWARE_ESTATE
	}
function SHUTDOWN_HP_GEAR
{
	rpower dl001 off
	rpower dl002 off
	rpower dl003 off
	rpower dl004 off
	rpower dl005 off
	rpower dl006 off
	rpower dl007 off
	rpower dl008 off
	rpower dl009 off
	ssh dl010 /etc/init.d/ceph -a stop
	ssh dl011 /etc/init.d/ceph -a stop
	sleep 10s
	rpower dl010 off
	rpower dl011 off
}
function SHUTDOWN_MO
{
	$POWER_OFF_MO_COMPUTE
	$POWER_OFF_MO_LOGIN
	
}
function SHUTDOWN_GPFS_MO
{
	ssh momgt01 mmshutdown
}
function SHUTDOWN_GPFS_CLUSTER
{
	ssh mgt01 mmshutdown
}
function SHUTDOWN_STOR
{
	$POWER_OFF_CLUSTER_STOR
	$POWER_OFF_MO_STOR
}
function CHECK_POWER
{
	$CHECK_CLUSTER_POWER_STATUS
	$CHECK_MO_POWER_STATUS
}
function VMWARE_ESTATE
{
	$HOSTB08-VMWARE1_GUEST_SHUTDOWN
	$HOSTB17-VMWARE2_GUEST_SHUTDOWN
	$HOSTB18-VMWARE3_GUEST_SHUTDOWN
	

function POWER_ON
{
	POWER_ON_I_NODES
	POWER_ON_COMPUTE
}
function POWER_ON_I_NODES
{
	$POWER_ON_GPU
	$POWER_ON_PPN
	$POWER_ON_HEAD
	$POWER_ON_LOGIN
}

##Actual Script

#Email out to Admins Power Failure event has occurred
$FAIL1

sleep 2m

#2nd Email to Admins - cluster Power Off will occur in 1 minute
$FAIL2

sleep 1m

#Power Off the Compute nodes and Interactive nodes to run only mgt01
POWER_OFF_NODES
#Email Re Progress of Shutdown to admins
$PO_COMPUTE_EMAIL

CONTINUE_SHUTDOWN

echo "Do you wish to power the system back on?"
select yn in "Yes" "No"
case $yn in
    Yes ) POWER_ON;;
    No ) exit;;
esac
