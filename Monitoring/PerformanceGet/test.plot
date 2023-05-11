# Calendar System Test Script
# 

# monitoring two hosts during tests
host1=$1 #CP IFS Server
host2=$2 #CP Directory Server and PS UI
i=$3

current_date=`date '+%d%H%M'`
end_date=$4


if [ $# -ne 4 ]
then
        echo " "
        echo " Usage $0 host1 host2 testid enddate" 
	echo " "
	#echo " host1  : CP Calendar Server"
	echo " host2  : CP Directory Server and PS UI"
	echo " testid : Test ID"
        echo " date   : For Example 101451 runs until 14:51 on 10th day of this month"
	echo "          Current date is: `date` ;-)"
        echo " "
	exit 2
fi

#create a working directory for this test
mkdir test$i
workdir=/ds/CpCal/ab_bench/test$i


echo CP Calendar Server is $host1
echo CP Directory Server and PS UI is $host2
echo Test Working directory is $workdir

####################################################################################

	# start monitoring scripts in first host

	rsh $host1 /usr/platform/sun4u/sbin/prtdiag >> $workdir/prtdiag.$host1

	rsh $host1 /opt/RICHPse/bin/se /opt/RICHPse/examples/virtual_adrian.se >> $workdir/se.$host1 &
	RSHSE1=$!

	rsh $host1 iostat 60 >> $workdir/iostat.$host1 &
	RSHIOSTAT1=$!

	rsh $host1 vmstat 60 >> $workdir/vmstat.$host1 &
	RSHVMSTAT1=$!

	#############################################################################

	# start monitoring scripts in second host

	rsh $host2 /usr/platform/sun4u/sbin/prtdiag >> $workdir/prtdiag.$host2

	rsh $host2 /opt/RICHPse/bin/se /opt/RICHPse/examples/virtual_adrian.se >> $workdir/se.$host2 &
	RSHSE2=$!

	rsh $host2 iostat 60 >> $workdir/iostat.$host2 &
	RSHIOSTAT2=$!

        rsh $host2 vmstat 60 >> $workdir/vmstat.$host2 &
        RSHVMSTAT2=$!

	#############################################################################  

	#./perf.get $host1 $workdir &
	#RSHGET=$!

	#echo RSH scripts are all started.

####################################################################################

	# run actual calendar server stress scripts 
	#i=1
	#limit=2

	echo "`date`" > $workdir/duration.txt
	#while [ "$i" -lt "$limit" ] 
	#do

	until [ "$current_date" -ge "$end_date" ] # Tests condition here, at top of loop.
	do
                ./tst
	#	i=`expr $i + 1`
	#	echo "Limit is $limit and current iteration is $i.I am sleeping 60 seconds and then i promise i will start testing!">> status.txt
		#sleep 60
		current_date=`date '+%d%H%M'`
	done
	echo "`date`" >> $workdir/duration.txt

####################################################################################

	# calendar server stress scripts are stopped so kill monitoring scripts

	kill -9 $RSHSE1 $RSHVMSTAT1 $RSHSE2 $RSHVMSTAT2 $RSHIOSTAT1 $RSHIOSTAT2 $RSHGET
	sleep 2
	echo RSH scripts are all killed...

####################################################################################

	#*times files are produced from calendar server stress scripts so move them also to working directory
	mv *times $workdir/

####################################################################################

	# play with iostat outputs for both host

	sed '/cpu/d' $workdir/iostat.$host1 > $workdir/iostat.$host1.tmp
	sed '/id/d' $workdir/iostat.$host1.tmp > $workdir/iostat.$host1.final	

	sed '/cpu/d' $workdir/iostat.$host2 > $workdir/iostat.$host2.tmp        
        sed '/id/d' $workdir/iostat.$host2.tmp > $workdir/iostat.$host2.final   

	awk '{ print $18 }' $workdir/iostat.$host1.final > $workdir/$host1.id.cpu
	awk '{ print $17 }' $workdir/iostat.$host1.final > $workdir/$host1.wt.cpu
	awk '{ print $16 }' $workdir/iostat.$host1.final > $workdir/$host1.sy.cpu
	awk '{ print $15 }' $workdir/iostat.$host1.final > $workdir/$host1.us.cpu

        awk '{ print $18 }' $workdir/iostat.$host2.final > $workdir/$host2.id.cpu
        awk '{ print $17 }' $workdir/iostat.$host2.final > $workdir/$host2.wt.cpu
        awk '{ print $16 }' $workdir/iostat.$host2.final > $workdir/$host2.sy.cpu
        awk '{ print $15 }' $workdir/iostat.$host2.final > $workdir/$host2.us.cpu

	rm workdir/iostat.$host1.tmp $workdir/iostat.$host2.tmp $workdir/iostat.$host1.tmp $workdir/iostat.$host1.final $workdir/iostat.$host2.tmp $workdir/iostat.$host2.final

####################################################################################

	# play with vmstat outputs for both host

        sed '/cpu/d' $workdir/vmstat.$host1 > $workdir/vmstat.$host1.tmp
        sed '/id/d' $workdir/vmstat.$host1.tmp > $workdir/vmstat.$host1.final

        sed '/cpu/d' $workdir/vmstat.$host2 > $workdir/vmstat.$host2.tmp
        sed '/id/d' $workdir/vmstat.$host2.tmp > $workdir/vmstat.$host2.final

        awk '{ print $5 }' $workdir/vmstat.$host1.final > $workdir/$host1.memory.tmp

	while read line; do
    		line2=`expr $line / 1024`
    		echo $line2 >> $workdir/$host1.memory
	done < $workdir/$host1.memory.tmp

        awk '{ print $5 }' $workdir/vmstat.$host2.final > $workdir/$host2.memory.tmp

        while read line; do
                line2=`expr $line / 1024`
                echo $line2 >> $workdir/$host2.memory
        done < $workdir/$host2.memory.tmp

	rm $workdir/vmstat.$host1.tmp $workdir/vmstat.$host1.final $workdir/vmstat.$host2.tmp $workdir/vmstat.$host2.final
	
####################################################################################

	for files in $( ls  $workdir/*times )
	do

                cat $files | grep real | cut -f2 -d"m" | cut -f1 -d"s" > $files.inputt # unix time command
                cat $files | grep -v r | grep -v s > $files.sed
                sed '/^$/d' $files.sed > $files.input # apache benchmark timings
                rm $files.sed
	done

####################################################################################



	rsh $host1 /opt/criticalpath/cal/bin/mgr -s $host1 -p 5230 -w password performance get >> $workdir/performance.get	
	echo "-----------------db_stat -c output-------------------" >> $workdir/db.stat
	rsh $host1 /opt/criticalpath/cal/bin/db_stat -c >> $workdir/db.stat
	echo "-----------------db_stat -t output-------------------" >> $workdir/db.stat
        rsh $host1 /opt/criticalpath/cal/bin/db_stat -t >> $workdir/db.stat
	echo "-----------------db_stat -l output-------------------" >> $workdir/db.stat
        rsh $host1 /opt/criticalpath/cal/bin/db_stat -l >> $workdir/db.stat
	echo "-----------------------------------------------------" >> $workdir/db.stat


####################################################################################


	cd $workdir

	#Draw CPU Graphs

	gnuplot <<EOF
	set terminal gif
	set output '$host1.id.cpu.gif'
	set title "CPU Idle Time Percantage on $host1"
	set xlabel "Sessions in minutes"
	set ylabel "CPU Idle Time Percantage"
	set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
	set grid
	set border
	plot "$host1.id.cpu" with lines
	EOF

	#Draw memory Graphs

	gnuplot <<EOF
	set terminal gif
	set output '$host1.memory.gif'
	set title "Free memory size on $host1"
	set xlabel "Sessions in minutes"
	set ylabel "Free memory size (Mega Bytes)"
        set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
        set grid
        set border
	plot "$host1.memory" with lines
	EOF

        gnuplot <<EOF
        set terminal gif
        set output '$host2.id.cpu.gif'
        set title "CPU Idle Time Percantage on $host2"
        set xlabel "Sessions in minutes"
        set ylabel "CPU Idle Time Percantage"
        set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
        set grid
        set border
        plot "$host2.id.cpu" with lines
        EOF

        #Draw memory Graphs

        gnuplot <<EOF
        set terminal gif
        set output '$host2.memory.gif'
        set title "Free memory size on $host2 (Mega Bytes)"
        set xlabel "Sessions in minutes"
        set ylabel "Free memory size"
        set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
        set grid
        set border
        plot "$host2.memory" with lines
        EOF


####################################################################################

        # Draw graphs with ABACHE BENCHMARK TIMING STATISTICS

        #Draw add event times graph

        gnuplot <<EOF
        set terminal gif
        set output 'add_event_times.gif'
        set title "Add Event Times (sec)"
        set xlabel "Sessions"
        set ylabel "Add Event Times (sec)"
        set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
        set grid
        set border
        plot "add_event_times.input" with lines
        EOF

        #Draw add meeting times graph

        gnuplot <<EOF
        set terminal gif
        set output 'add_meeting_times.gif'
        set title "Add Meeting Times (sec)"
        set xlabel "Sessions"
        set ylabel "Add Meeting Times (sec)"
        set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
        set grid
        set border
        plot "add_meeting_times.input" with lines
        EOF

        #Draw add task times graph

        gnuplot <<EOF
        set terminal gif
        set output 'add_task_times.gif'
        set title "Add Task Times (sec)"
        set xlabel "Sessions"
        set ylabel "Add Task Times (sec)"
        set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
        set grid
        set border
        plot "add_task_times.input" with lines
        EOF


        #Draw modify event times graph

        gnuplot <<EOF
        set terminal gif
        set output 'modify_event_times.gif'
        set title "Modify Event Times (sec)"
        set xlabel "Sessions"
        set ylabel "Modify Event Times (sec)"
        set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
        set grid
        set border
        plot "modify_event_times.input" with lines
        EOF

        #Draw modify meeting times graph

        gnuplot <<EOF
        set terminal gif
        set output 'modify_meeting_times.gif'
        set title "Modify Meeting Times (sec)"
        set xlabel "Sessions"
        set ylabel "Modify Meeting Times (sec)"
        set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
        set grid
        set border
        plot "modify_meeting_times.input" with lines
        EOF

        #Draw modify task times graph

        gnuplot <<EOF
        set terminal gif
        set output 'modify_task_times.gif'
        set title "Modify Task Times (sec)"
        set xlabel "Sessions"
        set ylabel "Modify Task Times (sec)"
        set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
        set grid
        set border
        plot "modify_task_times.input" with lines
        EOF



        #Draw delete event times graph

        gnuplot <<EOF
        set terminal gif
        set output 'delete_event_times.gif'
        set title "Delete Event Times (sec)"
        set xlabel "Sessions"
        set ylabel "Delete Event Times (sec)"
        set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
        set grid
        set border
        plot "delete_event_times.input" with lines
        EOF

        #Draw delete meeting times graph

        gnuplot <<EOF
        set terminal gif
        set output 'delete_meeting_times.gif'
        set title "Delete Meeting Times (sec)"
        set xlabel "Sessions"
        set ylabel "Delete Meeting Times (sec)"
        set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
        set grid
        set border
        plot "delete_meeting_times.input" with lines
        EOF

        #Draw delete task times graph

        gnuplot <<EOF
        set terminal gif
        set output 'delete_task_times.gif'
        set title "Delete Task Times (sec)"
        set xlabel "Sessions"
        set ylabel "Delete Task Times (sec)"
        set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
        set grid
        set border
        plot "delete_task_times.input" with lines
        EOF


####################################################################################

        # DRAW GRAPHS WITH UNIX TIME STATISTICS

        #Draw add event times graph
        
        gnuplot <<EOF
        set terminal gif
        set output 'add_event_times.giff'
        set title "Add Event Times (sec)"
        set xlabel "Sessions"
        set ylabel "Add Event Times (sec)"
        set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
        set grid
        set border
        plot "add_event_times.inputt" with lines
        EOF

        #Draw add meeting times graph

        gnuplot <<EOF
        set terminal gif 
        set output 'add_meeting_times.giff'
        set title "Add Meeting Times (sec)"
        set xlabel "Sessions"
        set ylabel "Add Meeting Times (sec)"
        set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
        set grid
        set border
        plot "add_meeting_times.inputt" with lines
        EOF

        #Draw add task times graph

        gnuplot <<EOF
        set terminal gif 
        set output 'add_task_times.giff'
        set title "Add Task Times (sec)"
        set xlabel "Sessions"
        set ylabel "Add Task Times (sec)"
        set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
        set grid
        set border
        plot "add_task_times.inputt" with lines
        EOF


        #Draw modify event times graph

        gnuplot <<EOF
        set terminal gif
        set output 'modify_event_times.giff'
        set title "Modify Event Times (sec)"
        set xlabel "Sessions"
        set ylabel "Modify Event Times (sec)"
        set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
        set grid
        set border
        plot "modify_event_times.inputt" with lines
        EOF

        #Draw modify meeting times graph

        gnuplot <<EOF
        set terminal gif 
        set output 'modify_meeting_times.giff'
        set title "Modify Meeting Times (sec)"
        set xlabel "Sessions"
        set ylabel "Modify Meeting Times (sec)"
        set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
        set grid
        set border
        plot "modify_meeting_times.inputt" with lines
        EOF

        #Draw modify task times graph

        gnuplot <<EOF
        set terminal gif 
        set output 'modify_task_times.giff'
        set title "Modify Task Times (sec)"
        set xlabel "Sessions"
        set ylabel "Modify Task Times (sec)"
        set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
        set grid
        set border
        plot "modify_task_times.inputt" with lines
        EOF



        #Draw delete event times graph

        gnuplot <<EOF
        set terminal gif
        set output 'delete_event_times.giff'
        set title "Delete Event Times (sec)"
        set xlabel "Sessions"
        set ylabel "Delete Event Times (sec)"
        set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
        set grid
        set border
        plot "delete_event_times.inputt" with lines
        EOF

        #Draw delete meeting times graph

        gnuplot <<EOF
        set terminal gif 
        set output 'delete_meeting_times.giff'
        set title "Delete Meeting Times (sec)"
        set xlabel "Sessions"
        set ylabel "Delete Meeting Times (sec)"
        set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
        set grid
        set border
        plot "delete_meeting_times.inputt" with lines
        EOF

        #Draw delete task times graph

        gnuplot <<EOF
        set terminal gif 
        set output 'delete_task_times.giff'
        set title "Delete Task Times (sec)"
        set xlabel "Sessions"
        set ylabel "Delete Task Times (sec)"
        set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
        set grid
        set border
        plot "delete_task_times.inputt" with lines
        EOF


####################################################################################
