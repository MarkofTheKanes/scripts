#!/usr/bin/bash

## Author : Mark O'kane
## ver 1

###############################################################################################
# Script to analyse GCP cloud logs to determine the log type entries per severity.
# It works as follows:
## check for existing output files and timestamp them if they exist.
## Validate the source log file is csv format (sort of). It will exit if it is not.
## Count the total number of log entries in the file
## [TO DO] Checks which column in the csv file the log severeties INFO, WARNING, ERROR are in.
## Count the number of entries for INFO, WARNING, ERROR and those with no severity
## Calculate the percentage of each as part the overall log count
## Generate/display the analysis results and write it to file
## Write logs with No Severity to a separate file for further analysis
## [TO DO] add option to clean up e.g. -c i.e. delete all previously generated output files
## [TO DO] check it with Libreoffice Calc csv files
###############################################################################################

set -Eeuo pipefail
set -o errexit
set -o nounset

#*******************************************************************************************
# define script arguments
#*******************************************************************************************

# clear

# Check required command line arguments are included. Exit if not.
PROGRAM=$(basename $0)
if [ $# -ne 1 ]; then
	echo " "
 	echo "Usage $0 [source csv file name]"
 	echo " "
 	echo "    - source csv file name: csv log file to analyse"
 	 	echo "      e.g. ./${PROGRAM} yee_olde_gcp_logs.csv"
 	echo " "
 exit 2;
fi

# input params
source_log_file=$1

#*******************************************************************************************
# define global variables
#*******************************************************************************************
analysis_results_file_name=analysis_results
analysis_results_file_type=txt
analysis_results_output=${analysis_results_file_name}.${analysis_results_file_type}

no_severity_logs_file_name=no_severity_logs
no_severity_logs_file_type=csv
no_severity_logs_file=${no_severity_logs_file_name}.${no_severity_logs_file_type}

# set the column in the csv file to search for the log severity in. 3 for test file
# 182 for gcp log file as of 9th May 23
severity_column=3

script_logfile=script_logfile.txt

#*******************************************************************************************
# define arrays
#*******************************************************************************************

declare -a LOG_SEVS_CHECK=('INFO' 'WARNING' 'ERROR' 'No Severity')
# declare -a LOG_SEVS_CHECK=('ERROR')

#*******************************************************************************************
# define functions
#*******************************************************************************************
# 
## Generate useful information as the script runs. Also writes to a script log file
function msg() {
  #echo >&2 -e "\n ${1-}"
	echo -e "\n${1-}" | tee -a $script_logfile
}

## [TO DO] Generate errors as the script runs. Also writes to a script log file
function err() {
  msg ">. [$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

## Asks the user if they have removed comma's from cells in the source csv file
## The script will return inaccurate results if they haven't
function ask_removed_commas() {
	msg "## Before proceeding to use this script, you need to remove/replace
## ALL comma's from cells within the source csv file \"${source_log_file}\". 
## The script will return inaccurate results if this is not done first.\n"
	read -p "Have you done this? If so, hit enter to proceed or do so now.? "
}

## set debug
function set_debug() {
	set -x
	msg "Debug TURNED ON".182
}

## Displays results of the analysis on the screen, and writes it to the $analysis_results_output file
function write_results() {
  #echo >&2 -e "\n ${1-}"
	echo -e "\n${1-}" | tee -a $analysis_results_output
}

## Backup/delete previously generated files
function backup_old_files () {
	timestamp=`exec date +%y%m%d%H%M%S`
	# Backup existing analysis results file if it exists otherwise create a new one
	if [ -e ${analysis_results_output} ]; then
		msg "Renaming old analysis results file to: \"${analysis_results_file_name}-${timestamp}.${analysis_results_file_type}\""
		mv ${analysis_results_output} ${analysis_results_file_name}-${timestamp}.${analysis_results_file_type}
		touch ${analysis_results_output}
	else
		msg "Creating results file ${analysis_results_output}"
		touch ${analysis_results_output}
	fi

# Backup existing no-severity logs ouput file if it exists otherwise create a new one
if [ -e ${no_severity_logs_file} ]; then
	msg "Renaming old no-severity logs output file to: ${no_severity_logs_file}-${timestamp}.${no_severity_logs_file_type}"
	mv ${no_severity_logs_file} ${no_severity_logs_file_name}-${timestamp}.${no_severity_logs_file_type}
	touch ${no_severity_logs_file}
else
	msg "Creating no-severity logs output file ${no_severity_logs_file}"
	touch $no_severity_logs_file
fi

# Delete old script log file
if [ -e ${script_logfile} ]; then rm ./$script_logfile
	msg ">> Previous script log file deleted."
fi
}

## Check the source file is a csv file i.e. does it have .csv at the end.
function check_is_csv_file () {
	msg "Checking if a .csv file"
	ext="${source_log_file##*.}"
	if [ $ext == csv ]
	then 
   	msg ">> Source file IS a CSV file."
  else
    msg ">> Source file is NOT a CSV file. Exiting.\n"
		exit 2;
  fi
}

## Get the total count of all log entries not including the header
function get_count_of_logs () {
	msg "Getting the total number of log entries in ${source_log_file}."
	number_of_rows=$(awk -F, 'END{print NR-1}' $source_log_file)
	msg ">> Total number of logs = ${number_of_rows}"
}

## [TO DO] Find the column the log severity entries are in
function check_column_severity_in () {
	msg "check_column_severity_in function called"
}

## Count the number of entries for INFO, WARNING, ERROR and those with no severity
function count_log_entries () {
	number_info_sev_entries=0
	number_warning_sev_entries=0
	number_error_sev_entries=0
	number_no_sev_entries=0

	# get count for each severity type
	msg "Parsing the log file for types of logs based on severity"
	while IFS="," read -r log_severity
		do
		if [ "${log_severity}" == "INFO" ]; then
			let number_info_sev_entries+=1
		elif [ "${log_severity}" == "WARNING" ]; then
			let number_warning_sev_entries+=1
		elif [ "${log_severity}" == "ERROR" ]; then
			let number_error_sev_entries+=1
		# elif [ "${log_severity}" == "" ]; then
		else
			let number_no_sev_entries+=1
		fi
	done < <(cut -d "," -f${severity_column} ${source_log_file} | tail -n +2)
	msg ">> Total number of INFO logs = ${number_info_sev_entries}"
}

## Display results to screen including calculating %'s
## also write to analysis file
function generate_analysis () {
	for log_severity in "${LOG_SEVS_CHECK[@]}"
	do
		write_results "################# \"${log_severity}\" LOG ANALYSIS ############"
		# configure correct messages to display based on severity being checked
		if [ "$log_severity" == "INFO" ]; then
			num_services=$number_info_sev_entries
		elif [ "$log_severity" == "WARNING" ]; then
			num_services=$number_warning_sev_entries
		elif [ "$log_severity" == "ERROR" ]; then
			num_services=$number_error_sev_entries
		elif [ "$log_severity" == "No Severity" ]; then
			num_services=$number_no_sev_entries
		fi

		# perform calculations and display/write results
		percentage_logs=0
		write_results ">> Total number of \"${log_severity}\" logs = $num_services"
		percentage_logs=`echo "scale=3 ; 100 * ($num_services/$number_of_rows)" | bc`
		write_results ">> % \"${log_severity}\" logs as part of total log count: ${percentage_logs}%"
		write_results "##########################################################"	
	done
}

## Write all log entries with no severity to the $no_severity_logs_file file
## for future analysis
function write_no_severity_logs_to_file () {
	msg "Writing \"No Severity\" logs to \"${no_severity_logs_file}\" for future analysis."

	# copy header row to the ${no_severity_logs_file} file
	head -n 1 ${source_log_file} >> ${no_severity_logs_file}

	## add lines with blank severities to ${no_severity_logs_file} file
	# awk -F "," '$182 == ""' ${source_log_file} >> ${no_severity_logs_file}
	awk -F "," -v pos_sev="$severity_column" '$pos_sev == ""' ${source_log_file} >> ${no_severity_logs_file}
}

## Yee olde main function calling everything
function main () {
	ask_removed_commas
	# set_debug # unhash if you ant to run debug only used when debugging
	backup_old_files
	check_is_csv_file
	get_count_of_logs
	# check_column_severity_in
	count_log_entries
	write_no_severity_logs_to_file
	generate_analysis
	
	msg "Analysis results are in the file \"${analysis_results_output}\2."
	msg "Logs with no defined severity logs are written to the
file \"${no_severity_logs_file}\" for further analysis."
	msg "\n                   *** Finished ****\n"
}

#******************************************************************************************
## end of defining functions
#******************************************************************************************

main "$@"