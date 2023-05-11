#!/bin/bash

# script to get component version details

#*******************************************************************************************
# remove previous output file.
#*******************************************************************************************

if [ -e component_versions.out ]; then
	rm component_versions.out
	echo "Removing old component_versions.out file."
	echo ""
fi

export BIN_HOME=/home/sfindlay/bin

#*******************************************************************************************
# define configuration items
#*******************************************************************************************

## MS Servers
ms_host1=gould
ms_port1=4200
ms_pwd1=p

ms_host2=milligan
ms_port2=4200
ms_pwd2=p

smtpR_host1=emssun5
smtpR_port1=4214
smtpR_pwd1=password

loginP_host1=emssun5
loginP_port1=4207
loginP_pwd1=password

## CAL Servers
cal_host1=host00
cal_port1=5230
cal_pwd1=password

cal_host2=host01
cal_port2=5230
cal_pwd2=password

cproxy_host1=atari
cproxy_port1=5230
cproxy_pwd1=password

## PABS Servers
pabs_host1=host00
pabs_port1=4211
pabs_pwd1=password

pabs_host2=host01
pabs_port2=4211
pabs_pwd2=password

pproxy_host1=atari
pproxy_port1=4211
pproxy_pwd1=password

## IFS Servers
ifs_host1=apollo
ifs_port1=4621
ifs_pwd1=admin

## NS Servers
ns_host1=apollo
ns_port1=4210
ns_pwd1=p

nsproxy_host1=emssun5
nsproxy_port1=4210
nsproxy_pwd1=password

## Sync Servers
sync_host1=magellan
sync_port1=4221
sync_pwd1=password

#*******************************************************************************************
# get component version numbers.
#*******************************************************************************************

## MS
echo ""  | tee -a component_versions.out
echo "MS Component Versions..."  | tee -a component_versions.out
$BIN_HOME/mgre -s $ms_host1 -p $ms_port1 -w $ms_pwd1 "INFO" | tee -a component_versions.out
$BIN_HOME/mgre -s $ms_host2 -p $ms_port2 -w $ms_pwd2 "INFO" | tee -a component_versions.out

echo ""  | tee -a component_versions.out
echo "SMTP Relay Component Versions..."  | tee -a component_versions.out
$BIN_HOME/mgre -s $smtpR_host1 -p $smtpR_port1 -w $smtpR_pwd1 "INFO" | tee -a component_versions.out

echo ""  | tee -a component_versions.out
echo "Login Proxy Component Versions..."  | tee -a component_versions.out
$BIN_HOME/mgre -s $loginP_host1 -p $loginP_port1 -w $loginP_pwd1 "INFO" | tee -a component_versions.out


## CAL
echo ""  | tee -a component_versions.out
echo "CAL Component Versions..."  | tee -a component_versions.out
$BIN_HOME/mgre -s $cal_host1 -p $cal_port1 -w $cal_pwd1 "INFO" | tee -a component_versions.out
$BIN_HOME/mgre -s $cal_host2 -p $cal_port2 -w $cal_pwd2 "INFO" | tee -a component_versions.out

echo ""  | tee -a component_versions.out
echo "CAL Proxy Versions..."  | tee -a component_versions.out
$BIN_HOME/mgre -s $cproxy_host1 -p $cproxy_port1 -w $cproxy_pwd1 "INFO" | tee -a component_versions.out


## PABS
echo ""  | tee -a component_versions.out
echo "PABS Component Versions..."  | tee -a component_versions.out
$BIN_HOME/mgre -s $pabs_host1 -p $pabs_port1 -w $pabs_pwd1 "INFO" | tee -a component_versions.out
$BIN_HOME/mgre -s $pabs_host2 -p $pabs_port2 -w $pabs_pwd2 "INFO" | tee -a component_versions.out

echo ""  | tee -a component_versions.out
echo "PABS Proxy Versions..."  | tee -a component_versions.out
$BIN_HOME/mgre -s $pproxy_host1 -p $pproxy_port1 -w $pproxy_pwd1 "INFO" | tee -a component_versions.out


## IFS
echo ""  | tee -a component_versions.out
echo "IFS Component Versions..."  | tee -a component_versions.out
$BIN_HOME/mgre -s $ifs_host1 -p $ifs_port1 -w $ifs_pwd1 "INFO" | tee -a component_versions.out


## NS
echo ""  | tee -a component_versions.out
echo "NS Component Versions..."  | tee -a component_versions.out
$BIN_HOME/mgre -s $ns_host1 -p $ns_port1 -w $ns_pwd1 "INFO" | tee -a component_versions.out

echo ""  | tee -a component_versions.out
echo "NS Proxy Component Versions..."  | tee -a component_versions.out
$BIN_HOME/mgre -s $nsproxy_host1 -p $nsproxy_port1 -w $nsproxy_pwd1 "INFO" | tee -a component_versions.out


## SyncML
echo ""  | tee -a component_versions.out
echo "SyncML Component Versions..."  | tee -a component_versions.out
$BIN_HOME/mgre -s $sync_host1 -p $sync_port1 -w $sync_pwd1 "INFO" | tee -a component_versions.out

exit 1
