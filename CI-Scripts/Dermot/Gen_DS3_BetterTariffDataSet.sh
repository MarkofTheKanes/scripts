#!/usr/bin/bash
#******************************************************************************
# Title: Gen_DS3_BetterTariffDataSet.sh
# Description:  used to generate the dataset for Better Tarrif demo in the following sample format
#		IMSI|Mobility Profile|Tariff Plan|Service Usage Profile
#		123456700000001|Night Owl|Off Peak - Family & Friends|Big Data
#		123456700000002|Norm Peterson|Lifestyle 360|Average User
# one line per IMSI - mix of Mobility Profile and Service Usage Profile
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
	echo "    e.g. ./Gen_DS3_BetterTariffDataSet.sh 10000 123456700000000"
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

echo -e "\nGenerating Profile Data Set for $num_imsis IMSIs starting at number @ $imsi_val_start."

# define timestamp format to be used to rename existing output files
timestamp=`exec date +%y%m%d%H%M%S`

# Check if output file exists. If so, rename it with timestamp and create a new version with the header data in it.

if [ -e BetterTariff_DS3_DataSet.csv ]
then
	echo -e "\nRenaming old dataset file\n"
	mv BetterTariff_DS3_DataSet.csv BetterTariff_DS3_DataSet-${timestamp}.csv
	echo "IMSI|Mobility Profile|Tariff Plan|Service Usage Profile"  > BetterTariff_DS3_DataSet.csv
else
	echo "IMSI|Mobility Profile|Tariff Plan|Service Usage Profile"  > BetterTariff_DS3_DataSet.csv
fi

# Declare Mobile Profile Array to be used to assign random Profiles to each IMSI
declare -a MP_ARRAY
MP_ARRAY=("Delivering The Goods"  "Night Shift" "Homebody" "Daily Grinder" "Norm Peterson" "Busy")
# determine last index value of MP_ARRAY - reuqired to generate randon Profiles for each IMSI. -1 used as index starts at 0
let mp_array_last_index_val="${#MP_ARRAY[@]}-1"
# echo -e "last MP_ARRAY index value= $mp_array_last_index_val"

# Declare Tariff Plan Array to be used to assign random Profiles to each IMSI
declare -a TP_ARRAY
TP_ARRAY=("All the Data" "Off Peak - Family & Friends" "Off Peak - All the Data" "Lifestyle 360" "Family & Friends" "Business Special" "Monthly 200" "Monthly 500" "Just For You")
# determine last index value of TP_ARRAY - reuqired to generate randon tariff plans for each IMSI. -1 used as index starts at 0
let tp_array_last_index_val="${#TP_ARRAY[@]}-1"
# echo -e "last TP_ARRAY index value= $tp_array_last_index_val"

# Declare Service Usage  Profile Array to be used to assign random Services to each IMSI
declare -a SUP_ARRAY
SUP_ARRAY=("Average User" "Big Data" "High SMS - Low Data" "High Voice" "High Voice & SMS" "Low Usage Overall")
# determine last index value of SUP_ARRAY - reuqired to generate randon Services for each IMSI.  -1 used as index starts at 0
let sup_array_last_index_val="${#SUP_ARRAY[@]}-1"
# echo -e "last SUP_ARRAY index value=  $sup_array_last_index_val"

## create profile data set
imsi_count=$imsi_val_start

while [ $imsi_count -lt $finish_at ]
do
	# generate randon value for Mobile Profile
	random_mob_prof_array_val=`exec shuf -i  0-$mp_array_last_index_val -n 1`
	# echo -e "random MOB_ARRAY index value=  $random_mob_prof_array_val "
	
	# generate randon value for Tariff Plan value
	random_tp_prof_array_val=`exec shuf -i  0-$tp_array_last_index_val -n 1`
	# echo -e "random TP_ARRAY index value=  $random_tp_prof_array_val "
	
	# generate randon value for Service Usage Profile
	random_sup_prof_array_val=`exec shuf -i  0-$sup_array_last_index_val -n 1`
	# echo -e "random SUP_ARRAY index value=  $random_sup_prof_array_val "
	
	# print line to standard output and file
	# echo  "$imsi_count|${MP_ARRAY[$random_mob_prof_array_val]}|${TP_ARRAY[$random_tp_prof_array_val]}|${SUP_ARRAY[$random_sup_prof_array_val]}"
	echo  "$imsi_count|${MP_ARRAY[$random_mob_prof_array_val]}|${TP_ARRAY[$random_tp_prof_array_val]}|${SUP_ARRAY[$random_sup_prof_array_val]}">> BetterTariff_DS3_DataSet.csv

let "imsi_count += 1"
done

echo -e "\n***** FINISHED**********"
}

#******************************************************************************************
## end of defining functions
#******************************************************************************************

# Generate Profile Data Set
gen_dataset