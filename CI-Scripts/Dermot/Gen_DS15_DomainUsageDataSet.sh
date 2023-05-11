#!/usr/bin/bash
#******************************************************************************
# Title: Gen_DS15_DomainUsageDataSet.sh
# Description:  used to generate the dataset for Domain Usage in the following sample format
#		DATE|IMSI|DOMAIN|WEIGHTING|DEVICE|PLAN
#		FEBRUARY 2016|123456700000001|news.bbc.com|68|iPhone 5|High Voice - High SMS
#		FEBRUARY 2016|123456700000001|citibank.com|31iPhone 7|All Data
#		FEBRUARY 2016|123456700000001|golf.skysports.com|5|Samsung S5|High Voice
#		FEBRUARY 2016|123456700000001|newyorktimes.com|41|HTC 10|Family and Friends
#		FEBRUARY 2016|123456700000001|time.com|85|Samsung S7|High SMS - Low Data
# multiple lines per IMSI - mix of domain interests|iPhone 5|Lifestyle 360
# Author: Mark O'Kane
# Date: 13th Oct 2016
# Version: 2.0
# History:
#   Ver. 1.0 - 13th Oct 2016
#   Ver.: 2.0 added Device and Plan columns
# Comments:
# Dependencies: None
#******************************************************************************

