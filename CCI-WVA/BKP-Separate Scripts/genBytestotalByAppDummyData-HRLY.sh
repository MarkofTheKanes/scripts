#!/usr/bin/bash
#******************************************************************************
# Title: genBytestotalByAppDummyData.sh
# Description:  used to generate dummy data for loading to CCI Cassandra DB  for the following metric:
#		ibmaaf_bytestotal_by_application
#		OUTPUT FORMAT
# 		imsi|timeid|ibmaaf_bytestotal_by_application|dt|sgm        
#		000000000000000|20161117000000|{"metricId":"ibmaaf_bytestotal_by_application" counters:[{"breakdown":"DNS"
#      value:[188]}]}|201611170000|61
#
# multiple lines per IMSI -
# Author: Mark O'Kane
# Date: 16th May 2017
# Version: 1.0
# History:
#   Ver. 1.0 - 16th May 2017
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
	echo -e "- Start Date: Date the data should be generated from \n     format yyyymmddhhmmss e.g. 20170601000000 = 1st June 2017 from 12 midnight"
	echo "- No. Days: the number of days to generate data for."
	echo -e "\ne.g. ./genBytestotalByAppDummyData.sh 3 20170601000000 20"
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

echo -e "\nGenerating dummy data for:
- for:  $num_imsis IMSIs 
- from: $tmpStartDate 
- to:   $tmpEndDate\n"

# set dt field as start_time less the last 2 digits as it covers days and hours only, not seconds like the start date field
dt_timestamp=${start_date:0:12}

debugVal=1

if [ $debugVal -eq 1 ]
	then
		echo -e "\n"
		echo "start_date = $start_date"
		echo "dt = $dt_timestamp"
		echo -e "\n"
fi

#*******************************************************************************************
# define functions
#*******************************************************************************************

## Backup old output file
# define timestamp format to be used to rename existing output files
timestamp=`exec date +%y%m%d%H%M%S`

backup_old_files ()
# Check if output file exists. If so, rename it with timestamp and create a new version with the header data in it.
{
if [ -e BytestotalByApp_DummyData.csv ]
then
	echo -e "\nRenaming old output file"
	mv BytestotalByApp_DummyData.csv BytestotalByApp_DummyData-${timestamp}.csv
	echo "imsi|timeid|ibmaaf_bytestotal_by_application|dt|sgm"  > BytestotalByApp_DummyData.csv
else
	echo "imsi|timeid|ibmaaf_bytestotal_by_application|dt|sgm"  > BytestotalByApp_DummyData.csv
fi
}

