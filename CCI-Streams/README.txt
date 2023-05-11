____________________________________________________________________

Some notes on the Cassandra docker image from Eng:

The usual RHEL configs are used for network, IP is set in /etc/sysconfig/network-scripts/ifcfg-enp0s3:
 
TYPE="Ethernet"
BOOTPROTO="none"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"cql -e "copy tnf.test from 'test-load.txt' with header=true and delimiter='|'"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="enp0s3"
UUID="3ca8a20f-a2f8-4b67-8ca7-852dd38eb23f"
DEVICE="enp0s3"
ONBOOT="yes"
IPADDR="172.30.9.249"
PREFIX="24"
IPV6_PEERDNS="yes"
IPV6_PEERROUTES="yes"
 

1. Cassandra DB configuration file location is: /opt/cassandra/cassandra.yaml.custom
   I do not think that any changes required in cassandra db.
 
2. Web server configuration file locations is: /opt/tnf/apps/cas-main-var/cfg-cas.properties
    The 'webserver.port' value may be change as required per network set up.
 
3. The csv data may be loaded using cqlsh (Cassandra query language shell).
    This utility is shipped with any cassandra distributive.
 
 
In /home/boss/bin or /root/hrccwithdata/docker/home/boss directory a script to run cqlsh was created

CQLSH_HOST=node1 /usr/lib/cassandra/bin/cqlsh -u cassandra -p cassandra "$@"
 
In order to load data using this utility csv file with header should not include # at first line like we usually do in provisioning.
 
Example of loading data to cassandra table:
 
test-load.cql:
 
use tnf;
drop table if exists test;
create table test (test int primary key, name text);
copy test from 'test-load.txt' with header=true and delimiter='|';
select * from test;
 
test-load.txt
 
test|name
1|first
 
$/home/bin/cql -f test-load.cql
 
The output should look:
 
[boss@hrcc ~]$ ./test-load.sh
  Using 1 child processes
  Starting copy of tnf.test with columns [test, name].
  Processed: 1 rows; Rate:       0 rows/s; Avg. rate:       1 rows/s
  1 rows imported from 1 files in 1.130 seconds (0 skipped).
    test | name
    ------+-------
    1 | first
   (1 rows)
 
 
if table already exists then one can start import with one liner:
 
[boss@hrcc ~]$ cql -e "copy tnf.test from 'test-load.txt' with header=true and delimiter='|'"
 
Using 1 child processes
Starting copy of tnf.test with columns [test, name].
Processed: 1 rows; Rate:       1 rows/s; Avg. rate:       2 rows/s
1 rows imported from 1 files in 0.557 seconds (0 skipped).
 

The amount of data loaded with this command should not be too big
 
If network is set up correctly the cqlsh utilty may be invoked outside of the VM, for instance
download cassandra
wget http://ftp.heanet.ie/mirrors/www.apache.org/dist/cassandra/3.0.13/apache-cassandra-3.0.13-bin.tar.gz
tar xvfz apache-cassandra-3.0.13-bin.tar.gz
cd apache-cassandra-3.0.13/bin
CQLSH_HOST=172.30.9.249 ./cqlsh -u cassandra -p cassandra -e 'select * from tnf.test limit 1'
 
Use IP address assigned to vm istead of 172.30.9.249.
 
 
I tested the import export from csv, and in order to load data one have to increase batch size in
/opt/cassandra/cassandra.yaml.custom file.
 
The following two lines should set big enough batch size
 
batch_size_fail_threshold_in_kb: 5000
batch_size_warn_threshold_in_kb: 500
 
 
Then one can load data from pipe separated files. The example files attached to this email.
 
In the attached file I put cas_properties.txt these properties make hrcc properties persistent, by default some properties expire.
 
The command to load cas_properties into cassandra db is:
 
  cqlsh -e "copy tnf.cas_properties from 'cas_properties.txt' with header=true and delimiter='|'"
 
The same way one can import pipe separated data into historical tables:
 
  cqlsh -e "copy tnf.hrcc_historical_h_1 from 'hrcc_historical_h_1.txt' with header=true and delimiter='|'"

I imported your csv with my script '/share/import.sh' which is:
 
  i=$1
  columns=$(head -n 1 $i | tr '|' ',')
  cqlsh -e "copy tnf.hrcc_historical_d_1 ($(echo $columns))  from '$(echo $i)'   with header = true and delimiter = '|'"
 
 
I added a local directory 'share' which should be mounted by run.sh command to /share in docker container.
Right now import.sh and your csv stored in shared directory.
 
 
in order to run my import.sh script first run docker image and switch to docker container:
 
  docker exec -it cas-demo-flat bash
 
  #cd /root/cciImage/share
  root@3d9790afc534:/share# ./import.sh BytestotalByAppsAndSites_DummyData-DAILY.csv

The output looks like this:
 
root@3d9790afc534:/share# ./import.sh BytestotalByAppsAndSites_DummyData-DAILY.csv
  Using 16 child processes
  Starting copy of tnf.hrcc_historical_d_1 with columns [imsi, timeid, ibmaaf_bytestotal_by_cell_sitename, ibmaaf_bytestotal_by_application, dt, sgm].
  Processed: 40 rows; Rate:      71 rows/s; Avg. rate:     104 rows/s
  40 rows imported from 1 files in 0.385 seconds (0 skipped).
 
I checked input size and it was 40 lines:
  root@3d9790afc534:/share# wc -l BytestotalByAppsAndSites_DummyData-DAILY.csv
  41 BytestotalByAppsAndSites_DummyData-DAILY.csv
  #exit
 
In order to delete all data from table one can run a command from outside of docker command prompt
 
  docker exec cas-demo-flat cqlsh -e 'truncate tnf.hrcc_historical_h_1'