clear
#Check command line arguments
if [ $# -ne 5 ]
then
	echo " "
	echo "Usage $0 [Month] [Year] [#IMSIs] [IMSI Start number] [No. entries per IMSI] "
	echo " "
	echo "    - Month: Month for which profile data to be generated e.g. FEBRUARY"
	echo "    - Year: Year for which profile data to be generated e.g. 2016"
	echo "    - #IMSIs: number of IMSIs to generate entries for"
	echo "    - IMSI Start number: number at which to start IMSI from e.g. 123456700000000"
	echo "    - No. entries per IMSI: number of domaisn entries to be created per IMIS e.g. 5"
	echo -e "\n    e.g. ./Gen_DS15_DomainUsageDataSet.sh FEBRURARY 2016 10000 123456700000000 5"
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

gen_dataset ()
{
echo -e "\n\nGenerating Domain Usage Profile Data Set for:
- $num_imsis IMSIs starting number @ $imsi_val_start 
- for the date $profile_month $profile_year
- with $num_entries_per_imsi domains per IMSI\n"

# define timestamp format to be used to rename existing output files
timestamp=`exec date +%y%m%d%H%M%S`

# Check if output file exists. If so, rename it with timestamp and create a new version with the header data in it.

if [ -e DomainUsage_DS15_DataSet.csv ]
then
	echo -e "\nRenaming old dataset file"
	mv DomainUsage_DS15_DataSet.csv DomainUsage_DS15_DataSet-${timestamp}.csv
	echo "DATE|IMSI|DOMAIN|WEIGHTING|DEVICE|PLAN"  > DomainUsage_DS15_DataSet.csv
else
	echo "DATE|IMSI|DOMAIN|WEIGHTING|DEVICE|PLAN"  > DomainUsage_DS15_DataSet.csv
fi

## Declare Domain Interests Array to be used to assign random interests to each IMSI
declare -a DI_ARRAY
DI_ARRAY=("www.amazon.co.uk" "www.amazon.com" "www.bbc.co.uk" "www.bing.com" "www.blogger.com" "www.cnn.net" "www.nbc.com" "www.dailymotion.com" "www.doubleclick.net" "www.ebay.com" "www.espn.es" "www.espn.com" "www.facebook.com" "www.linkedin.com" "www.ibm.com" "www.fox.com" "www.foxsport.com" "www.frx.com" "www.github.com" "www.google.ie" "www.google.co.uk" "www.google.com" "www.googleadservices.com" "www.mashable.com" "www.hulu.com" "www.instagram.com" "www.kayak.com" "www.live.com" "www.microsoft.com" "www.netflix.com" "www.pandora" "www.reddit.com" "www.rydercup.com" "www.skyscanner.com" "www.tripadvisor.com" "www.twitter.com" "www.uspga.com" "www.wikipedia.org" "www.yahoo.com" "www.youtube.com")
# determine last index value of DI_ARRAY - reuqired to generate randon domains for each IMSI. -1 used as index starts at 0
let di_array_last_index_val="${#DI_ARRAY[@]}-1"
#echo -e "last DI_ARRAY index value= $di_array_last_index_val"

# #Declare Device Array to be used to assign random devices to each IMSI
declare -a DEV_ARRAY
DEV_ARRAY=("iPhone 5" "iPhone 5S" "iPhone6" "iPhone 6S" "iPhone 7" "iPhone 7 Plus" "Samsung S5" "Samsung S5 Plus" "Samsung S6" "Samsung S7" "Samsung Note 4" "Samsung Note 5" "HTC 1" "HTC 10" "HTC Desire" "Sony Xperia X" "OnePlus 3" "Google Pixel")
let dev_array_last_index_val="${#DEV_ARRAY[@]}-1"
# echo -e "last DEV_ARRAY index value=  $dev_array_last_index_val"

## Declare Tariff Plan Array ton be used to assign random plans to each IMSI
declare -a TP_ARRAY
TP_ARRAY=("All the Data" "Off Peak - Family & Friends" "Off Peak - All the Data" "Lifestyle 360" "Family & Friends" "Business Special" "Monthly 200" "Monthly 500" "Just For You")
# determine last index value of TP_ARRAY - reuqired to generate randon Services for each IMSI.  -1 used as index starts at 0
let tp_array_last_index_val="${#TP_ARRAY[@]}-1"
# echo -e "last TP_ARRAY index value=  $tp_array_last_index_val"

## create profile data set
# set counters
imsi_count=$imsi_val_start
#echo "imsi count = $imsi_count"

num_entries_per_imsi_count=0
#echo "num imsi count = $num_entries_per_imsi_count"

while [ $imsi_count -lt $finish_at ]
do
	#echo -e "\n imsi_count = $imsi_count. \n ; finish at $finish_at"
	for  (( num_entries_per_imsi_count=0 ;  num_entries_per_imsi_count < $num_entries_per_imsi  ;  num_entries_per_imsi_count++ ))
	do
		# echo -e "\nStarting second  while loop. num_entries_per_imsi_count = $num_entries_per_imsi_count. \n"
		## Generate random weighting per domain interest
		random_weighting=`exec shuf -i  0-100 -n 1`
		# echo -e "Random Weighting value =  $random_weighting "
	
		# #generate randon value for domain Interests
		random_di_prof_array_val=`exec shuf -i  0-$di_array_last_index_val -n 1`
		#echo -e "random DI_ARRAY index value=  $random_di_prof_array_val"
	
		# generate random value for device
		random_dev_array_val=`exec shuf -i  0-$dev_array_last_index_val -n 1`
		#echo -e "random DEV_ARRAY index value=  $random_dev_array_val"
		
		# generate random value for plan
		random_tp_array_val=`exec shuf -i  0-$tp_array_last_index_val -n 1`
		#echo -e "random TP_ARRAY index value=  $random_tp_array_val"
	
		# print line to standard output and file
		#echo  "$profile_month $profile_year|$imsi_count|${DI_ARRAY[$random_di_prof_array_val]}|$random_weighting|${DEV_ARRAY[$random_dev_array_val]}|${PLN_ARRAY[$random_tp_array_val]}"
		echo  "$profile_month $profile_year|$imsi_count|${DI_ARRAY[$random_di_prof_array_val]}|$random_weighting|${DEV_ARRAY[$random_dev_array_val]}|${TP_ARRAY[$random_tp_array_val]}">> DomainUsage_DS15_DataSet.csv
		
	done # end of inner loop	
	#echo -e "starting $imsi_count of outside loop"
	let "imsi_count += 1"
done # end of outer loop

echo -e "\n***** FINISHED**********"
}

#******************************************************************************************
## end of defining functions
#******************************************************************************************

# Generate Profile Data Set
gen_dataset