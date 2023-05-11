#!/usr/bin/ssh-agent /usr/bin/bash


###################################################################################
###################################################################################
###										###
###   SECUREMON 1.4 by Stuart.Findlay@cp.net					###
###   ======================================					###
###										###
###   A secure version of the unimon universal monitoring script		###
###										###
###   Last updated 15th June 2004						###
###										###
###   Instructions for use							###
###										###
###   1. Make a 'bin' directory with the following binaries and scripts:	###
###										###
###      	unimon.sh							###
###      	draw_cpu_memory.sh						###
###		draw_process.sh							###
###		make_ifs_web.sh							###
###		make_web.sh							###
###		gnuplot								###
###		mins								###
###		secs								###
###										###
###	 and add this directory to your $PATH. Alternatively place the above	###
###	 files in a bin directory which already exists in your $PATH		###
###										###
###   2. Create .unimonrc file in directory from which you will run this 	###
###	 script. Each line in the .unimonrc file has the format			### 
###      server_name+component+process1+process2 				###
###	 e.g. hp16+SMLS+syncmld+capd+pabd					###
###      with as many processes defined as you want. For examnple, you may want ###
###	 monitor capd and pabd with syncmld or DS processes with any other 	###
###   	 component. Note that in the case of IFS, PS and FS the component	###
###	 name has an affect on how data is gathered. In the other cases it is 	###
###	 used for web output.							###
###										###
###   3. Unimon uses secure shell (ssh) to connect to the remote machine.	###
###	 Create an rsa key pair as detailed in Bob Dowd's ssh instruction page: ###
###	 https://intranet.cp.net/dev-SantaMonica/cgi-bin/wiki?Setup_Ssh and 	###
###	 copy the public key to the ~/.ssh/authorized_keys file on the 
###	 server(s). Next create a file called "keys" in the same directory as   ###
###	 .unimonrc and enter a list of full paths to the private key files you  ###
###	 you will need for the test run with each key on a new line e.g.:	###
###	 /home/sfindlay/.ssh/gould2host01					### 
###	 /home/sfindlay/.ssh/gould2gallah					### 
###										###
###   4. To use Unimon's optional core monitor you can create a file, again in  ###
###	 same directory as .unimonrc, called cores. This file will have list of ###
###	 servers and paths (seperated by '+') in which to check for cores e.g.:	###
###	 host01+/opt/criticalpath/cal/log					###
###	 gallah+/opt/criticalpath/tomcat/bin					###
###	 This will cause the core file to be given a date stamp extension and 	###
###	 a mail to be set to the address supplied in the command line		###
###										###
###   5. Run unimon.sh as directed by the usage message. Do not run as root as  ###
###	 only you have ssh permissions from your public/private key pair.	###
###										###
###										###
###################################################################################
###################################################################################

zero_mins=`mins`

###################################################################################

# Usage check

if [ $# -ne 3 ]
then
        #clear
        echo " "
        echo " Usage $0 [run id] [end date] [email]"
        echo " "
        echo " [run id]             : suffix of the new directory that will be created in ftp site"
        echo " [end date]           : time in format of MONTH_DAY_HOUR_MINUTE"
        echo " [email]              : email address of tester to be displayed in result web page"
        echo " "
        echo " Current Date in above format: `date '+%m%d%H%M'`"
        echo " "
        exit 2
fi

runid=$1
end_date=$2
email=$3
current_date=`date '+%m%d%H%M'`


#create a working directory for this test
current_dir=`pwd`

if [ ! -d $current_dir/$runid ]
then
        mkdir $current_dir/$runid
        workdir=$current_dir/$runid
	echo "`date`"  > start.txt
	cp start.txt $workdir/duration.txt
else
        echo " "
        echo "There is already a directory called $runid in $current_dir!"
        echo " "
        ls -l | grep $runid
        echo " "
        PS3="Please choose an option: "
	
	select action in Append Exit 
	do
		case "$action" in 
		  Append)	workdir=$current_dir/$runid; zero_mins=`cat $workdir/zero_mins`; cp start.txt $workdir/duration.txt; break;;
		  Exit  )	exit 2;;
		  *     )	echo "Invalid selection!";;
		esac
	done

fi

echo " "
echo "Your working directory: $current_dir/$runid"
echo "$zero_mins" > $workdir/zero_mins

for lines in $( cat keys )
do
	ssh-add $lines
done

####################################################################################

