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

PerformanceGet.sh
