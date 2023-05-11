#!/bin/bash

#****************************************************************************#
# Title: gen_imap_graph.sh
# Description: generates graph (using gnuplot) containing average hourly 
#              imap4 logins
# Author: Mark O'Kane
# Date: 20 Sept. 2002
# Version: 1.0
# Location: XXXX
# History: Version 1.0 - created 20 Sept 2002
# Comments: This must be run on qaweb in order for output to be viewable on the 
#           web under http://qa.cpth.ie/$PRODUCT/$RELEASE/stats/
# Dependencies:
#    - gnuplot and txt2html required on machine 
#    - addup.sh (adds up data columns for use in averaging data), 
#    - get_imap_data.pl (parent script used to parse log files for required data)
#    - test env has the following env vars set - 
#      PRODUCT e.g. CSB
#      RELEASE e.g. 4.0
#****************************************************************************#

get_config ()
{
## GET test environment settings
tmp_product=`env | grep PRODUCT`
product=${tmp_product#*=*}

tmp_release=`env | grep RELEASE`
release=${tmp_release#*=*}
}


get_average_data ()
{
## This routine calcuates the average IMAP4 logins per hour and the duration
## of the details stored by the log file

rm *.grep
rm imap_login.txt

# first get all the data readins per on-the-hour reading and put
# them in a separate file per OTH reading e.g. 00.grep

for X in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23
do
    #echo "> grepping for $X:00"
	grep "$X:00" IMAP4Login1h.txt >> $X.grep
done


# next - for each file, use the add.sh file to sum all the data for use in 
# getting an average per OTH reading - also 
max_num=0
for X in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23
do
	
	# total all columns
	stat=`sh addup.sh 2 $X.grep`
	
	# Get total no. of occurrences for each OTH timestamp 
	# Required for calculating the average and also used to 
	# get no. of days the log file has run for
	
	total_oth_occurrences=`grep -c "$X:00" $X.grep`
	if [ "$total_oth_occurrences" -gt "$max_num" ]; then
		max_num=$total_oth_occurrences # gets duration of log file
	fi	
	
	#Calculate the average data for each OTH timestamp and print
	# the time stamp and average to file for use by gnu_plot
	let average_data="$stat / $total_oth_occurrences"
	echo "$X:00 $average_data" >> imap_login.txt
done
}


gen_graph ()
{
## this routine calls gnuplot to generate the graph based on details
## stored in the imap_login.txt file

#Get the date
plot_time=`date`

gnuplot <<EOF
set terminal gif
set output 'IMAP4Login1h.gif'
set title "Average IMAP4 Logins over a 24 hour period"
set xlabel "Time (Hour)"
set ylabel "Number of IMAP4 Logins"
set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
set grid
set border
plot "imap_login.txt" with lines
EOF

echo "<html>" > IMAP4Login.html
echo "<head>" >> IMAP4Login.html
echo "<title>Number of IMAP4 Logins</title>" >> IMAP4_Login.html
echo "<META HTTP-EQUIV="Expires" CONTENT="-1">" >> IMAP4Login.html
echo "<META HTTP-EQUIV="Pragma" CONTENT="no-cache">" >> IMAP4Login.html
echo "</head>" >> IMAP4Login.html
echo " " >> IMAP4Login.html
echo "<body bgcolor="#FFFFFF" text="#000000">" >> IMAP4Login.html
echo "<p><b><font face="Verdana" size="1">Average number of IMAP4 Logins per hour</b> - plotted on $plot_time</font></p>" >> IMAP4Login.html
echo "<p><font face="Verdana" size="1">The graph shows the average hourly IMAP4 logins over a 24 hour period for a log file covering a $max_num day period.<br> The information is sourced from the PERFORMANCE GET command.</font></p>" >> IMAP4Login.html
echo "<p><font face="Verdana" size="1">click <a href="imap_login.html">here</a> for details of the exact breakdown of the averages per hour</font></p>" >> IMAP4Login.html
echo "<p><font face="Verdana" size="1">click <a href="IMAP4Login1h.html">here</a> for details of <STRONG>ALL</STRONG> the readings taken over the $max_num day period</font></p>" >> IMAP4Login.html
echo "<p><img src="http://qa.cpth.ie/$PRODUCT/$RELEASE/stats/IMAP4Login1h.gif"></p>" >> IMAP4Login.html
echo "</body>" >> IMAP4Login.html
echo "</html>" >> IMAP4Login.html

txt2html imap_login.txt > imap_login.html
txt2html IMAP4Login1h.txt > IMAP4Login1h.html
cp imap_login.html /usr/local/apache/htdocs/$PRODUCT/$RELEASE/stats/
cp IMAP4Login1h.html /usr/local/apache/htdocs/$PRODUCT/$RELEASE/stats/
cp IMAP4Login.html /usr/local/apache/htdocs/$PRODUCT/$RELEASE/stats
cp IMAP4Login1h.gif /usr/local/apache/htdocs/$PRODUCT/$RELEASE/stats

echo "Finished generating graphs:  go to http://qa.cpth.ie/$PRODUCT/$RELEASE/stats/ to view."
}

#########################################################
###
### Call Functions
###
#########################################################

get_config
get_average_data
gen_graph
