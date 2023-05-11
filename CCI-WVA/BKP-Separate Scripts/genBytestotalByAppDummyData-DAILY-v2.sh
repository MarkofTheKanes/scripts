#!/usr/bin/bash
#******************************************************************************
# Title: genBytestotalByAppDummyData-DAILY.sh
# Description:  used to generate daily dummy volume data values per App for loading to CCI Cassandra DB  for the following metric - 1 entry per APP per day
#
#		ibmaaf_bytestotal_by_application
#		OUTPUT FORMAT
# 		imsi|timeid|ibmaaf_bytestotal_by_application|dt|sgm        
#		000000000000000|20161117000000|{"metricId":"ibmaaf_bytestotal_by_application" counters:[{"breakdown":"DNS"
#      value:[188]}]}|201611170000|61
#
#Improvements:
# 1 - read in list of Apps from external data source into a APPS_ARRAY
# 2 - read in per app data volume values from external source into APP_VOLUME_ARRAY
#
# Author: Mark O'Kane
# Date:23rd May 2017
# Version: 2.0
# History:
#   Ver. 1.0 - 16th May 2017
#   Ver. 2 - 23rd May - moved array declaration outside of loop
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
	echo -e "\ne.g. ./genBytestotalByAppDummyData-DAILY.sh 3 20170601000000 20"
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

echo -e "\nGenerating DAILY dummy data for:\n - for:  $num_imsis IMSI(s) \n - for $num_days days \n - from: $tmpStartDate\n - to:   $tmpEndDate\n"

# set dt field as start_time less the last 2 digits as it covers days and hours only, not seconds like the start date field
dt_timestamp=${start_date:0:12}

debugVal=0

## Declare list of apps to add daily app data for
declare -a APPS_ARRAY
APPS_ARRAY=("Instagram" "Youtube" "Facebook" "SnapChat" "Google" "Skype" "WhatsApp Calls" "WhatsApp" "Twitter" "Other")
# determine last index value of APPS_ARRAY. -1 used as index starts at 0
let APPS_ARRAY_last_index_val="${#APPS_ARRAY[@]}"
if [ "$debugVal" -eq 1 ] ;  then echo -e "\nLast APPS_ARRAY index value= $APPS_ARRAY_last_index_val"; fi

## Declare daily volume in Mbs values for each app
declare -a APP_VOLUME_ARRAY
APP_VOLUME_ARRAY=("137.777" "85.645" "50.833" "43.785" "41.860" "32.863" "27.762" "27.426" "18.284" "14.916")
# determine last index value of APP_VOLUME_ARRAY. -1 used as index starts at 0
let APP_VOLUME_ARRAY_last_index_val="${#APP_VOLUME_ARRAY[@]}"
if [ "$debugVal" -eq 1 ] ;  then echo -e "\nLast APP_VOLUME_ARRAY index value= $APP_VOLUME_ARRAY_last_index_val" ; fi

# Check #apps matches the number of data volume entires

if [ $APP_VOLUME_ARRAY_last_index_val -eq $APP_VOLUME_ARRAY_last_index_val ]
then
	echo -e "\nNumber of apps vs. data volume entries is CORRECT"
else
	echo -e "\nNumber of apps vs. data volume entries is INCORRECT"
fi

if [ "$debugVal" -eq 1 ] ;  then echo -e "\nstart_date = $start_date\ndt_timestamp = $dt_timestamp"; fi

#*******************************************************************************************
# define functions
#*******************************************************************************************

## Backup old output file. Check if output file exists. If so, rename it with timestamp and create a new version with the header data in it
timestamp=`exec date +%y%m%d%H%M%S`

backup_old_files ()
# Check if output file exists. If so, rename it with timestamp and create a new version with the header data in it.
{
if [ -e BytestotalByApp_DummyData-DAILY.csv ]
then
	echo -e "\nRenaming old output file"
	mv BytestotalByApp_DummyData-DAILY.csv BytestotalByApp_DummyData-DAILY-${timestamp}.csv
	echo "imsi|timeid|ibmaaf_bytestotal_by_application|dt|sgm"  > BytestotalByApp_DummyData-DAILY.csv
else
	echo "imsi|timeid|ibmaaf_bytestotal_by_application|dt|sgm"  > BytestotalByApp_DummyData-DAILY.csv
fi
}

# Generate ByteTotalByApp dummy Data
gen_dummydata ()
{

imsi_start=272211221122000 # modify as needed if different IMSI start value needed
tmp_start_date=$start_date # needed so orignal start date can be used
tmp_dt_timestamp=$dt_timestamp # needed so orignal dt_timestamp can be used

if [ "$debugVal" -eq 1 ] ;  then echo -e "\nimsi start number= $imsi_start\ntmp start date = $tmp_start_date \ntmp dt timestamp = $tmp_dt_timestamp"; fi

# set counters for use in loops
num_imsi_loop_count=0
num_apps_loop_count=0
num_apps_vol_loop_count=0

if [ "$debugVal" -eq 1 ]; then echo -e "\nnum_days_count = $num_days_count\nnum_imsi_loop_count = $num_imsi_loop_count\nnum_apps_vol_loop_count = $num_apps_vol_loop_count"; fi

# for each IMSI generate 1 daily value for each of the application
while [ $num_imsi_loop_count -lt $num_imsis ] 
do
	if [ "$debugVal" -eq 1 ] ;  then echo -e "\nRUNNING LOOP TO CALL DATA GENERATION LOOP BASED ON # APPS\nnum_imsi_loop_count = $num_imsi_loop_count \ntmp_start_date=$tmp_start_date"; fi
	for  (( num_apps_loop_count=0 ;  num_apps_loop_count < $APPS_ARRAY_last_index_val  ;  num_apps_loop_count++ ))
	do # generate volume values for each app per hour
		if [ "$debugVal" -eq 1 ] ;  then echo -e "RUNNING LOOP TO GENERATE THE DATA INTO .CSV FILE\n num_apps_loop_count = $num_apps_loop_count \n App: ${APPS_ARRAY[$num_apps_loop_count]} \nApp Daily Volume: ${APP_VOLUME_ARRAY[$num_apps_loop_count]}"; fi
		echo "$imsi_start|$tmp_start_date|{\"metricId\":\"ibmaaf_bytestotal_by_application\" counters:[{\"breakdown\":\"${APPS_ARRAY[$num_apps_loop_count]}\" value:[${APP_VOLUME_ARRAY[$num_apps_loop_count]}]}]}|$dt_timestamp|$sqm_val"	>> BytestotalByApp_DummyData-DAILY.csv
	done
	let "num_imsi_loop_count += 1"
	let "imsi_start += 1"	
done
}

#******************************************************************************************
## end of defining functions
#******************************************************************************************
## backup old files first
backup_old_files

# Set variables to be used when calling the main function
num_days_count=0
sqm_val=1 #SQM will be incremented from 1 up to the number of days the data is to be generated for. It is a hash function of IMSI it groups data into bucket-like partitions.

# Generate Daily Dummy Data Set
while [ $num_days_count -lt $num_days ] # run a loop to generate stats for each day
do # for each hour, generate an volme entry to the IMSI for each app
	let "tmpDayCount=$num_days_count+1"
	if [ "$debugVal" -eq 1 ] ;  then echo -e "\nGenerating volume data for each day for each IMSI for each app for day: $tmpDayCount"; fi
	gen_dummydata
	let "num_days_count += 1"
	let "sqm_val += 1"
	let "start_date=$start_date+1000000"
	let "dt_timestamp=$dt_timestamp+10000"
done

echo -e "\n***** Generation of dummy daily BytesTotal Data per APP per day finished **********"
