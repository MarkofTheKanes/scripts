#!/usr/bin/bash
#******************************************************************************
# Title: genDailyBytestotalByAppAndSite-DummyData.sh
# Description: Generates daily dummy volume data values per App and Site for 
# loading to CCI Cassandra DB for the following metrics:
#
#		ibmaaf_bytestotal_by_cell_sitename
#		ibmaaf_bytestotal_by_application
#		
#		Sample output:
#		
#		imsi|timeid|ibmaaf_bytestotal_by_cell_sitename|ibmaaf_bytestotal_by_application|dt|sgm
#		272211221122000|20170601000000|{"metricId":"ibmaaf_bytestotal_by_cell_sitename","counters":[{"breakdown":"Belt Line Road","value":[3435.411]},{"breakdown":"Las Colinas","value":[2145.929]},{"breakdown":"Irving Valley","value":[1010.415]},{"breakdown":"Ranch","value":[971.923]},{"breakdown":"Market Center","value":[837.201]},{"breakdown":"West Dallas","value":[721.725]},{"breakdown":"Cockrell Hill","value":[500.396]}]}|{"metricId":"ibmaaf_bytestotal_by_application","counters":[{"breakdown":"Instagram","value":[137.777]},{"breakdown":"Youtube","value":[85.645]},{"breakdown":"Facebook","value":[50.833]},{"breakdown":"SnapChat","value":[43.785]},{"breakdown":"Google","value":[41.860]},{"breakdown":"Skype","value":[32.863]},{"breakdown":"WhatsApp Calls","value":[27.762]},{"breakdown":"WhatsApp","value":[27.426]},{"breakdown":"Twitter","value":[18.284]},{"breakdown":"Other","value":[14.916]}]}|201706010000|0
# 
#Improvements:
#
# Author: Mark O'Kane
# Date:25th May 2017
# Version: 1
# History:
#   Ver. 1 - 25th May 2017
# Comments:
# Dependencies: None
#******************************************************************************

