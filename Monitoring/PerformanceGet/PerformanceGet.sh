#!/bin/sh
 
MGR=$CP/global/bin/mgr

if [ $# -ne 2 ]
then
		echo "Usage $0 [hostname] [password] "
		echo " "
		exit 2
fi

timestamp=`date '+%d-%m-%y_%H-%M'`
echo $timestamp
server=$1
password=$2

logdir=$LOG_DIR
 
echo ------------------------------------------------------------------------------------------------------- >> $logdir/$server.log
date >> $logdir/$server_$timestamp.log
echo
$MGR -s $server -p 4200 -r $password PERFORMANCE GET >> $logdir/${server}_${timestamp}.log
sleep 2
$MGR -s $server -p 4201 -r $password PERFORMANCE GET >> $logdir/${server}_${timestamp}.log