monitor_core () {
	for lines in $( cat cores )
	do
        	# parse host name and directory
        	c_host=`echo $lines | cut -f1 -d"+"`
        	directory=`echo $lines | cut -f2 -d"+"`
        	echo "Core monitor: $c_host:$directory"
        	control_core=`ssh $c_host ls -l $directory/core 2> /dev/null | wc -l`
        	if [ $control_core -eq 1 ]
        	then
                	now=`date '+%m%d%H%M'`
                	ssh $c_host mv $directory/core  $directory/core.$now
	
                	echo "There is a core file under $directory on $c_host!"
                	echo "From: Core.Monitor@cp.net" > msg.0
                	echo "Subject: Core under $directory directory on $c_host!!!" >> msg.0
                	echo "" >> msg.0
                	echo "core moved to $directory/core.$now" >> msg.0
	
                	# enter a list of notification email addresses here
                	smtptst -spuma.dub0.ie.cp.net f\'disk.monitor@cp.net\'r\'$email\'S0Q
        	fi
        	#echo "$control_core"
	done
}

####################################################################################

disk_monitor() {
	allowed_disk_usage=95

        for lines in $( cat .unimonrc )
        do
                now_mins=`mins $zero_mins`
                host=`echo $lines | cut -f1 -d"+"`
		
		os=`ssh $host uname`
		if [ "$os" = "SunOS" ]
		then
        		highest_disk_usage=`ssh $host df -k | egrep -v 'winworld|net|capacity' | awk '{ print $5 }' | sort -n | tail -1 | cut -f1 -d"%"`

		elif [ "$os" = "HP-UX" ]
		then
        		highest_disk_usage=`ssh $host bdf | egrep -v 'winworld|net|capacity' | awk '{ print $5 }' | sort -n | tail -1 | cut -f1 -d"%"`

		fi

        	echo "$host:$highest_disk_usage"

        	if [ $highest_disk_usage -gt $allowed_disk_usage ]
        	then
                	echo "Disk problem on $host!"
                	echo "From: Disk.Monitor@cp.net" > msg.0
                	echo "Subject: High Disk Usage ( > $allowed_disk_usage) on $host!!!" >> msg.0
                	# enter a list of notification email addresses here
                	smtptst -spuma.dub0.ie.cp.net f\'disk.monitor@cp.net\'r\'$email\'S0Q
        	fi
	done
}

####################################################################################