clear
#Check command line arguments
if [ $# -ne 3 ]
then
	echo " "
	echo "Usage $0 [No. IMSis] [Start Date] [No. Days]"
	echo " "
	echo "- No. IMSIs: the number of IMSIs to generate the dummy data for."
	echo -e "- Start Date: the date the data should be generated in the format YYYYMMDDHHMMSS e.g. 20170601000000 = 1st June 2017 from 12 midnight"
	echo "- No. Days: the number of days to generate data for."
	echo -e "\ne.g. ./genDailyBytestotalByAppAndSite-DummyData.sh 2 20170601000000 20"
	echo " "
exit 2
fi

#*******************************************************************************************
# define configuration items
#*******************************************************************************************
# input params
num_imsis=$1
start_date=$2
num_days=$3

# Display user friendly start and end times
let end_date="$start_date + (($num_days -1) * 1000000)"
tmpStartDate=`exec date -d ${start_date:0:8}`
tmpEndDate=`exec date -d ${end_date:0:8}`

echo -e "Generating DAILY dummy data for:\n - for $num_imsis IMSI(s) \n - for $num_days day(s) \n - from: $tmpStartDate\n - to:   $tmpEndDate\n"

# set dt field as start_time less the last 2 digits as it covers days and hours only, not seconds like the start date field
dt_timestamp=${start_date:0:12}

# set debug value 1 = generate debug file
debugVal=0

## SITE ARRAYS
# Declare list of SITES to add daily data for
declare -a SITES_ARRAY
SITES_ARRAY=("Belt Line Road" "Las Colinas" "Irving Valley" "Ranch" "Market Center" "West Dallas" "Cockrell Hill")
# determine last index value of SITES_ARRAY. -1 used as index starts at 0
let SITES_ARRAY_last_index_val="${#SITES_ARRAY[@]}"
if [ "$debugVal" -eq 1 ] ;  then echo -e "\nLast SITES_ARRAY index value= $SITES_ARRAY_last_index_val" > debug.log; fi

## Declare daily volume in Mbs values for each SITEs
declare -a SITE_VOLUME_ARRAY
SITE_VOLUME_ARRAY=("3435.411" "2145.929" "1010.415" "971.923" "837.201" "721.725" "500.396" )

# determine last index value of SITE_VOLUME_ARRAY. -1 used as index starts at 0
let SITE_VOLUME_ARRAY_last_index_val="${#SITE_VOLUME_ARRAY[@]}"
if [ "$debugVal" -eq 1 ] ;  then echo -e "\nLast SITE_VOLUME_ARRAY index value= $SITE_VOLUME_ARRAY_last_index_val">> debug.log ; fi

# Check #sites matches the number of data volume entires
if [ $SITE_VOLUME_ARRAY_last_index_val -eq $SITE_VOLUME_ARRAY_last_index_val ]
then
	echo -e "\nNumber of sites vs. data volume entries is CORRECT"
else
	echo -e "\nNumber of sites vs. data volume entries is INCORRECT"
fi

## APPS ARRAYS
# Declare list of apps to add daily app data for
declare -a APPS_ARRAY
APPS_ARRAY=("Instagram" "Youtube" "Facebook" "SnapChat" "Google" "Skype" "WhatsApp Calls" "WhatsApp" "Twitter" "Other")
# determine last index value of APPS_ARRAY. -1 used as index starts at 0
let APPS_ARRAY_last_index_val="${#APPS_ARRAY[@]}"
if [ "$debugVal" -eq 1 ] ;  then echo -e "\nLast APPS_ARRAY index value= $APPS_ARRAY_last_index_val">> debug.log; fi

## Declare daily volume in Mbs values for each app
declare -a APP_VOLUME_ARRAY
APP_VOLUME_ARRAY=("137.777" "85.645" "50.833" "43.785" "41.860" "32.863" "27.762" "27.426" "18.284" "14.916")
# determine last index value of APP_VOLUME_ARRAY. -1 used as index starts at 0
let APP_VOLUME_ARRAY_last_index_val="${#APP_VOLUME_ARRAY[@]}"
if [ "$debugVal" -eq 1 ] ;  then echo -e "\nLast APP_VOLUME_ARRAY index value= $APP_VOLUME_ARRAY_last_index_val">> debug.log ; fi

# Check #apps matches the number of data volume entires
if [ $APP_VOLUME_ARRAY_last_index_val -eq $APP_VOLUME_ARRAY_last_index_val ]
then
	echo -e "Number of apps vs. data volume entries is CORRECT"
else
	echo -e "Number of apps vs. data volume entries is INCORRECT"
fi

if [ "$debugVal" -eq 1 ] ;  then echo -e "\nstart_date = $start_date\ndt_timestamp = $dt_timestamp" >> debug.log; fi

#*******************************************************************************************
# define functions
#*******************************************************************************************

## Backup old output file. Check if output file exists. If so, rename it with timestamp and create a new version with the header data in it
timestamp=`exec date +%y%m%d%H%M%S`

backup_old_files ()
# Check if output file exists. If so, rename it with timestamp and create a new version with the header data in it.
{
if [ -e DailyBytestotalByAppAndSite_DummyData.csv ]
then
	echo -e "\nRenaming old output file"
	mv DailyBytestotalByAppAndSite_DummyData.csv DailyBytestotalByAppAndSite_DummyData-${timestamp}.csv
	echo "imsi|timeid|ibmaaf_bytestotal_by_cell_sitename|ibmaaf_bytestotal_by_application|dt|sgm"  > DailyBytestotalByAppAndSite_DummyData.csv
else
	echo "imsi|timeid|ibmaaf_bytestotal_by_cell_sitename|ibmaaf_bytestotal_by_application|dt|sgm"  > DailyBytestotalByAppAndSite_DummyData.csv
fi

# remove old debug file
if [ "$debugVal" -eq 1 ]
then
	if [ -e debug.log ] 
	then 
		echo -e "\nDebug turned on.\n  Removing old debug.log file and creating new one"
		rm debug.log
		touch debug.log
	else
		echo -e "\nCreating new debug.log file"
		touch debug.log
	fi
else
	echo -e "\nDebug is not on."
fi
}

# Generate daily ByteTotalByAppAndSite dummy Data
gen_dummydata ()
{

imsi_start=272211221122000 # modify as needed if different IMSI start value needed
tmp_start_date=$start_date # needed so orignal start date can be used
tmp_dt_timestamp=$dt_timestamp # needed so orignal dt_timestamp can be used

if [ "$debugVal" -eq 1 ] ; then echo -e "\nStarting values:\n imsi start number= $imsi_start\n tmp start date = $tmp_start_date \n tmp dt timestamp = $tmp_dt_timestamp"; fi

# set SMG value - used to along with IMSI, start_date anddt_timestamp to generate a hash
smgVal=0

# set counters for use in loops
num_imsi_loop_count=0
num_apps_loop_count=0
# num_apps_vol_loop_count=0
num_sites_loop_count=0
# num_sites_vol_loop_count=0

if [ "$debugVal" -eq 1 ]; then echo -e "\nInitial loop counter settings:\n num_days_count = $num_days_count\n num_imsi_loop_count = $num_imsi_loop_count\n num_apps_loop_count = $num_apps_loop_count">> debug.log; fi

# (A) define the beginning entry for each IMSIs entry
line_start="$imsi_start|$tmp_start_date|{\"metricId\":\"ibmaaf_bytestotal_by_cell_sitename\",\"counters\":["
line_end="{\"metricId\":\"ibmaaf_bytestotal_by_application\",\"counters\":["
if [ "$debugVal" -eq 1 ]; then echo -e "\nLine beginning =$line_start \nLine end =$line_end">> debug.log; fi

# for each IMSI generate 1 line for all app entries
while [ $num_imsi_loop_count -lt $num_imsis ] 
do
	if [ "$debugVal" -eq 1 ] ;  then echo -e "\nLoop to generate entries for $num_imsis IMSIs:\n num_imsi_loop_count = $num_imsi_loop_count \n tmp_start_date=$tmp_start_date\n\n** GENERATING SITE AND VOLUME VALUES ENTRIES **" >> debug.log; fi	
	
	# (B) append sites+values fields to (A)
	for  (( num_sites_loop_count=0 ;  num_sites_loop_count < ${SITES_ARRAY_last_index_val}-1  ;  num_sites_loop_count++ ))
	do 	
		if [ "$debugVal" -eq 1 ] ;  then echo -e "\nAppending following site names and volume values to end of \"$imsi_start|$tmp_start_date|{\"metricId\":\"ibmaaf_bytestotal_by_cell_sitename\",\"counters\":[\":\n  num_sites_loop_count = $num_sites_loop_count \n  Site: ${SITES_ARRAY[$num_sites_loop_count]} \n  Site Daily Volume: ${SITE_VOLUME_ARRAY[$num_sites_loop_count]}">> debug.log; fi
		
		line_start=$line_start"{\"breakdown\":\"${SITES_ARRAY[$num_sites_loop_count]}\",\"value\":[${SITE_VOLUME_ARRAY[$num_sites_loop_count]}]},"
		if [ "$debugVal" -eq 1 ] ;  then echo -e "\nline_start now: $line_start">> debug.log; fi
	done
	
	# Add last site+value entry less the ","
	if [ "$debugVal" -eq 1 ] ;  then echo -e "\nAdding last site & value less the \",\" to the end of:\n = $line_start">> debug.log; fi	
	line_start=$line_start"{\"breakdown\":\"${SITES_ARRAY[$num_sites_loop_count]}\",\"value\":[${SITE_VOLUME_ARRAY[$num_sites_loop_count]}]}]}|"
	
	if [ "$debugVal" -eq 1 ] ;  then echo -e "\n** FINISHED APPENDING SITES+VALUES TO LINE START.** line start current= $line_start">> debug.log; fi	
	
	# append apps+values fields to (B) - details
	if [ "$debugVal" -eq 1 ] ;  then echo -e "\n\n** GENERATING APP AND VOLUME VALUES ENTRIES **">> debug.log; fi	
	
	for  (( num_apps_loop_count=0 ;  num_apps_loop_count < ${APPS_ARRAY_last_index_val}-1  ;  num_apps_loop_count++ ))
	do # create the single line daily entry for the IMSI by appending the app+value onto the end of the line for the number of apps less 1. The final app entry will occur outside of the loop so the last "," can be removed before the dt_timestamp and sgm value is appended to the end.
		
		if [ "$debugVal" -eq 1 ] ;  then echo -e "\nAppending following app names and volume values to end of \"$imsi_start|$tmp_start_date|{\"metricId\":\"ibmaaf_bytestotal_by_application\",\"counters\":[\":\n  num_apps_loop_count = $num_apps_loop_count \n  App: ${APPS_ARRAY[$num_apps_loop_count]} \n  Apps Daily Volume: ${APP_VOLUME_ARRAY[$num_apps_loop_count]}">> debug.log; fi
				
		line_end=$line_end"{\"breakdown\":\"${APPS_ARRAY[$num_apps_loop_count]}\",\"value\":[${APP_VOLUME_ARRAY[$num_apps_loop_count]}]},"
		if [ "$debugVal" -eq 1 ] ;  then echo -e "line_end now: $line_end">> debug.log; fi
	done
	
	# Add last app+value entry less the "," amd also adding dt_timestamp and sgm value at the end of the line
	if [ "$debugVal" -eq 1 ] ;  then echo -e "\nAdding last App & value less the \",\" to the end as well as dt_timestamp and smg values to end of:\n $line_end">> debug.log; fi
	line_end=$line_end"{\"breakdown\":\"${APPS_ARRAY[$num_apps_loop_count]}\",\"value\":[${APP_VOLUME_ARRAY[$num_apps_loop_count]}]}]}|$dt_timestamp|$smgVal"
	
	# Join the site and app entries together
	if [ "$debugVal" -eq 1 ] ;  then echo -e "\nJoining site and app entries + finishing fields to write them into the .csv file\n  line_start: $line_start\n  line_end: $line_end">> debug.log; fi
	
	# print the final entry into the .csv file
	joined_entry=${line_start}${line_end}
	echo $joined_entry >>DailyBytestotalByAppAndSite_DummyData.csv
	if [ "$debugVal" -eq 1 ] ;  then echo -e "\nFinal line entry: $joined_entry">> debug.log; fi
	
	# increment counters for next loop
	let "num_imsi_loop_count += 1"
	let "imsi_start += 1"
	
	# reset line_start value for next IMSI entry
	line_start="$imsi_start|$tmp_start_date|{\"metricId\":\"ibmaaf_bytestotal_by_cell_sitename\",\"counters\":["
	line_end="{\"metricId\":\"ibmaaf_bytestotal_by_application\",\"counters\":["
	if [ "$debugVal" -eq 1 ]; then echo -e "\nLine start reset to: $line_start \nLine end reset to: $line_end">> debug.log; fi
done
}

#******************************************************************************************
## end of defining functions
#******************************************************************************************
## backup old files first
backup_old_files

# Set variables to be used when calling the main function
num_days_count=0
#sqm_val=1 #SQM will be incremented from 1 up to the number of days the data is to be generated for. It is a hash function of IMSI it groups data into bucket-like partitions.

# Generate Daily Dummy Data Set
while [ $num_days_count -lt $num_days ] # run a loop to generate stats for each day
do # for each hour, generate an volme entry to the IMSI for each app
	let "tmpDayCount=$num_days_count+1"
	if [ "$debugVal" -eq 1 ] ;  then echo -e "\nGenerating volume data for each day for each IMSI for each app for day: $tmpDayCount">> debug.log; fi
	gen_dummydata
	let "num_days_count += 1"
	# let "sqm_val += 1"
	let "start_date=$start_date+1000000"
	let "dt_timestamp=$dt_timestamp+10000"
done

echo -e "\n***** Generation of dummy daily BytesTotal Data per APP and site per day finished **********"