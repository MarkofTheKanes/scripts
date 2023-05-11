#!/usr/local/bin/bash

pop3_login ()

{

rm *.out
rm pop3_login.txt

for file in *.log

do
        echo "Reading $file"
        grep POP3Login1h $file >> POP3Login1h.out

done

number=10
count=0

while [ $count -lt $number ]

do
        echo "grepping number 0$count"
        grep " 0$count:" POP3Login1h.out > 0$count.grep
        awk -F : '{ print $4 }' 0$count.grep > 0$count.out
        rm 0$count.grep
        sh addup.sh 1 0$count.out
        stat=`sh addup.sh 1 0$count.out`
        echo "0$count:00 $stat" >> pop3_login.txt

        let "count += 1"

done

number=23
count=10

while [ $count -le $number ]

do
        echo "grepping number $count"
        grep " $count:" POP3Login1h.out > $count.grep
        awk -F : '{ print $4 }' $count.grep > $count.out
        rm $count.grep
        stat=`sh addup.sh 1 $count.out`
        echo "$count:00 $stat" >> pop3_login.txt
        let "count += 1"
done

# Get the date
plot_time=`date`

gnuplot <<EOF
set terminal gif
set output 'POP3Login1h.gif'
set title "POP3 Logins over a 24 hour period"
set xlabel "Time (Hour)"
set ylabel "Number of Messages Sent"
set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
set grid
set border
plot "pop3_login.txt" with lines
EOF

echo "<html>" > Pop3Login.html
echo "<head>" >> Pop3Login.html
echo "<title>Number of Messages Sent</title>" >> Pop3Login.html
echo "<META HTTP-EQUIV="Expires" CONTENT="-1">" >> Pop3Login.html
echo "<META HTTP-EQUIV="Pragma" CONTENT="no-cache">" >> Pop3Login.html
echo "</head>" >> Pop3Login.html
echo " " >> Pop3Login.html
echo "<body bgcolor="#FFFFFF" text="#000000">" >> Pop3Login.html
echo "<p><b><font face="Verdana" size="1">Number of Messages Sent at certain hours</font></b></p>" >> Pop3Login.html
echo "<p><font face="Verdana" size="1">Plotted at $plot_time</font></p>" >> Pop3Login.html
echo "<p><font face="Verdana" size="1">The graphic shows the peaks for message sending measured over one months traffic</font></p>" 
>> Pop3Login.html
echo "<p><font face="Verdana" size="1">click <a href="pop3_login.html">here</a> for exact breakdown</font></p>" >> Pop3Login.html
echo "<p><img src="http://qa.cpth.ie/puma_stats/POP3Login1h.gif"></p>" >> Pop3Login.html
echo "</body>" >> Pop3Login.html
echo "</html>" >> Pop3Login.html

txt2html pop3_login.txt > pop3_login.html
cp pop3_login.html /usr/local/apache/htdocs/puma_stats/
cp Pop3Login.html /usr/local/apache/htdocs/puma_stats
cp POP3Login1h.gif /usr/local/apache/htdocs/puma_stats

}

pop3_retr ()

{

rm *.out
rm pop3_retr.txt

for file in *.log

do
        echo "Reading $file"
        grep POP3MsgRtrv1h $file >> POP3MsgRtrv1h.out

done

number=10
count=0

while [ $count -lt $number ]

do
        echo "grepping number 0$count"
        grep " 0$count:" POP3MsgRtrv1h.out > 0$count.grep
        awk -F : '{ print $4 }' 0$count.grep > 0$count.out
        rm 0$count.grep
        sh addup.sh 1 0$count.out
        stat=`sh addup.sh 1 0$count.out`
        echo "0$count:00 $stat" >> pop3_retr.txt

        let "count += 1"

done

number=23
count=10

while [ $count -le $number ]

do
        echo "grepping number $count"
        grep " $count:" POP3MsgRtrv1h.out > $count.grep
        awk -F : '{ print $4 }' $count.grep > $count.out
        rm $count.grep
        stat=`sh addup.sh 1 $count.out`
        echo "$count:00 $stat" >> pop3_retr.txt
        let "count += 1"
done

# Get the date
plot_time=`date`

gnuplot <<EOF
set terminal gif
set output 'POP3MsgRtrv1h.gif'
set title "POP3 Logins over a 24 hour period"
set xlabel "Time (Hour)"
set ylabel "Number of Messages Sent"
set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
set grid
set border
plot "pop3_retr.txt" with lines
EOF

echo "<html>" > POP3Rtrv.html
echo "<head>" >> POP3Rtrv.html
echo "<title>Number of Messages Sent</title>" >> POP3Rtrv.html
echo "<META HTTP-EQUIV="Expires" CONTENT="-1">" >> POP3Rtrv.html
echo "<META HTTP-EQUIV="Pragma" CONTENT="no-cache">" >> POP3Rtrv.html
echo "</head>" >> POP3Rtrv.html
echo " " >> POP3Rtrv.html
echo "<body bgcolor="#FFFFFF" text="#000000">" >> POP3Rtrv.html
echo "<p><b><font face="Verdana" size="1">Number of Messages Sent at certain hours</font></b></p>" >> POP3Rtrv.html
echo "<p><font face="Verdana" size="1">Plotted at $plot_time</font></p>" >> POP3Rtrv.html
echo "<p><font face="Verdana" size="1">The graphic shows the peaks for message sending measured over one months traffic</font></p>" 
>> POP3Rtrv.html
echo "<p><font face="Verdana" size="1">click <a href="pop3_retr.html">here</a> for exact breakdown</font></p>" >> POP3Rtrv.html
echo "<p><img src="http://qa.cpth.ie/puma_stats/POP3MsgRtrv1h.gif"></p>" >> POP3Rtrv.html
echo "</body>" >> POP3Rtrv.html
echo "</html>" >> POP3Rtrv.html

txt2html pop3_retr.txt > pop3_retr.html
cp pop3_retr.html /usr/local/apache/htdocs/puma_stats/
cp POP3Rtrv.html /usr/local/apache/htdocs/puma_stats
cp POP3MsgRtrv1h.gif /usr/local/apache/htdocs/puma_stats

}


