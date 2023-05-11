Log onto the CCI VM (172.27.12.52 in this case) as root/ibmgsc

PREPARATION:
============
Copy the required scripts and data to the VM using Filezilla or some other secure ftp client. I copied the originals to the /root/cciImage/share location

Scripts: 
o import_metrics.sh - import the historical metrics to the tnf.hrcc_historical_d_1 table
o test_metrics_import.sh - check the historical metrics import worked by testing the API
o import_subscriberprof.sh - import the subscriber profile into the tnf.hrcc_subscriber table
o test_subscriberpro_import.sh - check the subscriber profile import worked by testing the API
o test_all_import.sh - tests returning of both the metrics data and the subscriber profile data

Data Files:
o GeneratedJSON.csv - contains historical data metrics for the IMSI 272211221122333 between the dates 20171016000000 (16th Oct 2017) and 20171115000000 (15th Nov. 2017)
o subscriber_profile.csv - the subscriber profile data for IMSI 272211221122333

Next ensure the files are in unix format. If not, use the dos2unix utility to convert them or edit them with vi and run :set ff=unix. There may be some manual editing to be done e.g. rogue ,'s to be removed. Give the files a visual once over to check them.

Get the docker image ID by running: 

	[root@docker2 share]# docker ps

you should get something akin to the following returned:

	CONTAINER ID IMAGE         COMMAND                CREATED            STATUS            PORTS                  NAMES
	ddc41703a861 cas-demo-flat "/docker-entrypoint.s" About a minute ago Up About a minute 0.0.0.0:7000-7001->7000-7001/tcp, 0.0.0.0:7199->7199/tcp, 0.0.0.0:8009->8009/tcp, 0.0.0.0:8449->8449/tcp, 0.0.0.0:9042->9042/tcp, 0.0.0.0:9160->9160/tcp   sad_leakey

In this case ddc41703a861 is the ID we need. Copy the required files to the docker image as follows:

	[root@docker2 share]# docker cp <FILE> <CONTAINER ID>:/<LOCATION>/

	In this case I ran 
		[root@docker2 share]# docker cp import_subscriberprof.sh ddc41703a861:/home/boss/
		[root@docker2 share]# docker cp subscriber_profile.csv ddc41703a861:/home/boss/
		etc..

next open a bash session in docker by running:

		[root@docker2 share]# docker exec -it ddc41703a861 bash (replace the ID with your versions ID)
	and then
		cd /home/boss
	
	you should see your shell prompt change to something akin to 

	root@ddc41703a861:/home/boss#

list all the files to ensure they were successfully copied over to the docker image. I see 
	root@ddc41703a861:/home/boss# ls -l
	total 64
	-rwxr-xr-x. 1 root root 29553 Oct 31 15:08 GeneratedJSON.csv
	-rwxr-xr-x. 1 root root   162 Oct 20 21:20 import_metrics.sh
	-rwxr-xr-x. 1 root root   158 Oct 31 14:53 import_subscriberprof.sh
	-rwxr-xr-x. 1 root root   693 Oct 31 15:36 subscriber_profile.csv
	-rw-r--r--. 1 boss boss   279 Oct 31 15:58 test.cookie
	-rwxrwxrwx. 1 boss boss   272 May 24 12:25 test.sh
	-rwxr-xr-x. 1 root root   387 Oct 31 15:09 test_all_import.sh
	-rwxr-xr-x. 1 root root   272 Oct 21 12:10 test_metrics_import.sh
	-rwxr-xr-x. 1 root root   218 Oct 31 15:12 test_subscriberpro_import.sh
	root@ddc41703a861:/home/boss#

