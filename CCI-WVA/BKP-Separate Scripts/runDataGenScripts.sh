#!/usr/bin/bash
#******************************************************************************
# Title: RunDatGenScripts.sh
# Description:  used to run all scripts required to generate the dummy data for use in CCI Cassandra DB
#
# Author: Mark O'Kane
# Date: 16th May 2017
# Version: 1.0
# History:
#   Ver. 1.0 - 16th May 2017
# Comments:
# Dependencies: None
#******************************************************************************

# Edit the following as needed
shared_no_imsis=2 # the number of IMSIs to generate data for
shared_start_date=20170601000000 # the start date to generate the data from
shared_no_days=20 # the number of days to generate data for

debugVal=0 # set to 1 for debug to work
if [ "$debugVal" -eq 1 ] ;  then echo -e "\nshared_no_imsis = $shared_no_imsis\nshared_start_date = $shared_start_date \nshared_no_days = $shared_no_days"; fi

if [ "$debugVal" -eq 1 ] ;  then echo -e "\nRunning genBytestotalByAppDummyData-DAILY.sh $shared_no_imsis $shared_start_date $shared_no_days"; fi
(exec ./genBytestotalByAppDummyData-DAILY.sh $shared_no_imsis $shared_start_date $shared_no_days)

if [ "$debugVal" -eq 1 ] ;  then echo -e "\nRunning genBytestotalBySiteDummyData-DAILY.sh $shared_no_imsis $shared_start_date $shared_no_days"; fi
(exec ./genBytestotalBySiteDummyData-DAILY.sh $shared_no_imsis $shared_start_date $shared_no_days)

