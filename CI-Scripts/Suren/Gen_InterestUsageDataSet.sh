#!/usr/bin/bash
#******************************************************************************
# Title: Gen_InterestUsageDataSet.sh
# Description:  used to generate the dataset for Interest Usage in the following sample format
# 	DATE|IMSI|PRIMARY INTEREST|SECONDARY INTEREST|WEIGHTING
# 	FEBRUARY 2016|123456700000001|News & Media|News|68
# 	FEBRUARY 2016|123456700000001|Finance|Banking|31
# 	FEBRUARY 2016|123456700000001|Sport|Golf|5
# 	FEBRUARY 2016|123456700000001|News & Media|News|41
# 	FEBRUARY 2016|123456700000001|News & Media|Magazines & E-Zines|85
# 	FEBRUARY 2016|123456700000001|News & Media|News|90
# 	FEBRUARY 2016|123456700000001|News & Media|News|24
# multiple lines per IMSI - mix of Primary and Secondary interests
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
	echo "    - No. entries per IMSI: number of primary & secondary interests to be created per IMIS e.g. 7"
	echo -e "\n    e.g. ./Gen_InterestUsageDataSet.sh FEBRURARY 2016 10000 123456700000000 7"
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

# Generate Interest Usage Profile Data Set

gen_profile_data ()
{
echo -e "\n\nGenerating Interest Usage Profile Data Set for :
- $num_imsis IMSIs starting number @ $imsi_val_start 
- for the date $profile_month $profile_year
- with $num_entries_per_imsi primary and secondary interests per IMSI\n"

# define timestamp format to be used to rename existing output files
timestamp=`exec date +%y%m%d%H%M%S`

# Check if output file exists. If so, rename it with timestamp and create a new version with the header data in it.

if [ -e InterestUsageDataSet.out ]
then
	echo -e "\nRenaming old dataset file\n"
	mv InterestUsageDataSet.out InterestUsageDataSet-${timestamp}.out
	echo "DATE|IMSI|PRIMARY INTEREST|SECONDARY INTEREST|WEIGHTING"  > InterestUsageDataSet.out
else
	echo "DATE|IMSI|PRIMARY INTEREST|SECONDARY INTEREST|WEIGHTING"  > InterestUsageDataSet.out
fi

# Declare Primary/Secondary Interests Array to be used to assign random interests to each IMSI
declare -a PSI_ARRAY
PSI_ARRAY=("News & Media|News" "News & Media|Magazines & E-Zines" "News & Media|Science" "Finance|Banking" "Sport|Sport" "Sport|Soccer" "Sport|Rugby" "Sport|Golf" "Arts & Entertainment|TV & Video" "Gambling|Sports Gambling" "Books & Literature|Book Retailers" "Internet & Telecom|Social Networking")

# determine last index value of PSI_ARRAY - reuqired to generate randon interests for each IMSI. -1 used as index starts at 0
let psi_array_last_index_val="${#PSI_ARRAY[@]}-1"
echo -e "last PSI_ARRAY index value= $psi_array_last_index_val"

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
		# Generate random weighting per primary/secondary interest
		random_weighting=`exec shuf -i  0-100 -n 1`
		echo -e "Random Weighting value =  $random_weighting "
	
		# generate randon value for Primary/Secondary Interests
		random_psi_prof_array_val=`exec shuf -i  0-$psi_array_last_index_val -n 1`
		echo -e "random PSI_ARRAY index value=  $random_psi_prof_array_val"
	
		# print line to standard output and file
		echo  "$profile_month $profile_year|$imsi_count|${PSI_ARRAY[$random_psi_prof_array_val]}|$random_weighting"
		echo  "$profile_month $profile_year|$imsi_count|${PSI_ARRAY[$random_psi_prof_array_val]}|$random_weighting">> InterestUsageDataSet.out
		
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