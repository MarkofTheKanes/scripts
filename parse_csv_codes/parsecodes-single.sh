#!/bin/bash
## script to parse client cloud opps from Atlas opps export file.
## File must be in csv format

clear

#Check command line arguments
if [ $# -ne 2 ]
then
	echo " "
 	echo "Usage $0 [input file name] [client name]"
 	echo " "
 	echo "    - input file name: csv file to parse"
 	echo "    - client name"
 	echo "    e.g. ./parsecodes.sh atlasopps.csv lloyds"
 	echo " "
 exit 2
 fi

#*******************************************************************************************
# define configuration items
#*******************************************************************************************

# input params
input_file=$1
client_name=$2
# let finish_at="$start_at + $num_users"

#*******************************************************************************************
# define functions
#*******************************************************************************************
## Backup old output file. Check if output file exists. If so, rename it with timestamp and create a new version with the header data in it
timestamp=`exec date +%y%m%d%H%M%S`

backup_old_files ()

## Check if output file exists. If so, rename it with timestamp and create a new version with the header data in it.
{
if [ -e Output.csv ]
then
	echo -e "\n# Renaming old output file to: "Output.csv-${timestamp}.csv""
	mv Output.csv Output.csv-${timestamp}.csv
	touch Output.csv
	#echo "imsi|timeid|ibmaaf_bytestotal_by_cell_sitename|ibmaaf_bytestotal|ibmaaf_set_cesaggregation_video_by_cell|dt|sgm"  > Output.csv
else
	#echo "imsi|timeid|ibmaaf_bytestotal_by_cell_sitename|ibmaaf_bytestotal|ibmaaf_set_cesaggregation_video_by_cell|dt|sgm"  > Output.csv
	echo -e "\n# Creating output file"
	touch Output.csv
fi
}

## read lines from input file
parse_file ()
{
echo -e "\n# Reading data..."
exec < $input_file
while read line
do
	# grep -i $client_name  >> Output.csv
	grep -i $client_name >> Output.csv
done 
}

#******************************************************************************************
## end of defining functions
#******************************************************************************************

backup_old_files
parse_file

echo -e "\n# Finished. \n"