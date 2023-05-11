#!/bin/bash

# System Monitoring Script
# 

# global variables
i=$1
current_date=`date '+%m%d%H%M'`
end_date=$2
Username=$3
Password=$4
server=$5
directory=$6
email=$7

if [ $# -ne 7 ]
then
	clear
    echo " "
    echo " Usage $0 [run id] [end time] [username] [password] [ftp server] [ftp base directory] [email]" 
	echo " "
	echo " [run id]             : suffix of the new directory that will be created in ftp site"
    echo " [end time]           : time in format of MONTH_DAY_HOUR_MINUTE e.g. 12310900"
    echo " [username]           : username to connect to ftp server"
    echo " [password]           : password to connect to ftp server"
    echo " [ftp server]         : fully qualified hostname of the ftp/web server"
    echo " [ftp base directory] : base directory in ftp/web server under which new directories will be created"
    echo " [email]              : email address of tester to be displayed in result web page"
    echo " "
	echo " Current Date in above format: `date '+%m%d%H%M'`"
    echo " "
	exit 2
fi

#create a working directory for this test
current_dir=`pwd`

if [ ! -d $current_dir/run$i ] 
then

	mkdir run$i
	workdir=$current_dir/run$i
	clear
	echo " "
	echo "Your working directory: $current_dir/run$i"
else
	clear
	echo " "
	echo "There is already a directory called run$i here!"
	echo " "
	ls -l | grep run$i
	echo " "
	echo "Please use a different TEST ID to create a different directory."
	echo " "
	exit 2
fi

####################################################################################

# create hosts and processes files from config.txt and copy those to workdir

if [ -e hosts ]
then
	rm hosts
fi

if [ -e processes ]
then
	rm processes
fi

cat config.txt | grep -v + >> hosts
cat config.txt | grep + >> processes

cp hosts $workdir
cp processes $workdir

####################################################################################

start_monitor () {

	# start monitoring scripts in all hosts
	for hosts in $( cat hosts )
	do
		rsh $hosts /usr/platform/sun4u/sbin/prtdiag > $workdir/prtdiag.$hosts

		rsh $hosts /opt/RICHPse/bin/se /opt/RICHPse/examples/virtual_adrian.se >> $workdir/se.$hosts &
		
		rsh $hosts iostat 60 >> $workdir/iostat.$hosts &
		
		rsh $hosts vmstat 60 >> $workdir/vmstat.$hosts &
		
	done
}

####################################################################################

control_monitor () {
	
        # runs for 10 minutes 

	current_min=0
	end_min=10

	until [ "$current_min" -ge "$end_min" ]
	do	
		for lines in $( cat processes )
		do
			host=`echo $lines | cut -f1 -d"+"`
			process=`echo $lines | cut -f2 -d"+"`
			#pid=`rsh $host ps -ef | grep $process | awk '{ print $2}'`
			#rsh $host /usr/local/bin/top | grep -w $pid >> $workdir/$host.$process
			rsh $host /usr/local/bin/top | grep $process >> $workdir/$host.$process
		done
		
		current_min=`expr $current_min + 1`
		clear
		echo " "
		echo "Your working directory   : $current_dir/run$i"
		echo " "
		echo "Monitoring start date : `cat $workdir/duration.txt`"
		#echo "Current date is          : $current_date"
		echo "Monitoring end date   : $end_date"
		#echo "Current minute            : $current_min"
		#echo "Monitoring end minute     : $end_min"
		diff=`expr $end_min - $current_min`
		echo " "
		echo "Your webpage will be updated after $diff minutes!"
		echo " "
		echo "Monitoring below hosts:"
        	echo " "
        	cat hosts
        	echo " "
        	echo "Monitoring below processes:"
        	echo " "
        	cat processes
        	echo " "
                sleep 60
        done

}
####################################################################################

kill_monitor () {

	# kill monitoring scripts

	for hosts in $( cat hosts )
	do
		kill -9 $(ps -ef | grep rsh | grep $hosts | awk '{ print $2 }') 
	done
	
	# kill top commands that are run against remote hosts
	kill -9 `ps -ef | grep rsh | grep top | awk '{ print $2 }'`
	kill -9 `ps -ef | grep rsh | grep top | awk '{ print $2 }'`
	
	for hosts in $( cat hosts )
	do
		rsh $hosts ps -ef | grep virtual_adrian.se | grep -v grep | awk '{ print $2 }' > se_pids
		for pids in $( cat se_pids )
		do
			rsh $hosts kill -9 $pids
		done
	done
	
	
	sleep 2
	echo RSH scripts are all killed...
}

##################################################################################

modify_iostat () {
	# modify iostat outputs for all hosts to draw graphs 
	
	for hosts in $( cat hosts )
	do

		sed '/cpu/d' $workdir/iostat.$hosts > $workdir/iostat.$hosts.tmp
		sed '/id/d' $workdir/iostat.$hosts.tmp > $workdir/iostat.$hosts.final	
		
		# check if the monitored host is Netra or Ultra
		j=`rsh $hosts /usr/platform/sun4u/sbin/prtdiag | head -1 | grep Netra | wc -l`
		
		if [ $j == 0 ]
		then
			awk '{ print $18 }' $workdir/iostat.$hosts.final > $workdir/$hosts.id.cpu
			awk '{ print $17 }' $workdir/iostat.$hosts.final > $workdir/$hosts.wt.cpu
			awk '{ print $16 }' $workdir/iostat.$hosts.final > $workdir/$hosts.sy.cpu
			awk '{ print $15 }' $workdir/iostat.$hosts.final > $workdir/$hosts.us.cpu
		fi
		
		if [ $j == 1 ]
		then
			awk '{ print $12 }' $workdir/iostat.$hosts.final > $workdir/$hosts.id.cpu
			awk '{ print $11 }' $workdir/iostat.$hosts.final > $workdir/$hosts.wt.cpu
			awk '{ print $10 }' $workdir/iostat.$hosts.final > $workdir/$hosts.sy.cpu
			awk '{ print $9 }' $workdir/iostat.$hosts.final > $workdir/$hosts.us.cpu
		fi
		
		
		#rm workdir/iostat.$hosts.tmp $workdir/iostat.$hosts.final

        done
     
}
####################################################################################

modify_vmstat () {

	# modify vmstat outputs for all hosts to draw graphs

	for hosts in $( cat hosts )
	do

	        sed '/cpu/d' $workdir/vmstat.$hosts > $workdir/vmstat.$hosts.tmp
        	sed '/id/d' $workdir/vmstat.$hosts.tmp > $workdir/vmstat.$hosts.final

	        awk '{ print $5 }' $workdir/vmstat.$hosts.final > $workdir/$hosts.memory.tmp
		
		rm $workdir/$hosts.memory
		
		while read line; do
    			line2=`expr $line / 1024`
    			echo $line2 >> $workdir/$hosts.memory
		done < $workdir/$hosts.memory.tmp

        	#awk '{ print $5 }' $workdir/vmstat.$hosts.final > $workdir/$hosts.memory.tmp
      
		rm $workdir/vmstat.$hosts.tmp $workdir/vmstat.$hosts.final
	done
}
####################################################################################

modify_top () {

	# modify top outputs for all processes in specific hosts

	for lines in $( cat processes )
	do
		host=`echo $lines | cut -f1 -d"+"`
		process=`echo $lines | cut -f2 -d"+"`
		awk '{ print $10 }' $workdir/$host.$process > $workdir/$host.$process.cp
		cat $workdir/$host.$process.cp | cut -f1 -d"%" > $workdir/$host.$process.cpu
		awk '{ print $6 }' $workdir/$host.$process > $workdir/$host.$process.me
		cat $workdir/$host.$process.me | cut -f1 -d"M" > $workdir/$host.$process.mem
	done
}

####################################################################################

draw_iostat_vmstat () {
	
	# change to the working directory
	cd $workdir
	
	# call gnuplot to draw free memory, idle cpu and i/o wait graphs
	echo "Drawing CPU and Memory graphs for hosts that are monitored." 	
	
	for hosts in $( cat hosts )
	do
		../draw_cpu_memory.sh $hosts
	done
	sleep 2
}
####################################################################################

draw_top () {

	# call gnuplot to draw %CPU usage and free memory size for the process monitored
	
	echo "Drawing % CPU usage and free memory graphs for processes that are monitored." 	
	
	for lines in $( cat processes )
	do
		host=`echo $lines | cut -f1 -d"+"`
		process=`echo $lines | cut -f2 -d"+"`
		../draw_process.sh $host $process
	done
	sleep 2
	# return back to home directory
	cd ..
}

####################################################################################

create_web () {


	# create index.html file for this test and move it to the working directory
	# when you make an ftp connection to qaweb as webmaster your directory is /home/webmaster
	# but when you want to create a link in qawebsite, you should point under /home/webmaster/qawebsite
	
	./cr_index.htm.sh $server $directory $i $email > index.htm 
	sleep 1
	mv index.htm $workdir
	
	echo "Sending results to ftp machine."
	sleep 2
	./ftp $i $Username $Password $server $directory
	# remove temporary se pids file
	rm se_pids
}

####################################################################################

# main part of the script

#log the start date
echo "`date`" > $workdir/duration.txt

until [ "$current_date" -ge "$end_date" ] # Tests condition here, at top of loop.
do
	
	# functions 
	start_monitor 
	control_monitor
	kill_monitor
	modify_iostat
	modify_vmstat
	modify_top
	draw_iostat_vmstat
	draw_top
	create_web
	
	# get the current date to control until loop
	current_date=`date '+%m%d%H%M'`	
done
#log the finish date
echo "`date`" >> $workdir/duration.txt
# remove temporary files that are created to distinguish hosts and processes from config.txt file.
rm hosts processes

####################################################################################