pop3_bytes ()

{

rm *.out
rm pop3_bytes.txt

for file in *.log

do
        echo "Reading $file"
        grep POP3BytRtrv1h $file >> POP3BytRtrv1h.out

done

number=10
count=0

while [ $count -lt $number ]

do
        echo "grepping number 0$count"
        grep " 0$count:" POP3BytRtrv1h.out > 0$count.grep
        awk -F : '{ print $4 }' 0$count.grep > 0$count.out
        rm 0$count.grep
        sh addup.sh 1 0$count.out
        stat=`sh addup.sh 1 0$count.out`
        echo "0$count:00 $stat" >> pop3_bytes.txt

        let "count += 1"

done

number=23
count=10

while [ $count -le $number ]

do
        echo "grepping number $count"
        grep " $count:" POP3BytRtrv1h.out > $count.grep
        awk -F : '{ print $4 }' $count.grep > $count.out
        rm $count.grep
        stat=`sh addup.sh 1 $count.out`
        echo "$count:00 $stat" >> pop3_bytes.txt
        let "count += 1"
done

# Get the date
plot_time=`date`

gnuplot <<EOF
set terminal gif
set output 'POP3BytRtrv1h.gif'
set title "POP3 Bytes recieved over a 24 hour period"
set xlabel "Time (Hour)"
set ylabel "Number of Messages Sent"
set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
set grid
set border
plot "pop3_bytes.txt" with lines
EOF

echo "<html>" > POP3Bytes.html
echo "<head>" >> POP3Bytes.html
echo "<title>Number of Messages Sent</title>" >> POP3Bytes.html
echo "<META HTTP-EQUIV="Expires" CONTENT="-1">" >> POP3Bytes.html
echo "<META HTTP-EQUIV="Pragma" CONTENT="no-cache">" >> POP3Bytes.html
echo "</head>" >> POP3Bytes.html
echo " " >> POP3Bytes.html
echo "<body bgcolor="#FFFFFF" text="#000000">" >> POP3Bytes.html
echo "<p><b><font face="Verdana" size="1">Number of Messages Sent at certain hours</font></b></p>" >> POP3Bytes.html
echo "<p><font face="Verdana" size="1">Plotted at $plot_time</font></p>" >> POP3Bytes.html
echo "<p><font face="Verdana" size="1">The graphic shows the peaks for message sending measured over one months traffic</font></p>" 
>> POP3Bytes.html
echo "<p><font face="Verdana" size="1">click <a href="pop3_bytes.html">here</a> for exact breakdown</font></p>" >> POP3Bytes.html
echo "<p><img src="http://qa.cpth.ie/puma_stats/POP3BytRtrv1h.gif"></p>" >> POP3Bytes.html
echo "</body>" >> POP3Bytes.html
echo "</html>" >> POP3Bytes.html

txt2html pop3_bytes.txt > pop3_bytes.html
cp pop3_bytes.html /usr/local/apache/htdocs/puma_stats/
cp POP3Bytes.html /usr/local/apache/htdocs/puma_stats
cp POP3BytRtrv1h.gif /usr/local/apache/htdocs/puma_stats

}


############################################################
##
## End functions
##
############################################################

pop3_login
pop3_retr
pop3_bytes