# Generate ByteTotalByApp dummy Data
gen_dummydata ()
{

## Declare list of apps to add hourly data for
declare -a APPS_ARRAY
APPS_ARRAY=("Instagram" "Facebook" "Google Video" "WhatsApp" "Pandora")
# determine last index value of APPS_ARRAY. -1 used as index starts at 0
let APPS_ARRAY_last_index_val="${#APPS_ARRAY[@]}"
echo -e "last APPS_ARRAY index value= $APPS_ARRAY_last_index_val"

## Declare volume values for Instagram
declare -a INST_ARRAY_VOLUME
INST_ARRAY_VOLUME=("Instagram" "Facebook" "Google Video" "WhatsApp" "Pandora")
# determine last index value of INST_ARRAY_VOLUME. -1 used as index starts at 0
let INST_ARRAY_VOLUME_last_index_val="${#INST_ARRAY_VOLUME[@]}"
echo -e "last INST_ARRAY_VOLUME index value= $INST_ARRAY_VOLUME_last_index_val"

#### repeat for other apps

imsi_start=2712211221122000
echo "imsi_start = $imsi_start"
tmp_start_date=$start_date # needed so orignal start date can be used
echo "tmp start date = $tmp_start_date"
tmp_dt_timestamp=$dt_timestamp # needed so orignal dt_timestamp can be used
echo "tmp dt timestamp = $tmp_dt_timestamp"

# set counters for use in loops
num_imsi_loop_count=0
num_hrs_loop_count=0
num_apps_loop_count=0
hrs_per_day=24

# input params
# num_imsis=$1
# start_date=$2
# num_days=$3
# end_date
# dt_timestamp

if [ $debugVal -eq 1 ]
	then
		echo -e "\n"
		echo "num_days_count = $num_days_count"
		echo "num_imsi_loop_count = $num_imsi_loop_count"
		echo "num_hrs_loop_count = $num_hrs_loop_count"
		echo "num_hrs_loop_count = $num_hrs_loop_count"
		echo "hrs_per_day = $hrs_per_day"
		echo -e "\n"
fi

# for each day generate 24 hourly values for each of the 5 application for each IMSI
while [ $num_imsi_loop_count -lt $num_imsis ] # run a loop to generate stats for all IMSIs per 24 hour period
do # for each hour, generate an volme entry to the IMSI for each app
	echo -e "\nnum_imsi_loop_count = $num_imsi_loop_count"
	echo -e "imsi_start = $imsi_start"
		for (( num_hrs_loop_count =0 ;  num_hrs_loop_count < $hrs_per_day  ;  num_hrs_loop_count++ ))
		do
			echo -e "\nnum_hrs_loop_count = $num_hrs_loop_count"
			echo "tmp_start_date=$tmp_start_date"
			echo "tmp_dt_timestamp=$tmp_dt_timestamp"
			for  (( num_apps_loop_count=0 ;  num_apps_loop_count < $APPS_ARRAY_last_index_val  ;  num_apps_loop_count++ ))
			do # generate volume values for each app per hour
				echo -e "num_apps_loop_count = $num_apps_loop_count"
				echo -e "${APPS_ARRAY[$num_apps_loop_count]}"
				echo "$imsi_start|$tmp_start_date|{\"metricId\":\"ibmaaf_bytestotal_by_application\" counters:[{\"breakdown\":\"${APPS_ARRAY[$num_apps_loop_count]}\" value:[XXXX]}]}|$tmp_dt_timestamp|SGM"	>> BytestotalByApp_DummyData.csv
				
				# format: 000000000000000|20161117000000|{"metricId":"ibmaaf_bytestotal_by_application"	counters:[{"breakdown":"DNS"	value:[188]}]}|201611170000|61
				# $imsi_start|$start_date|{"metricId":"ibmaaf_bytestotal_by_application"	counters:[{"breakdown":"${APPS_array[$random_di_prof_array_val]"	value:[XXXX]}]}|$dt_timestamp|$SGM
				
				# echo "$imsi_start|$start_date|{\"metricId\":\"ibmaaf_bytestotal_by_application\" counters:[{\"breakdown\":\"${APPS_ARRAY[$num_apps_loop_count]}\" value:[XXXX]}]}|$dt_timestamp|SGM"	>> BytestotalByApp_DummyData.csv
			done # end of generating per hour app stats for 24 hrs
		let "tmp_start_date=$tmp_start_date+10000" # move to the next hour
		let "tmp_dt_timestamp=$tmp_dt_timestamp+100" # move to the next hour
		if [ $num_hrs_loop_count -eq 23 ]
					then
						tmp_start_date=$start_date # resetting start date to original for generation of second IMSI values
						tmp_dt_timestamp=$dt_timestamp # resetting dt timestamp to original for generation of second IMSI values
				fi
		# echo "updated_start_date = $tmp_start_date"
		done # end of num imsis
	let "num_imsi_loop_count += 1"
	let "imsi_start += 1"	
done # end of number of days count
	
	
	# done # end of inner loop	
	#echo -e "starting $imsi_count of outside loop"
#	echo  "days_count= $days_count"
	# echo "$imsi_start|$start_date|{\"metricId\":\"ibmaaf_bytestotal_by_application\" counters:[{\"breakdown\":\"APP\" value:[XXXX]}]}|$dt_timestamp|$SGM">> BytestotalByApp_DummyData.csv
}

#******************************************************************************************
## end of defining functions
#******************************************************************************************
## backup old files first
backup_old_files

num_days_count=0
# Generate Profile Data Set
while [ $num_days_count -lt $num_days ] # run a loop to generate stats for each day
do # for each hour, generate an volme entry to the IMSI for each app
	let "tmpDayCount=$num_days_count+1"
	echo -e "\nDAY $tmpDayCount"
	gen_dummydata
	let "num_days_count += 1"
	let "start_date=$start_date+1000000"
	let "dt_timestamp=$dt_timestamp+10000"
done

echo -e "\n***** FINISHED**********"
