#!/bin/bash

#******************************************************************************
# Title: monitor_logs.sh
# Description: remotely monitors files for specified info and sends an email
#        if it is found.
#        It takes input from a file "logs", parses the host, log dir, log file
#        and errors to be monitored and then checks if these errors have occurred
#        in the relevant log files by comparing the count from the previous run
#        (stored in a file) and if the number have increased, an email is sent.
#        The "logs" input file should be in the format:
#
#        <host>+<log_dir>+<log_file>+<error1>+<error2>+<error3>+END
#        e.g. magellan+/home/mokane+mylog+fatal+recoverable+info+END
#
#        NOTE: The "END" must be at the end of the string for the script to work.
# Author: Mark O'Kane
# Date: 13th Feb 2003
# Version: 1.0
# Location: /cvsroot/www/pe/qa/syststing/Carrier/4.0/Monitoring/Logs
# History:
#   Ver. 1.0 - created 13th Feb 2003
# Comments:
# Dependencies: $BIN_HOME must be defined to point to the smtptst binary
#         The remote hosts must be configured to allow rsh access for user root
#         The script must be executed by user root
# To Do: Enable the grep return the actual errors generated vs just a warning
#        if the error has occurred.
#******************************************************************************

for lines in $( cat logs )
do
	# parse host name, log directory, logfile and errors to monitor
	host=`echo $lines | cut -f1 -d"+"`
	log_dir=`echo $lines | cut -f2 -d"+"`
	log_file=`echo $lines | cut -f3 -d"+"`

	# parse errors to monitor for and write them to an array
	count=4
	element_count=0
	while [ 1 ]
	do
		error=`echo $lines | cut -f$count -d"+"`
		if [ "$error" == "END" ]
		then
			break
		else
			error_array[$element_count]=$error
		fi

		let "count += 1"
		let "element_count += 1"
	done

	# create store file to hold a count of each errors found to date so
	# warnings are not emailed if they're found again
	store_error_logfile=${host}_${log_file}_store.out
	`touch $store_error_logfile`

	# create an email message file with headers
	if [ -e msg.0 ]
	then
		rm msg.0
	fi

	# comprise header for warning email
	echo "From: Log Monitor on $host" > msg.0
	echo "Subject: *** WARNING *** Errors found in \"$log_file\" on \"$host\"!!!" >> msg.0
	echo "" >> msg.0
	echo "_________________________________________________________________________" >> msg.0
	echo "" >> msg.0

	# some useful info
	timestamp1=`exec date +20%y-%m-%d`
	timestamp2=`exec date +%H:%M:%S`

	# grep for each error in the log file
	count=0
	element_count=${#error_array[*]}
	# used to determine if email should be sent or not
	error_found_flag=0

	# check for each error type
	while [ $count -lt $element_count ]
	do
		# get a count of the number of times the error has occurred in the log file
		grep_count=`rsh $host grep -ic ${error_array[$count]} ${log_dir}/${log_file}`

		# if the error already exists in the store file, check if the no. of errors has changed
		existing_error_count=0
		# first check if the error already exists in the store file
		check_exists=`grep -ic ${error_array[$count]} $store_error_logfile`
		if [ "$check_exists" -gt 0 ]
		then
			existing_error_count=`grep -i "${error_array[$count]}" $store_error_logfile | cut -f2 -d" "`
		fi

		# next compare the new count with the old count.  If changed, add a message to the
		# msg.0 file for emailing and update the temporary store file
		# if not changed, add the existing error count to the temporary store file
		if [ "$grep_count" -gt "$existing_error_count" ]
		then
			let diff_erence="$grep_count - $existing_error_count"
			echo "$diff_erence new occurrences of the \"${error_array[$count]}\" error have been found on host \"$host\" in \"${log_dir}/${log_file}\" on \"$timestamp1\" at \"$timestamp2\"" >> msg.0
			echo "${error_array[$count]} $grep_count" >>tmp_$store_error_logfile
			error_found_flag=1
		else
			echo "${error_array[$count]} $existing_error_count" >>tmp_$store_error_logfile
		fi
		let "count += 1"
	done

	# After all errors have been checked, remove the old store file and replace with new
	# updated store file
	if [ -e tmp_$store_error_logfile ]
	then
		`rm $store_error_logfile`
		`mv tmp_$store_error_logfile $store_error_logfile`
	fi

	# Email if an error is found
	if [ $error_found_flag -eq 1 ]
	then
		sleep 3
		echo "" >> msg.0
		echo "_________________________________________________________________________" >> msg.0
		#$BIN_HOME/smtptst -spuma.dub0.ie.cp.netf\'logmonitor@cp.net\'r\'deniz.susar@cp.net\'S0Q
		$BIN_HOME/smtptst -spuma.dub0.ie.cp.net f\'logmonitor@cp.net\'r\'mark.okane@cp.net\'S0Q
	fi

done

exit 0
