#!/bin/bash

# script to check the number of users provisioned in a domain on a DS
# name: check_prov_users.sh
# location: CVS - www/pe/qa/syststing/Carrier/4.0/Provisioning/DS

domain_check=$1

##################################################################################

if [ $# -ne 1 ]
then
        echo " "
        echo "Usage $0 [Domain to check no. of users on] " 
        echo " "
        exit 2
fi

###################################################################################

if [ -e number_of_users.out ]
then
	echo "Deleting existing file"
	rm number_of_users.out
fi


start_time=`date`
timestamp=`exec date +%y%m%d%H%M%S`
logfile=total_no_users_${domain_check}

echo "start time= $start_time" | tee -a $logfile

echo "Getting dsa details"
odslist | grep $domain_check | grep users[0-9]*  | grep -v mail_ | tee number_of_users.out

echo "Domain $domain_check has the following users configured:"
grep -c user number_of_users.out | tee -a $logfile

echo "Check $logfile for all results"
