#!/usr/bin/bash
## script to parse selcted PRR recommendations from a csv file and
## generate a html file with all details for inclusion in the initial PRR report template.
## File must be in csv format

# set -o errexit
# set -o nounset
clear

#Check command line arguments
if [ $# -ne 2 ]
then
	echo " "
 	echo "Usage $0 [input file name] [debug value]"
 	echo " "
 	echo "    - input file name: csv file to parse"
	echo "    - Debug value: 0 = off, 1 = on"
 	echo "    e.g. ./gen_recommendations.sh filter_options.csv 1"
 	echo " "
 exit 2
 fi

#*******************************************************************************************
# define configuration items
#*******************************************************************************************

# input params
input_file=$1
debugVal=$2


if [ "$debugVal" -eq 1 ] 
then 
	set -x  # show command 
	trap read debug  # require a RETURN after each command executed 

fi

#*******************************************************************************************
# define array(s)
#*******************************************************************************************

## parse list of required recommendation keys (1st column of input csv file) into the array temp KEY_ARRAY_TMP. 
## Keys to be used to get detailed recommendations and add them to the final file
# if recommendation has been selected i.e. column 7 has Yes, add recommendation key in column 1 to array

echo -e "\n> Adding selected recommendation keys to array KEY_ARRAY from file: $input_file"
KEY_ARRAY_TMP=() # clear the array
KEY_ARRAY=() # clear the array

declare -a KEY_ARRAY_TMP # temp array to hold inital keys
KEY_ARRAY_TMP=($(awk -F, '$7 ~ /Yes/ {print $1}' $input_file ))


## alpabtically sort KEY_ARRAY_TMP entries into KEY_ARRAY
readarray -t KEY_ARRAY < <(for a in "${KEY_ARRAY_TMP[@]}"; do echo "$a"; done | sort -V)

if [ "$debugVal" -eq 2 ] 
then 
	echo -e "\n> KEY_ARRAY created with ${#KEY_ARRAY[@]} keys"
	for i in "${KEY_ARRAY[@]}"
	do
		:
		echo $i
	done
else
	echo ""	
fi

## key/section title key pair array - used to change heading e.g. if key arc, heading = Architecture
#
echo -e "\n> Creating key-pair array with keys & section heading pairs."
SECTION_ARRAY=() # clear the array

declare -a SECTION_ARRAY
SECTION_ARRAY=("arc" "Architecture" "aut" "Automation" "bnr" "Backup and Recovery" "con" "Configuration" "hav" "High Availability" "iam" "Identity and Access Management" "mgt" "Management" "net" "Networking" "obs" "Observability" "sem" "Secrets Management" "sec" "Security" "ssc" "Software Supply Chain" "scs" "Supply Chain Security")

if [ "$debugVal" -eq 2 ] 
then 
	echo -e "\n> SECTION_ARRAY created with ${#SECTION_ARRAY[@]} keys."
	for i in "${SECTION_ARRAY[@]}"
	do
		:
		echo $i
	done
else
	echo ""	
fi


#*******************************************************************************************
# define functions
#*******************************************************************************************
## Backup old output file. Check if output file exists. If so, rename it with timestamp and 
# create a new version with the header data in it
timestamp=`exec date +%y%m%d%H%M%S`

# check backup directory exists
check_bkup_dir ()
{
	if [ -d "backup" ]
		then
		echo -e "\n> Backup directory exists."
	else
		mkdir ./backup
		echo -e "\n> Backup directory created."
	fi
}

## Check if final recommendations file "filtered_recomms.html" already exists. If so, rename it with timestamp 
# and create a new version with the header data in it.
backup_recomms_files ()
{
	if [ -e filtered_recomms.html ]
	then
		echo -e "\n> Renaming previous output file to: "filtered_recomms-${timestamp}.html""
 		mv filtered_recomms.html ./backup/filtered_recomms-${timestamp}.html
		touch filtered_recomms.html
	else
		echo -e "\n> Creating output file."
		touch filtered_recomms.html
		echo  ""
	fi
}

## create the initial filtered_recomms.html file with the required header info in it.
#
create_recomms_file ()
{
	echo -e "\n> Creating new output file \"filtered_recomms.html\" with heading info"
	cp ./section_templates/file_start.html ./filtered_recomms.html
}


## get keys and use them to add recoomendation details. If 1st entry for a key, add the section heading +
# summary table to the filtered_recomms.html file first
append_rec_details  ()
{
key_array2=$1
key_array2=("$@")

# determine last index value of CLIENT_ARRAY.
let key_array2_last_index_val="${#key_array2[@]}"

# used to track occurence of each key. If > 1, do not append the heading + summary table until the next unique key occurs
loop1_counter=0 ## while loop counter
prev_short_key=0 # used to store short key to check 

while [ $loop1_counter -lt $key_array2_last_index_val ]
do		
	short_key=${key_array2[$loop1_counter]:0:3} # var to hold 1st 3 letter of key. Used to generate the section heading
	if [ "$short_key" == "$prev_short_key" ]
	then
		echo -e "Adding details section for ${key_array2[$loop1_counter]}"
		cat ./details_files/${key_array2[$loop1_counter]}.html >>filtered_recomms.html
	else # call function to add the section header
		append_section_heading "${SECTION_ARRAY[@]}"
	fi
	prev_short_key=$short_key
	((loop1_counter++))
done
}


## Create the required sections and append the detailed info for each recommendation into the filtered_recomms.html file
append_section_heading ()
{
# first get the section header by querying the SECTION_ARRAY based on the key. 
sec_array2=$1
sec_array2=("$@")

# determine last index value of SECTION_ARRAY for the loop while below.
let sec_array2_last_index_val="${#sec_array2[@]}"
	
loop2_counter=0 ## while loop counter
while [ $loop2_counter -lt $sec_array2_last_index_val ]
do
	if [ "$short_key" == "${sec_array2[$loop2_counter]}" ] 
	then
		((loop2_counter++)) # increment loop counter by 1 to point to the next index item in the array = section header to be used
		cp ./section_templates/section_header.html ./tmp_sec_header.html
		sed -i "s/SECTION_HEADER/${sec_array2[$loop2_counter]}/" tmp_sec_header.html # change the section header
		cat ./tmp_sec_header.html >>filtered_recomms.html
		cat ./details_files/${key_array2[$loop1_counter]}.html >>filtered_recomms.html
		echo -e "\n> Appended section heading for ${sec_array2[$loop2_counter]} and details section for ${key_array2[$loop1_counter]}.html"
		rm ./tmp_sec_header.html
	else
		let "loop2_counter+=2"
	fi
done
}


## add the last html required for teh final recooms file to work on a browser
finish_recomms_file ()
{
	echo -e "\n> Adding end section to \"filtered_recomms.html\""
	cat ./section_templates/file_end.html >>filtered_recomms.html
	echo -e "\n> Finished. \n"
	exit 0
}

#******************************************************************************************
## end of defining functions
#******************************************************************************************
check_bkup_dir
backup_recomms_files
create_recomms_file
append_rec_details "${KEY_ARRAY[@]}"
finish_recomms_file
