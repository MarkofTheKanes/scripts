#!/usr/bin/perl 
use strict;

#************************************************************
# Title: get_imap_data.pl
# Description: Script to parse PERFORMANCE GET results 
#	and generate a graph based on this information
# Author: Mark O'Kane
# Date: 16th Sept 2002
# Version: 0.2
# Location: <later>
# History:  ver. 0.1 - created 16th Sept. 2002
#           ver. 0.2 - 25th Sept 2002 - added "get_data_avg"
#                for averaging of data for a 24 hr period
# Comments:
# Dependencies: gen_imap_graph.sh to generate th graph using 
#               gnuplot
# To Do:  1. enable generation of multiple graphs for multiple
#         data objects e.g. IMAPxxxx, POP3xxxx
#         2. Enable it to read directly from telnet mgmt port
#         3. make it capable of reading from multiple log files
#************************************************************

#************************************************************
# Set variables for script
#************************************************************

# DEFINE LOG FILE TO SEARCH AND SEARCH STRING TO BE USED
my $search_item="IMAP4Login1h";
my $src_log_file="scc062.log";

# USED TO STORE LOG TIMESTAMPS AND DATA READING FOR USE BY GNUPLOT
my $gnu_plot_out="${search_item}.txt";


## ARRAYS
# USED TO STORE SRC LOG FILE - EASIER TO PARSE INFO
my @file_array;
# USED TO STORE ON-THE-HOUR TIMESTAMPS FOR PARSING
my @timestamp_array;
# USED TO STORE FINAL ON-THE-HOUR DATA FIGURES
my @final_log_array;
# USED TO STORE LOG DATA FOR EACH ON-THE-HOUR TIMESTAMP
my @log_array;

# temp array for storing log data during parsing of required data
my @tmp_log_array1;


#************************************************************
# define subroutines
#************************************************************
sub delete_old_files
{
	# delete previously generated files
	if ( -e $gnu_plot_out ) {
		unlink $gnu_plot_out;
		print "> *** $gnu_plot_out deleted ***\n\n";
	} else { print "> No previously generated files exist\n\n"; 
	}

}

sub get_timestamps
{
	
	# open src log file to parse on-the-hour timestamps i.e. 23:00:00, 00:00:00 etc.
	if ( -e $src_log_file ) {
		open SRC_FILE, "< $src_log_file" or die "Cannot open $src_log_file: $!\n";
	}
	
	# write file contents to an array for ease of text processing
	while (<SRC_FILE>) {
		push(@file_array, $_);
	}
	
	# put on-the-hour timestamps into an array
	#my @tmp_search_timestamps=qw(00:00 01:00 02:00 03:00 04:00 05:00 06:00 07:00 08:00 09:00 10:00 11:00 12:00 13:00 14:00 15:00 16:00 17:00 18:00 19:00 20:00 21:00 22:00 23:00);
	foreach (@file_array) {
		if (/ [0-2][0-9]:00/) {
			push(@timestamp_array, $&);
			#print "found timestamp $_ \n";
		}
	}
		
	# clean up
	close SRC_FILE;
	#print "timestamp_array \n";
}


sub get_search_item
{
	# Get log details for search item for each on-the-hour timestamp
	
	my $elem_counter=0;
	my $search_item_count=0; # tmp for checking of search
	my $found_timestamp_flag=0;
	my $element=0;
	
	foreach $element (@file_array) {
		#print "element = $element\n";
		if ($element =~ /($timestamp_array[$elem_counter])/) {
			$found_timestamp_flag=1;
			#print "********* SET FOUND_TIMESTAMP TO 1 *********\n";
			$elem_counter++;
		} 
		
		if (($found_timestamp_flag == 1) && ($element =~ /($search_item)/)) {
			# write matching log entry to log_array
			push(@log_array, $element);
			
			#reset found_timestamp_flag
			$found_timestamp_flag=0;
		}

	}
	
	my $end_count=$#timestamp_array+1;
	#print "> No. of search items = $end_count\n\n";
	#print "@log_array \n";
	
}

sub prep_logs_4_gnuplot
{
	## get_on-the-hour data reading
	
	# first split data readings from text field
	foreach (@log_array) {
		if ($_ =~ /VALUE=/) {
			push(@tmp_log_array1, $');
		}
	}
	
	# next split 24 field data readings into separate fields and assign first reading to
	# final_log_array for use in getting average per hour
	my $counter=0;
	foreach (@tmp_log_array1) {
		#print "\$_ = $_";
		$final_log_array[$counter] = (split /,/, $_) [0];
		#print " final_log_array[$counter] = $final_log_array[$counter] \n";
		$counter++;
	}	
	
}	


sub gen_all_data_file
{
	
	# Generate  file containing on-the-hour time stamps and all log data 
	my $counter=0;
	
	# open 
	open ALL_LOG_FILE, "> $gnu_plot_out" or die "Cannot open $gnu_plot_out: $!\n";
	foreach (@timestamp_array) {
		print ALL_LOG_FILE "$timestamp_array[$counter] $final_log_array[$counter]\n";
		#print "> writing \"$timestamp_array[$counter] $final_log_array[$counter]\" to $gnu_plot_out \n\n ";
		$counter++;
	}
	close ALL_LOG_FILE;

}

sub close_fh
{
	
	# close all filehandles
	close SRC_FILE;
	close ALL_LOG_FILE;
	
}

sub gen_graph
{
	# call gen_imap_graph.sh sript to generate the gnuplot graph
	if ( -e "./gen_imap_graph.sh" ) {
		my $status = system "./gen_imap_graph.sh";
		if ( $status == 0 ) {
			print "Exit status was \"successful\". \n\n";
		} else {
			print "Exit status was unsuccessful: $status\n\n";
		}
	} else {
		print "./gen_imap_graph.sh does not exist $!";
	}

}

#********************************************************
# call required routines
#********************************************************

## Delete previously generate files
delete_old_files;

## get on-the-hour time stamps i.e. xx:00:00 n from the
## source log file and write them to the relevant .out file
##  - required to generate graph
get_timestamps;

## Get search item relevant to the hourly timestamp
get_search_item;

## prepare output files for use with gnuplot
prep_logs_4_gnuplot;

## print file containing all the required data
gen_all_data_file;

## call the shell script to generate the gnuplot graph
gen_graph;

# close filehandles (just to be sure)
close_fh;

