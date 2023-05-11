
allowed_disk_usage=90
for host in $( cat hosts )
do
	highest_disk_usage=`rsh $host df -k | awk '{ print $5 }' | grep -v capacity | sort -n | tail -1 | cut -f1 -d"%"`
	echo "$host:$highest_disk_usage"

	if [ $highest_disk_usage -gt $allowed_disk_usage ]
	then
		echo "Disk problem on $host!"
		echo "From: Disk Monitor" > msg.0
		echo "Subject: High Disk Usage ( > $allowed_disk_usage) on $host!!!" >> msg.0
		#sleep 3
		./smtptst -spuma.dub0.ie.cp.net f\'core@cp.net\'r\'deniz.susar@cp.net\'S0Q
		./smtptst -spuma.dub0.ie.cp.net f\'core@cp.net\'r\'mark.okane@cp.net\'S0Q
	fi
done
