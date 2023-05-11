#!/bin/bash -x

#******************************************************************************
# Title: check_processes.sh
# Description: remotely checks that processess are still running on a server.
#        and emails a warning when a process is not running
#        It takes input from a file "processes", parses the host and proccesses
#        to be checked and then checks if they are still running. A list of the
#        expected no. of processes is kept for referencing
#        The "processes" input file should be in the format:
#
#        <host>+<process_name1>+<process_name2>+<process_name3>+END
#        e.g. magellan+smtpd+imsd+ldapconn+END
#
#        NOTE: The "END" must be at the end of the string for the script to work.
# Author: Mark O'Kane
# Date: 13th Feb 2003
# Version: 1.0
# Location: /cvsroot/www/pe/qa/syststing/Carrier/4.0/Monitoring/Processes
# History:
#   Ver. 1.0 - created 13th Feb 2003
# Comments:
# Dependencies: $BIN_HOME must be defined to point to the smtptst binary
#         The remote hosts must be configured to allow rsh access for user root
#         The script must be executed by user root
#******************************************************************************

for lines in $( cat processes )
do
	# parse host name and processes to check for
	host=`echo $lines | cut -f1 -d"+"`

	# parse processes to check for and write them to an array
	count=2
	element_count=0
	while [ 1 ]
	do
		process=`echo $lines | cut -f$count -d"+"`
		if [ "$process" == "END" ]
		then
			break
		else
			process_name_array[$element_count]=$process
		fi

		let "count += 1"
		let "element_count += 1"
	done

	# create an email message file with headers
	if [ -e msg.0 ]
	then
		rm msg.0
	fi

	# comprise header for warning email
	echo "From: Process check on $host" > msg.0
	echo "Subject: *** WARNING *** process failure on \"$host\"!!!" >> msg.0
	echo "" >> msg.0
	echo "_________________________________________________________________________" >> msg.0
	echo "" >> msg.0

	# some useful info
	timestamp1=`exec date +20%y-%m-%d`
	timestamp2=`exec date +%H:%M:%S`

	# grep for each process in the log file
	count=0
	element_count=${#process_name_array[*]}
	# used to determine if email should be sent or not
	process_found_flag=0

	# check for each process type
	while [ $count -lt $element_count ]
	do
		# check if the process is running.  If not running, add a warning to the
		# msg.0 file and email it when all processes have been checked
		#`rsh $host "ps -ef | grep -ic ${process_name_array[$count]} | grep -v grep 2>/dev/null"`
		grep_count=`rsh $host ps -ef | grep -ic ${process_name_array[$count]} | grep -v grep`
		if [ $grep_count -lt 1 ]
		then
			echo "\"${process_name_array[$count]}\" on host \"$host\" has stopped on \"$timestamp1\" at \"$timestamp2\"" >> msg.0
			process_found_flag=1
		fi
		let "count += 1"
	done


	# Email if an process is found
	if [ $process_found_flag -eq 1 ]
	then
		sleep 3
		echo "" >> msg.0
		echo "_________________________________________________________________________" >> msg.0
		#$BIN_HOME/smtptst -spuma.dub0.ie.cp.netf\'logcheck@cp.net\'r\'deniz.susar@cp.net\'S0Q
		$BIN_HOME/smtptst -spuma.dub0.ie.cp.net f\'logcheck@cp.net\'r\'mark.okane@cp.net\'S0Q
	fi

done

exit 0