IMPORTING DATA:
===============
Import the subscriber profile details...
	root@ddc41703a861:/home/boss# bash ./import_subscriberprof.sh ./subscriber_profile.csv
	You will see the following returned....
	
		Using 3 child processes
		Starting copy of tnf.hrcc_subscriber with columns [imsi, msisdn, age, gender, handset, last_updaname, surname, date_of_birth, address_1, address_2, ethnicity, highest_level_of_education, emplo tenure, credit_rating_grade, monthly_arpu, customer_type, churned_flag, brand, fixmobilebundlef
		Processed: 1 rows; Rate:       2 rows/s; Avg. rate:       2 rows/s
		1 rows imported from 1 files in 0.416 seconds (0 skipped).
		root@ddc41703a861:/home/boss# 


Import the historical metrics data
	root@ddc41703a861:/home/boss# bash ./import_metrics.sh ./GeneratedJSON.csv
	you'll see 
		Using 3 child processes
		Starting copy of tnf.hrcc_historical_d_1 with columns [imsi, timeid, ibmaaf_bytestotal_by_cell_s
		Processed: 31 rows; Rate:      54 rows/s; Avg. rate:      80 rows/s
		31 rows imported from 1 files in 0.387 seconds (0 skipped).
		
CHECK THE IMPORT WORKED:
========================
Kick off a cqlsh session and run the following:
	
	root@ddc41703a861:/home/boss# cqlsh
	Connected to Test Cluster at 127.0.0.1:9042.
	[cqlsh 5.0.1 | Cassandra 3.0.9 | CQL spec 3.4.0 | Native protocol v4]
	Use HELP for help.
	cqlsh> use tnf;
	cqlsh:tnf> describe tables;

	hrcc_subscriber  hrcc_msisdn_imsi       hrcc_historical_d_1  flyway_info
	cas_properties   hrcc_historical_min_5  hrcc_historical_h_1
	
	check the sub profile import was successful...
	
		cqlsh:tnf> select * from hrcc_subscriber;

		imsi| account_number | address_1| address_2 | age | brand | car_owneate_group_name | credit_rating_grade | customer_type | customer_value | data_offering | d | first_name | fixmobilebundleflag | gender | handset  | highest_level_of_education | last_upda plan | plan_name | sms_offering | subscriber_name | surname | tenure | voice_offering
		-----------------+----------------+-----------------------+------------+------+-------+------------------------+---------------------+-----------------+----------------+--------------------+---+------------+---------------------+--------+----------+----------------------------+----------------+-----------+--------------+-----------------+---------+--------+----------------
		272211221122333 |      964347550 | 1177 S. Beltline Road | Coppel, TX | null |  null |      nulteady - Family |                null | Consumer Mobile |           null | 4G All You Can Eat |   |       Paul |                null |      M | iPhone 7 |            Bachelor Degree | 201709311 null |      null |         null |            null |   Kelly |   null |           null
	 
	check the historical data import was successful....
	
		cqlsh:tnf> select * from hrcc_historical_d_1;
		dt| sgm | imsi| timeid| ibmaaf_bytestotal|ibmaaf_bytestotal_b|ibmaaf_bytestotal_by_cell_sitename| ibmaaf_bytestotbmaaf_bytestotal_geran_topapps | ibmaaf_bytestotal_utran_topapps........
		
		lots of results will be returned e.g 
		
		201710210000 |   0 | 272211221122333 | 20171021000000 |  {"metricId":"ibmaaf_bytestotal","counters":[{"value":[71055808]}]} | null |                     {"metricId":"ibmaaf_bytestotal_by_cell_sitename","counters":[{"breakdown":"Belt Line Road","value":[3991158]},{"breakdown":"Las Colinas","value":[4601464]},{"breakdown":"Irving","value":[22556593]},{"breakdown":"Valley Ranch","value":[31732031]},{"breakdown":"Market Center","value":[0]},{"breakdown":"West Dallas","value":[0]},{"breakdown":"Cockrell Hill","value":[0]}]} |                        null |                     null |                             null |  
		

CHECK THE API CALL RETURNS THE CORRECT RESULTS:
===============================================
Run the scripts as follows:

	root@ddc41703a861:/home/boss# ./test_metrics_import.sh
	
  which should return something akin to
	
	{"token":":Ym9zcw:ez89k:rhIpZRyNHGMeFMAorQuCqLVycDzVy2mRYmqc80s4lU3Wom5pJ9OgkqHEugamf_So-NnAMtxwOo5vN8f7FloX8w"}	[{"imsi":"272211221122333","time":"20171103000000","metrics":[{"metricId":"ibmaaf_bytestotal","counters":[{"value":[113876826]}]},{"metricId":"ibmaaf_bytestotal_by_cell_sitename","counters":[{"breakdown":"Belt Line Road","value":[3462197]},{"breakdown":"Las Colinas","value":[2389562]},{"breakdown":"Irving","value":[9170138]},{"breakdown":"Valley Ranch","value":[2920650]},{"b...
	etc
	
	root@ddc41703a861:/home/boss# ./test_subscriberpro_import.sh
	
  which should return something akin to
	
	{"token":":Ym9zcw:ez89l:xxwZcBBDhVZ73XKCMYXVtRDNdjlkBcn3zG44a-267fBBR621uznoXqPiUaPJvpWctqNWhy3_tUbBiht4ix1pVg"}
	[{"imsi": "272211221122333", "account_number": "964347550", "address_1": "1177 S. Beltline Road", "address_2": "Coppel, TX", "age": null, "brand": null, "car_owner": null, "churned_flag": "LOW", "contract": null, "contract_type": "Bill Pay", "corporate_account_name": "Early Adopter, LTV High", "corporate_group_name": "Steady - Family", "credit_rating_grade": null, "customer_type": "Consumer Mobile", "customer_value": null, "data_offering": "4G All You Can Eat", "date_of_birth": null, "dob": "LOW", "employment_status": null, "estimated_income": nul....
	etc

	or check everything is returned:
	
	root@ddc41703a861:/home/boss# ./test_all_import.sh
	{"token":":Ym9zcw:ez89m:L3uqwghJpL7Ti0UTyjAMyrEtirHmTPI9csy90odP9-31V3DWxiOvMS2vrdKRZMX36rJPLcrVPaxgDibEHWWwLA"}
	[{"imsi":"272211221122333","time":"20171027000000","metrics":[{"metricId":"ibmaaf_bytestotal","counters":....
	etc
	.
	]}]
	[{"imsi": "272211221122333", "account_number": "964347550", "address_1": "1177 S. Beltline Road", "address_2": "Coppel, TX", "age": null, "brand": null, "car_owner": null, "churned_flag": "LOW", "contract": null, "contract_t
	etc
	..
	: null}]
	
	
		