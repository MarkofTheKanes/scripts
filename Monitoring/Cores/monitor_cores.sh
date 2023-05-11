for lines in $( cat cores )
do
	# parse host name and directory
	host=`echo $lines | cut -f1 -d"+"`
        directory=`echo $lines | cut -f2 -d"+"`
        #echo "$host:$directory"
        control_core=`rsh $host ls -l $directory/core 2> /dev/null | wc -l`
	if [ $control_core -eq 1 ]
	then
		#echo "There is a core file under $directory on $host!"
		echo "From: Core Monitor" > msg.0
		echo "Subject: Core under $directory directory on $host!!!" >> msg.0
		#sleep 3
		./smtptst -spuma.dub0.ie.cp.net f\'core@cp.net\'r\'deniz.susar@cp.net\'S0Q
		./smtptst -spuma.dub0.ie.cp.net f\'core@cp.net\'r\'mark.okane@cp.net\'S0Q
	fi
        #echo "$control_core"

done
