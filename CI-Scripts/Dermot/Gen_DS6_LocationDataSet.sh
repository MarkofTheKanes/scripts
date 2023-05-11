#!/usr/bin/bash
#******************************************************************************
# Title: Gen_DS6_LocationDataSet.sh
# Description:  used to generate the dataset for Better Tarrif demo in the following sample format
#		IMSI|Location|Affinity|Service Usage Profile
#		123456700000001|Blanchardstown|Work|Big Data
#		123456700000002|Dundrum|Home|Average User
# one line per IMSI - mix of location, affinity, and service usage profile
# Author: Mark O'Kane
# Date: 13th Oct 2016
# Version: 1.0
# History:
#   Ver. 1.0 - 13th Oct 2016
# Comments:
# Dependencies: None
#******************************************************************************

clear

#Check command line arguments
if [ $# -ne 2 ]
then
	echo " "
	echo "Usage $0 [#IMSIs] [IMSI Start number] "
	echo " "
	echo "    - #IMSIs: number of IMSIs to generate entries for"
	echo "    - IMSI Start number: number at which to start IMSI from e.g. 123456700000000"
	echo "    e.g. ./Gen_DS6_LocationDataSet.sh 10000 123456700000000"
	echo " "
exit 2
fi

#*******************************************************************************************
# define configuration items
#*******************************************************************************************

# input params
num_imsis=$1
imsi_val_start=$2
let finish_at="$imsi_val_start + $num_imsis"

#*******************************************************************************************
# define functions
#*******************************************************************************************

# Generate Profile Data Set

gen_dataset ()
{

echo -e "\nGenerating Location Data Set for $num_imsis IMSIs starting number @ $imsi_val_start."

# define timestamp format to be used to rename existing output files
timestamp=`exec date +%y%m%d%H%M%S`

# Check if output file exists. If so, rename it with timestamp and create a new version with the header data in it.

if [ -e Location_DS6_DataSet.csv ]
then
	echo -e "\nRenaming old dataset file\n"
	mv Location_DS6_DataSet.csv Location_DS6_DataSet-${timestamp}.csv
	echo "IMSI|Location|Affinity|Service Usage Profile"  > Location_DS6_DataSet.csv
else
	echo "IMSI|Location|Affinity|Service Usage Profile"  > Location_DS6_DataSet.csv
fi

# Declare Location Array to be used to assign random locations to each IMSI
declare -a LP_ARRAY
LP_ARRAY=("Blanchardstown" "Dundrum" "Liffey Valley" "Swords Pavillion")
# determine last index value of LP_ARRAY - reuqired to generate random locations for each IMSI. -1 used as index starts at 0
let lp_array_last_index_val="${#LP_ARRAY[@]}-1"
# echo -e "last LP_ARRAY index value= $lp_array_last_index_val"

# Declare Affinity Array to be used to assign random affinitys to each IMSI
declare -a AF_ARRAY
AF_ARRAY=("Home" "Work" "Leisure")
# determine last index value of AF_ARRAY - reuqired to generate randon affinity for each IMSI. -1 used as index starts at 0
let af_array_last_index_val="${#AF_ARRAY[@]}-1"
# echo -e "last AF_ARRAY index value= $af_array_last_index_val"

# Declare Service Usage Profile Array to be used to assign random Services to each IMSI
declare -a SUP_ARRAY
SUP_ARRAY=("Average User" "Big Data" "High SMS - Low Data" "High Voice" "High Voice & SMS" "Low Usage Overall")
# determine last index value of SUP_ARRAY - reuqired to generate randon Services for each IMSI.  -1 used as index starts at 0
let sup_array_last_index_val="${#SUP_ARRAY[@]}-1"
# echo -e "last SUP_ARRAY index value=  $sup_array_last_index_val"

## create profile data set
imsi_count=$imsi_val_start

while [ $imsi_count -lt $finish_at ]
do
	# generate randon value for location array
	random_lp_prof_array_val=`exec shuf -i  0-$lp_array_last_index_val -n 1`
	# cho -e "random LP_ARRAY index value=  $random_lp_prof_array_val "
	
	# generate randon value for affinity array value
	random_af_prof_array_val=`exec shuf -i  0-$af_array_last_index_val -n 1`
	# echo -e "random AF_ARRAY index value=  $random_af_prof_array_val "
	
	# generate randon value for Service Usage Profile
	random_sup_prof_array_val=`exec shuf -i  0-$sup_array_last_index_val -n 1`
	# echo -e "random SUP_ARRAY index value=  $random_sup_prof_array_val "
	
	# print line to standard output and file
	# echo  "$imsi_count|${LP_ARRAY[$random_lp_prof_array_val]}|${AF_ARRAY[$random_af_prof_array_val]}|${SUP_ARRAY[$random_sup_prof_array_val]}"
	echo  "$imsi_count|${LP_ARRAY[$random_lp_prof_array_val]}|${AF_ARRAY[$random_af_prof_array_val]}|${SUP_ARRAY[$random_sup_prof_array_val]}">> Location_DS6_DataSet.csv

let "imsi_count += 1"
done

echo -e "\n\n***** FINISHED**********"
}

#******************************************************************************************
## end of defining functions
#******************************************************************************************

# Generate Profile Data Set
gen_dataset