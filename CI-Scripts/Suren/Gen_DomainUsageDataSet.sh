#!/usr/bin/bash
#******************************************************************************
# Title: Gen_DomainUsageDataSet.sh
# Description:  used to generate the dataset for Domain Usage in the following sample format
#		DATE|IMSI|DOMAIN|WEIGHTING
#		FEBRUARY 2016|123456700000001|news.bbc.com|68
#		FEBRUARY 2016|123456700000001|citibank.com|31
#		FEBRUARY 2016|123456700000001|golf.skysports.com|5
#		FEBRUARY 2016|123456700000001|newyorktimes.com|41
#		FEBRUARY 2016|123456700000001|time.com|85
# multiple lines per IMSI - mix of domain interests
# Author: Mark O'Kane
# Date: 13th Oct 2016
# Version: 1.0
# History:
#   Ver. 1.0 - 13th Oct 2016
# Comments:
# Dependencies: None
#******************************************************************************

#Check command line arguments
if [ $# -ne 5 ]
then
	echo " "
	echo "Usage $0 [Month] [Year] [#IMSIs] [IMSI Start number] "
	echo " "
	echo "    - Month: Month for which profile data to be generated e.g. FEBRUARY"
	echo "    - Year: Year for which profile data to be generated e.g. 2016"
	echo "    - #IMSIs: number of IMSIs to generate entries for"
	echo "    - IMSI Start number: number at which to start IMSI from e.g. 123456700000000"
	echo "    - No. entries per IMSI: number of domaisn entries to be created per IMIS e.g. 5"
	echo -e "\n    e.g. ./Gen_ProfileData.sh FEBRURARY 2016 10000 123456700000000 5"
	echo " "
exit 2
fi

#*******************************************************************************************
# define configuration items
#*******************************************************************************************

# set debug print out 0 = off, 1 = on
# to be done later debug_on=0

# input params
profile_month=$1
profile_year=$2
num_imsis=$3
imsi_val_start=$4
num_entries_per_imsi=$5

let finish_at="$imsi_val_start + $num_imsis"

#*******************************************************************************************
# define functions
#*******************************************************************************************

# Generate Domain Usage Profile Data Set

gen_profile_data ()
{
echo -e "\n\nGenerating Domain Usage Profile Data Set for :
- $num_imsis IMSIs starting number @ $imsi_val_start 
- for the date $profile_month $profile_year
- with $num_entries_per_imsi domains per IMSI\n"

# define timestamp format to be used to rename existing output files
timestamp=`exec date +%y%m%d%H%M%S`

# Check if output file exists. If so, rename it with timestamp and create a new version with the header data in it.

if [ -e DomainUsageDataSet.out ]
then
	echo -e "\nRenaming old dataset file\n"
	mv DomainUsageDataSet.out DomainUsageDataSet-${timestamp}.out
	echo "DATE|IMSI|DOMAIN|WEIGHTING"  > DomainUsageDataSet.out
else
	echo "DATE|IMSI|DOMAIN|WEIGHTING"  > DomainUsageDataSet.out
fi

# Declare Domain Interests Array to be used to assign random interests to each IMSI
declare -a DI_ARRAY
DI_ARRAY=("news.bbc.com" "citibank.com" "golf.skysports.com" "newyorktimes.com" "time.com" "easyodds.com" "youtube.com" "newscientist.com" "barnesandnoble.com" "twitter.com" "sport.cnn.com" "facebook.com")

# determine last index value of DI_ARRAY - reuqired to generate randon domains for each IMSI. -1 used as index starts at 0
let di_array_last_index_val="${#DI_ARRAY[@]}-1"
echo -e "last DI_ARRAY index value= $di_array_last_index_val"

## create profile data set
# set counters
imsi_count=$imsi_val_start
echo "imsi count = $imsi_count"

num_entries_per_imsi_count=0
echo "num imsi count = $num_entries_per_imsi_count"

while [ $imsi_count -lt $finish_at ]
do
	echo -e "\n imsi_count = $imsi_count. \n ; finish at $finish_at"
	for  (( num_entries_per_imsi_count=0 ;  num_entries_per_imsi_count < $num_entries_per_imsi  ;  num_entries_per_imsi_count++ ))
	do
		echo -e "\nStarting second  while loop. num_entries_per_imsi_count = $num_entries_per_imsi_count. \n"
		# Generate random weighting per domain interest
		random_weighting=`exec shuf -i  0-100 -n 1`
		echo -e "Random Weighting value =  $random_weighting "
	
		# generate randon value for domain Interests
		random_di_prof_array_val=`exec shuf -i  0-$di_array_last_index_val -n 1`
		echo -e "random DI_ARRAY index value=  $random_di_prof_array_val"
	
		# print line to standard output and file
		echo  "$profile_month $profile_year|$imsi_count|${DI_ARRAY[$random_di_prof_array_val]}|$random_weighting"
		echo  "$profile_month $profile_year|$imsi_count|${DI_ARRAY[$random_di_prof_array_val]}|$random_weighting">> DomainUsageDataSet.out
		
	done # end of inner loop	
	echo -e "starting $imsi_count of outside loop"
	let "imsi_count += 1"
done # end of outer loop

echo -e "\n\n***** FINISHED**********"
}

#******************************************************************************************
## end of defining functions
#******************************************************************************************

# Generate Profile Data Set
gen_profile_data