make_web_pages() {
        for lines in $( cat .unimonrc )
        do
		host=`echo $lines | cut -f1 -d"+"`
		component=`echo $lines | cut -f2 -d"+"`
		if [ "$component" = "IFS" ]
		then
			make_ifs_web.sh $workdir $lines $email > $workdir/$host.$component.shtml 
		else
			make_web.sh $workdir $lines $email > $workdir/$host.$component.shtml 
		fi
	done

	if [ -f publish ]
	then
		location=`cat publish`
		scp $workdir/*html $location
		scp $workdir/*.gif $location
	fi
}

####################################################################################

draw_system_data() {
	cd $workdir
        # call gnuplot to draw free memory, idle cpu and i/o wait graphs
        echo "Drawing CPU and Memory graphs for $host."

        draw_cpu_memory.sh $host

	cd ..
}

####################################################################################

draw_process_data() {
	cd $workdir
	
	if [ "$proc" = "httpd" ]
	then
	        for processes in $(cat processes)
		do
                	draw_process.sh $host $processes
        	done
	else
		draw_process.sh $host $proc
	fi

	cd ..
}

####################################################################################

draw_data() {
        for lines in $( cat .unimonrc )
        do
                now_mins=`mins $zero_mins`
                host=`echo $lines | cut -f1 -d"+"`
                draw_system_data

                i=3
                proc=`echo $lines | cut -f$i -d"+"`
                while [ -n "$proc" ]
                do
                        draw_process_data
                        let i=i+1
                        proc=`echo $lines | cut -f$i -d"+"`
                done
        done
}

####################################################################################

get_system_data() {
	        # vmstat/sar data on host
                ssh $host vmstat 1 2 | egrep -v 'id|cpu|change' > $workdir/vmstat.$host
                nawk -v t=$now_mins 'BEGIN {line = 0}{line++; if (line==2){ x = $5/1024; printf "%.2f\t%f\n", t, x} }' $workdir/vmstat.$host >> $workdir/$host.memory
                nawk -v t=$now_mins 'BEGIN {line = 0}{line++; if (line==2) printf "%.2f\t%f\n", t, $(NF)}' $workdir/vmstat.$host >> $workdir/$host.id.cpu
                ssh $host sar 1 2 | nawk -v t=$now_mins 'BEGIN {line=0}{line++; if (line == 6) printf "%.2f\t%.2f\n", t, $4}' >> $workdir/$host.wt.cpu

}


####################################################################################

get_hpux_top_data() {
	if [ "$component" = "IFS" ]
	then
		ssh $host ps -ef | grep bin/httpd | awk '{ print "httpd." $2 }' > processes
		cp processes $workdir

                # top for IFS processes on $host
                for processes in $(cat processes)
                do
                        ssh $host /usr/bin/top -d 1 -n 200 -f /mem.tmp
                        ssh $host cat /mem.tmp | grep httpd | grep ${processes#httpd.} > $workdir/$host.$processes
                        nawk -v t=$now_mins '{ printf "%.2f\t%f\n", t, $12 }' $workdir/$host.$processes >> $workdir/$host.$processes.cpu
                        nawk -v t=$now_mins '{ str = $7; if (substr(str, length(str)) == "K") {sub(/K/,"",str); i = str/1024 } else {sub(/M/,"",str); i = str } printf "%.2f\t%f\n", t, i }' $workdir/$host.$processes >> $workdir/$host.$processes.mem
                        ssh $host rm /mem.tmp
                done
	elif [ "$component" = "PS" ]
	then
                # top on host/proc for PS
		pid=`ssh $host ps -ef | grep java | grep 'Xms' | awk '{ print $2 }'`
		
                ssh $host /usr/bin/top -d 1 -n 200 -f /mem.tmp
                ssh $host cat /mem.tmp | grep java | grep $pid > $workdir/$host.$proc
                nawk -v t=$now_mins '{ printf "%.2f\t%f\n", t, $12 }' $workdir/$host.$proc >> $workdir/$host.$proc.cpu
                nawk -v t=$now_mins '{ str = $7; if (substr(str, length(str)) == "K") {sub(/K/,"",str); i = str/1024 } else {sub(/M/,"",str); i = str } printf "%.2f\t%f\n", t, i }' $workdir/$host.$proc >> $workdir/$host.$proc.mem
                ssh $host rm /mem.tmp
        elif [ "$component" = "FS" ]
        then
                # top on host/proc for FS
		pid=`ssh $host ps -ef | grep java | grep 'cp-fs' | awk '{ print $2 }'`
                ssh $host /usr/bin/top -d 1 -n 200 -f /mem.tmp
                ssh $host cat /mem.tmp | grep java | grep $pid > $workdir/$host.$proc
                nawk -v t=$now_mins '{ printf "%.2f\t%f\n", t, $12 }' $workdir/$host.$proc >> $workdir/$host.$proc.cpu
                nawk -v t=$now_mins '{ str = $7; if (substr(str, length(str)) == "K") {sub(/K/,"",str); i = str/1024 } else {sub(/M/,"",str); i = str } printf "%.2f\t%f\n", t, i }' $workdir/$host.$proc >> $workdir/$host.$proc.mem
                ssh $host rm /mem.tmp
	else
                # top on host/proc for all other servers
                ssh $host /usr/bin/top -d 1 -n 200 -f /mem.tmp
                ssh $host cat /mem.tmp | grep $proc > $workdir/$host.$proc
                nawk -v t=$now_mins '{ printf "%.2f\t%f\n", t, $12 }' $workdir/$host.$proc >> $workdir/$host.$proc.cpu
                nawk -v t=$now_mins '{ str = $7; if (substr(str, length(str)) == "K") {sub(/K/,"",str); i = str/1024 } else {sub(/M/,"",str); i = str } printf "%.2f\t%f\n", t, i }' $workdir/$host.$proc >> $workdir/$host.$proc.mem
                ssh $host rm /mem.tmp
	fi

}

####################################################################################

get_solaris_top_data() {
	if [ "$component" = "IFS" ]
	then
		ssh $host ps -ef | grep bin/httpd | awk '{ print "httpd." $2 }' > processes
		cp processes $workdir

                # top for IFS processes on $host
                for processes in $(cat processes)
                do
                        ssh $host /usr/local/bin/top -b all | grep ${processes#httpd.} > $workdir/$host.$processes
                        nawk -v t=$now_mins '{ printf "%.2f\t%f\n", t, $(NF-1) }' $workdir/$host.$processes >> $workdir/$host.$processes.cpu
                        nawk -v t=$now_mins '{ str = $6; if (substr(str, length(str)) == "K") {sub(/K/,"",str); i = str/1024 } else {sub(/M/,"",str); i = str } printf "%.2f\t%f\n", t, i }' $workdir/$host.$processes >> $workdir/$host.$processes.mem
                done
	elif [ "$component" = "PS" ]
	then
                # top on host/proc for PS
		ssh $host /usr/local/bin/top -b all | grep $proc | grep -v 'cp-fs' > $workdir/$host.$proc
                nawk -v t=$now_mins '{ printf "%.2f\t%f\n", t, $(NF-1) }' $workdir/$host.$proc >> $workdir/$host.$proc.cpu
                nawk -v t=$now_mins '{ str = $6; if (substr(str, length(str)) == "K") {sub(/K/,"",str); i = str/1024 } else {sub(/M/,"",str); i = str } printf "%.2f\t%f\n", t, i }' $workdir/$host.$proc >> $workdir/$host.$proc.mem
        elif [ "$component" = "FS" ]
        then
                # top on host/proc for FS
		ssh $host /usr/local/bin/top -b all | grep $proc | grep 'cp-fs' > $workdir/$host.$proc
                nawk -v t=$now_mins '{ printf "%.2f\t%f\n", t, $(NF-1) }' $workdir/$host.$proc >> $workdir/$host.$proc.cpu
                nawk -v t=$now_mins '{ str = $6; if (substr(str, length(str)) == "K") {sub(/K/,"",str); i = str/1024 } else {sub(/M/,"",str); i = str } printf "%.2f\t%f\n", t, i }' $workdir/$host.$proc >> $workdir/$host.$proc.mem
	else
                # top on host/proc for all other servers
		ssh $host /usr/local/bin/top -b all | grep $proc  > $workdir/$host.$proc
                nawk -v t=$now_mins '{ printf "%.2f\t%f\n", t, $(NF-1) }' $workdir/$host.$proc >> $workdir/$host.$proc.cpu
                nawk -v t=$now_mins '{ str = $6; if (substr(str, length(str)) == "K") {sub(/K/,"",str); i = str/1024 } else {sub(/M/,"",str); i = str } printf "%.2f\t%f\n", t, i }' $workdir/$host.$proc >> $workdir/$host.$proc.mem
	fi

}

####################################################################################

get_data() {
	
	for lines in $( cat .unimonrc )
	do
		now_mins=`mins $zero_mins`
		host=`echo $lines | cut -f1 -d"+"`
		get_system_data
		component=`echo $lines | cut -f2 -d"+"`

		i=3
		proc=`echo $lines | cut -f$i -d"+"`
		while [ -n "$proc" ]
		do
			os=`ssh $host uname`
			if [ "$os" = "SunOS" ]
			then
				get_solaris_top_data
			elif [ "$os" = "HP-UX" ]
			then
				get_hpux_top_data
			elif [ "$os" = "Linux" ]
			then
				get_linux_top_data
			fi

	                let i=i+1
			proc=`echo $lines | cut -f$i -d"+"`
		done
	done

}

###################################################################################

control_monitor() {
	until [ "$current_date" -gt "$end_date" ] # Tests condition here, at top of loop.
	do
        	current_cycle=1
        	end_cycle=10

        	while [ "$current_cycle" -le "$end_cycle" ]
        	do
			tm_start=`secs`
			get_data
			
                	echo " "
                	echo "Your working directory  : $workdir"
                	echo " "
                	echo "Monitoring start date   : `cat $workdir/duration.txt`"
                	echo "Monitoring current date : `date`"
                	echo "Monitoring end date     : $end_date"

                	diff=`expr $end_cycle - $current_cycle`
                	echo " "
			if [ $diff -eq 0 ]
			then
				echo "Updating webpage..."
			else
                		echo "Your webpage will be updated after $diff cycles!"
			fi

	                current_cycle=`expr $current_cycle + 1`

			tm_data=`secs $tm_start`
			if [ $tm_data -gt 5 ] 
			then
				sleep `expr 60 - $tm_data`
			fi

		done

               	echo " "

		draw_data	
		make_web_pages
		disk_monitor
		monitor_core
		current_date=`date '+%m%d%H%M'`
	done
}

####################################################################################

echo "Monitoring Started"
control_monitor

echo "`date`" >> $workdir/duration.txt

