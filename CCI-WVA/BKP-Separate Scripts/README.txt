Mark O'Kane - 19th May 2017 v1

The scripts are bash scripts and as such need a unix env supporting bash to run them e.g. cygwin if you are on the windows platform.

To run both scripts at the same time using the same criteria:
1. Edit the "RunDataGenScripts.sh" script and set the desired values for:

	shared_no_imsis=2 							# the number of IMSIs to generate data for
	shared_start_date=201611170000 	# the start date to generate the data from
	shared_no_days=2 							# the number of days to generate data for
	
2. Exit back to the command line and run the script using
	./runDataGenScripts.sh

To run the scripts separately
1. on the command line execute
	./genBytestotalByAppDummyData-DAILY.sh [No. IMSis] [Start Date] [No. Days] 
		e.g. ./genBytestotalByAppDummyData-DAILY.sh 3 20170601000000 20
	The output file will be named "BytestotalByApp_DummyData-DAILY"
	
	or
	
	./genBytestotalBySiteDummyData-DAILY.sh [No. IMSis] [Start Date] [No. Days] 
		e.g. ./genBytestotalBySiteDummyData-DAILY.sh 3 20170601000000 20
	The output file will be named "BytestotalBySite_DummyData-DAILY"

run the scripts without arguments to get more details.


