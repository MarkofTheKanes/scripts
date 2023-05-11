#!/usr/bin/bash
#******************************************************************************
# Title: Gen_ProfileDataSet.sh
# Description:  used to generate the dataset for Profile Data in the following sample format
#     DATE|IMSI|MOBILITY PROFILE|SERVICE USAGE PROFILE
#     FEBRUARY 2016|123456700000001|Delivering The Goods|Average User
#     FEBRUARY 2016|123456700000002|Night Shift|High SMS - Low Data
#     FEBRUARY 2016|123456700000003|Homebody|High SMS - Low Data
#     FEBRUARY 2016|123456700000004|Daily Grinder|Average User
# one line per IMSI - mix of Mobility Profile and Service Usage Profile
# Author: Mark O'Kane
# Date: 13th Oct 2016
# Version: 1.0
# History:
#   Ver. 1.0 - 13th Oct 2016
# Comments:
# Dependencies: None
#******************************************************************************

#Check command line arguments
if [ $# -ne 4 ]
then
	echo " "
	echo "Usage $0 [Month] [Year] [#IMSIs] [IMSI Start number] "
	echo " "
	echo "    - Month: Month for which profile data to be generated e.g. FEBRUARY"
	echo "    - Year: Year for which profile data to be generated e.g. 2016"
	echo "    - #IMSIs: number of IMSIs to generate entries for"
	echo "    - IMSI Start number: number at which to start IMSI from e.g. 123456700000000"
	echo "    e.g. ./Gen_ProfileData.sh FEBRURARY 2016 10000 123456700000000"
	echo " "
exit 2
fi

#*******************************************************************************************
# define configuration items
#*******************************************************************************************

# input params
profile_month=$1
profile_year=$2
num_imsis=$3
imsi_val_start=$4
let finish_at="$imsi_val_start + $num_imsis"

#*******************************************************************************************
# define functions
#*******************************************************************************************

# Generate Profile Data Set

gen_profile_data ()
{

echo -e "\nGenerating Profile Data Set for $num_imsis IMSIs starting number @ $imsi_val_start  for the data $profile_month $profile_year..."

# define timestamp format to be used to rename existing output files
timestamp=`exec date +%y%m%d%H%M%S`

# Check if output file exists. If so, rename it with timestamp and create a new version with the header data in it.

if [ -e ProfileDataSet.out ]
then
	echo -e "\nRenaming old dataset file\n"
	mv ProfileDataSet.out ProfileDataSet-${timestamp}.out
	echo "DATE|IMSI|MOBILITY PROFILE|SERVICE USAGE PROFILE"  > ProfileDataSet.out
else
	echo "DATE|IMSI|MOBILITY PROFILE|SERVICE USAGE PROFILE"  > ProfileDataSet.out
fi

# Declare Mobile Profile Array to be used to assign random Profiles to each IMSI
declare -a MP_ARRAY
MP_ARRAY=("Delivering The Goods"  "Night Shift" "Homebody" "Daily Grinder" "Norm Peterson" "Busy")
# determine last index value of MO_ARRAY - reuqired to generate randon Profiles for each IMSI. -1 used as index starts at 0
let mp_array_last_index_val="${#MP_ARRAY[@]}-1"
echo -e "last MP_ARRAY index value= $mp_array_last_index_val"

# Declare Service Usage  Profile Array to be used to assign random Services to each IMSI
declare -a SUP_ARRAY
SUP_ARRAY=("Average User" "Big Data" "High SMS - Low Data" "High Voice" "High Voice & SMS" "Low Usage Overall")
# determine last index value of SUP_ARRAY - reuqired to generate randon Services for each IMSI.  -1 used as index starts at 0
let sup_array_last_index_val="${#SUP_ARRAY[@]}-1"
echo -e "last SUP_ARRAY index value=  $sup_array_last_index_val"

## create profile data set
imsi_count=$imsi_val_start

while [ $imsi_count -lt $finish_at ]
do
	# generate randon value for Mobile Profile
	random_mob_prof_array_val=`exec shuf -i  0-$mp_array_last_index_val -n 1`
	echo -e "random MOB_ARRAY index value=  $random_mob_prof_array_val "
	
	# generate randon value for  Service Usage Profile
	random_serv_prof_array_val=`exec shuf -i  0-$sup_array_last_index_val  -n 1`
	echo -e "random SUP_ARRAY index value=  $random_mob_prof_array_val"
	
	# print line to standard output and file
	echo  "$profile_month $profile_year|$imsi_count|${MP_ARRAY[$random_mob_prof_array_val]}|${SUP_ARRAY[$random_serv_prof_array_val]}"
	echo  "$profile_month $profile_year|$imsi_count|${MP_ARRAY[$random_mob_prof_array_val]}|${SUP_ARRAY[$random_serv_prof_array_val]}">> ProfileDataSet.out

let "imsi_count += 1"
done

echo -e "\n\n***** FINISHED**********"
}

#******************************************************************************************
## end of defining functions
#******************************************************************************************

# Generate Profile Data Set
gen_profile_data