#!/bin/bash
## script to parse client cloud opps from Atlas opps export file.
## File must be in csv format

clear

#Check command line arguments
if [ $# -ne 2 ]
then
	echo " "
 	echo "Usage $0 [input file name]"
 	echo " "
 	echo "    - input file name: csv file to parse"
	echo "    - Debug value: 0 = off, 1 = on"
 	echo "    e.g. ./parsecodes.sh atlasopps.csv 1"
 	echo " "
 exit 2
 fi

#*******************************************************************************************
# define configuration items
#*******************************************************************************************

# input params
input_file=$1
debugVal=$2

#*******************************************************************************************
# declare and create shared arrays
#*******************************************************************************************

### #1 CLIENT ARRAY ###
# Declare and create the array to hold the list of clients to be parsed
declare -a CLIENT_ARRAY
CLIENT_ARRAY=("BAE Systems" "Broadridge" "lloyds" "Unipart")
echo -e "\n# CLIENT_ARRAY created with ${#CLIENT_ARRAY[@]} clients"

	# determine last index value of CLIENT_ARRAY.
	let CLIENT_ARRAY_last_index_val="${#CLIENT_ARRAY[@]}"
	if [ "$debugVal" -eq 1 ]; then echo -e "\n# Number of clients: $CLIENT_ARRAY_last_index_val"; fi

### #1 ID ARRAY ###
# Declare and create the array to hold the list of IDs to be parsed
declare -a ID_ARRAY
ID_ARRAY=(6950-04M 6950-06A 6950-06G 6950-06Y 6950-15K 6950-17E 6950-17F 6950-17G 6950-17H 6950-17J 6950-17V 6950-18Z 6950-19E 6950-19L 6950-19U 6950-19W 6950-19X 6950-20C 6950-20J 6950-27G 6950-30I 6950-33X 6950-33Z 6950-34Z 6950-99D 69SW-G15 69SW-G16 69SW-G18 69SW-G11 69SW-G12 69SW-G03 69SW-G01 69SW-G17 69SW-G09 69SW-G10 6941-02C 6941-03B 6941-03C 6941-00C 6941-94B 6941-00F 6941-94H 6941-00H 6941-95Q 6941-95S 6941-95U 6941-95V 6941-95W 6941-00E 6941-95X 6941-96N 6941-96R 6941-00B 6941-96V 6941-96Q 6941-96Y 6941-96Z 6941-97B 6941-97H 6941-05F 6941-00Y 6941-25M 6941-00I 6941-25N 6941-00G 6941-25T 6941-01Q 6941-00A 69SW-G13 69SW-G14 69SW-G19)

	# determine last index value of ID_ARRAY.
	let ID_ARRAY_last_index_val="${#ID_ARRAY[@]}"
	if [ "$debugVal" -eq 1 ]; then echo -e "\n# Number of IDs: $ID_ARRAY_last_index_val"; fi

#*******************************************************************************************
# define functions
#*******************************************************************************************
## Backup old output file. Check if output file exists. If so, rename it with timestamp and create a new version with the header data in it
timestamp=`exec date +%y%m%d%H%M%S`

backup_results_files ()

## Check if final output file clientopps.csv already exists. If so, rename it with timestamp and create a new version with the header data in it.
{
if [ -e clientopps.csv ]
then
	echo -e "\n# Renaming old output file to: "clientopps.csv-${timestamp}.csv""
	mv clientopps.csv clientopps.csv-${timestamp}.csv
	touch clientopps.csv
else
	echo -e "\n# Creating output file"
	touch clientopps.csv
fi
}

## This function checks if the previous temp file exists and depending on the debug level will do the following:
# If debug = 1, rename old temp file tmp_results.csv and create the new one
# If debug = 0, delete the old temp file tmp_results.csv and create the new one
delete_old_temp_file ()
{
if [ "$debugVal" -eq 1 ]
then
	if [ -e tmp_results.csv ]
	then
		# if debug on and temp file already exists, rename old temp file
		echo -e "\n# Renaming old temp file to: "tmp_results-${timestamp}.csv""
		mv tmp_results.csv tmp_results-${timestamp}.csv
		touch tmp_results.csv
	else
		# if debug on and temp file does not exist, create the new temp file
		echo -e "\n# Creating output file"
		touch tmp_results.csv
	fi
else
	if [ -e tmp_results.csv ]
	then
		# if debug off and temp file does not exist, delete the old temp file
		echo -e "\n# Deleting old temp file"
		rm tmp_results.csv
		touch tmp_results.csv
	else
		# if debug off and temp file does not exist, create the new temp file
		echo -e "\n# Creating output file"
		touch tmp_results.csv
	fi
fi
}

## parse list of required clients into a temp file tmp_results.csv
get_required_clients ()
{
num_clients_counter=0
echo -e "\n# Getting all client opps..."
let client_array_count="$CLIENT_ARRAY_last_index_val" 

if [ "$debugVal" -eq 1 ]; then echo -e "\n# number client count start: $client_array_count"; fi
if [ "$debugVal" -eq 1 ]; then echo -e "\n# number clients counter start: $num_clients_counter"; fi

while [ $num_clients_counter -lt $client_array_count ]
do
	exec < $input_file
	while read line
		do
			if [ "$debugVal" -eq 1 ]; then echo -e "\n# number clients counter in opp: $num_clients_counter"; fi
			if [ "$debugVal" -eq 1 ]; then echo -e "\n# Client = ${CLIENT_ARRAY[$num_clients_counter]}"; fi
			grep -i "${CLIENT_ARRAY[$num_clients_counter]}" >> tmp_results.csv
		done 
	let "num_clients_counter += 1"
	if [ "$debugVal" -eq 1 ]; then echo -e "\n# number clients counter: $num_clients_counter"; fi
done
}

## parse list of required IDs from tmp_results.csv for the clients into a the final results file clientopps.csv
get_opps ()
{
num_ids_counter=0
echo -e "\n# Getting required opps for clients..."
#let id_array_count="$CLIENT_ARRAY_last_index_val -1" 
let id_array_count="$ID_ARRAY_last_index_val" 

if [ "$debugVal" -eq 1 ]; then echo -e "\n# number IDs  count start: $id_array_count"; fi
if [ "$debugVal" -eq 1 ]; then echo -e "\n# number IDs counter start: $num_ids_counter"; fi

while [ $num_ids_counter -lt $id_array_count ]
do
	exec < tmp_results.csv
	while read line
		do
			if [ "$debugVal" -eq 1 ]; then echo -e "\n# number ids counter in opp: $num_ids_counter"; fi
			if [ "$debugVal" -eq 1 ]; then echo -e "\n# ID = ${ID_ARRAY[$num_ids_counter]}"; fi
			if [ "$debugVal" -eq 1 ]; then echo -e "\n"; fi
			grep -i "${ID_ARRAY[$num_ids_counter]}" >> clientopps.csv
		done 
	let "num_ids_counter += 1"
	if [ "$debugVal" -eq 1 ]; then echo -e "\n# number IDs counter: $num_ids_counter"; fi
done

# If debug = 1, keep the new tmp_results.csv
# If debug = 0, delete the new temp file tmp_results.csv

if [ "$debugVal" -eq 0 ]; then rm tmp_results.csv; fi
}

#******************************************************************************************
## end of defining functions
#******************************************************************************************

backup_results_files
delete_old_temp_file
get_required_clients
get_opps

echo -e "\n# Finished. \n"

exit 1