#!/usr/local/bin/bash


sent_messages ()

{

rm *.out
rm log.txt

for file in *.log

do
        echo "Reading $file"
        grep MsgSent1h $file >> MsgSent1h.out

done

number=10
count=0

while [ $count -lt $number ]

do
        echo "grepping number 0$count"
        grep " 0$count:" MsgSent1h.out > 0$count.grep
        awk -F : '{ print $4 }' 0$count.grep > 0$count.out
        rm 0$count.grep
        sh addup.sh 1 0$count.out
        stat=`sh addup.sh 1 0$count.out`
        echo "0$count:00 $stat" >> log.txt

        let "count += 1"

done

number=23
count=10

while [ $count -le $number ]

do
        echo "grepping number $count"
        grep " $count:" MsgSent1h.out > $count.grep
        awk -F : '{ print $4 }' $count.grep > $count.out
        rm $count.grep
        stat=`sh addup.sh 1 $count.out`
        echo "$count:00 $stat" >> log.txt
        let "count += 1"
done

# Get the date
plot_time=`date`

gnuplot <<EOF
set terminal gif
set output 'MsgSent1h.gif'
set title "Message Send's over a 24 hour period"
set xlabel "Time (Hour)"
set ylabel "Number of Messages Sent"
set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
set grid
set border
plot "log.txt" with lines
EOF

echo "<html>" > MsgSent.html
echo "<head>" >> MsgSent.html
echo "<title>Number of Messages Sent</title>" >> MsgSent.html
echo "<META HTTP-EQUIV="Expires" CONTENT="-1">" >> MsgSent.html
echo "<META HTTP-EQUIV="Pragma" CONTENT="no-cache">" >> MsgSent.html
echo "</head>" >> MsgSent.html
echo " " >> MsgSent.html
echo "<body bgcolor="#FFFFFF" text="#000000">" >> MsgSent.html
echo "<p><b><font face="Verdana" size="1">Number of Messages Sent at certain hours</font></b></p>" >> MsgSent.html
echo "<p><font face="Verdana" size="1">Plotted at $plot_time</font></p>" >> MsgSent.html
echo "<p><font face="Verdana" size="1">The graphic shows the peaks for message sending measured over one months traffic</font></p>" 
>> MsgSent.html
echo "<p><font face="Verdana" size="1">click <a href="log.html">here</a> for exact breakdown</font></p>" >> MsgSent.html
echo "<p><img src="http://qa.cpth.ie/puma_stats/MsgSent1h.gif"></p>" >> MsgSent.html
echo "</body>" >> MsgSent.html
echo "</html>" >> MsgSent.html

txt2html log.txt > log.html
cp log.html /usr/local/apache/htdocs/puma_stats/
cp MsgSent.html /usr/local/apache/htdocs/puma_stats
cp MsgSent1h.gif /usr/local/apache/htdocs/puma_stats

}

recieve_messages ()

{

rm *.out
rm recieve_log.txt

for file in *.log

do
        echo "Reading $file"
        grep MsgRec1h $file >> MsgRec1h.out

done

number=10
count=0

while [ $count -lt $number ]

do
        echo "grepping number 0$count"
        grep " 0$count:" MsgRec1h.out > 0$count.grep
        awk -F : '{ print $4 }' 0$count.grep > 0$count.out
        rm 0$count.grep
        sh addup.sh 1 0$count.out
        stat=`sh addup.sh 1 0$count.out`
        echo "0$count:00 $stat" >> recieve_log.txt

        let "count += 1"

done

number=23
count=10

while [ $count -le $number ]

do
        echo "grepping number $count"
        grep " $count:" MsgRec1h.out > $count.grep
        awk -F : '{ print $4 }' $count.grep > $count.out
        rm $count.grep
        stat=`sh addup.sh 1 $count.out`
        echo "$count:00 $stat" >> recieve_log.txt
        let "count += 1"
done

# Get the date
plot_time=`date`

gnuplot <<EOF
set terminal gif
set output 'MsgRec1h.gif'
set title "Message Send's over a 24 hour period"
set xlabel "Time (Hour)"
set ylabel "Number of Messages Sent"
set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
set grid
set border
plot "recieve_log.txt" with lines
EOF

echo "<html>" > MsgRec.html
echo "<head>" >> MsgRec.html
echo "<title>Number of Messages Sent</title>" >> MsgRec.html
echo "<META HTTP-EQUIV="Expires" CONTENT="-1">" >> MsgRec.html
echo "<META HTTP-EQUIV="Pragma" CONTENT="no-cache">" >> MsgRec.html
echo "</head>" >> MsgRec.html
echo " " >> MsgRec.html
echo "<body bgcolor="#FFFFFF" text="#000000">" >> MsgRec.html
echo "<p><b><font face="Verdana" size="1">Number of Messages Sent at certain hours</font></b></p>" >> MsgRec.html
echo "<p><font face="Verdana" size="1">Plotted at $plot_time</font></p>" >> MsgRec.html
echo "<p><font face="Verdana" size="1">The graphic shows the peaks for messages recieved measured over one months traffic</font></p>
" >> MsgRec.html
echo "<p><font face="Verdana" size="1">click <a href="recieve_log.html">here</a> for exact breakdown</font></p>" >> MsgRec.html
echo "<p><img src="http://qa.cpth.ie/puma_stats/MsgRec1h.gif"></p>" >> MsgRec.html
echo "</body>" >> MsgRec.html
echo "</html>" >> MsgRec.html

txt2html recieve_log.txt > recieve_log.html
cp receive_log.html /usr/local/apache/htdocs/puma_stats/
cp MsgRec.html /usr/local/apache/htdocs/puma_stats/MsgRec.html 
cp MsgRec1h.gif /usr/local/apache/htdocs/puma_stats

}

delivered_messages ()

{

rm *.out
rm deliver_log.txt

for file in *.log

do
        echo "Reading $file"
        grep MsgDlv1h $file >> MsgDlv1h.out

done

number=10
count=0

while [ $count -lt $number ]

do
        echo "grepping number 0$count"
        grep " 0$count:" MsgDlv1h.out > 0$count.grep
        awk -F : '{ print $4 }' 0$count.grep > 0$count.out
        rm 0$count.grep
        sh addup.sh 1 0$count.out
        stat=`sh addup.sh 1 0$count.out`
        echo "0$count:00 $stat" >> deliver_log.txt

        let "count += 1"

done

number=23
count=10

while [ $count -le $number ]

do
        echo "grepping number $count"
        grep " $count:" MsgDlv1h.out > $count.grep
        awk -F : '{ print $4 }' $count.grep > $count.out
        rm $count.grep
        stat=`sh addup.sh 1 $count.out`
        echo "$count:00 $stat" >> deliver_log.txt
        let "count += 1"
done

# Get the date
plot_time=`date`

gnuplot <<EOF
set terminal gif
set output 'MsgDlv1h.gif'
set title "Message Send's over a 24 hour period"
set xlabel "Time (Hour)"
set ylabel "Number of Messages Sent"
set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
set grid
set border
plot "deliver_log.txt" with lines
EOF

echo "<html>" > MsgDlv1h.html
echo "<head>" >> MsgDlv1h.html
echo "<title>Number of Messages Sent</title>" >> MsgDlv1h.html
echo "<META HTTP-EQUIV="Expires" CONTENT="-1">" >> MsgDlv1h.html
echo "<META HTTP-EQUIV="Pragma" CONTENT="no-cache">" >> MsgDlv1h.html
echo "</head>" >> MsgDlv1h.html
echo " " >> MsgDlv1h.html
echo "<body bgcolor="#FFFFFF" text="#000000">" >> MsgDlv1h.html
echo "<p><b><font face="Verdana" size="1">Number of Messages Sent at certain hours</font></b></p>" >> MsgDlv1h.html
echo "<p><font face="Verdana" size="1">Plotted at $plot_time</font></p>" >> MsgDlv1h.html
echo "<p><font face="Verdana" size="1">The graphic shows the peaks for message's delivered measured over one months traffic</font></
p>" >> MsgDlv1h.html 
echo "<p><font face="Verdana" size="1">click <a href="deliver_log.html">here</a> for exact breakdown</font></p>" >> MsgDiv1h.html
echo "<p><img src="http://qa.cpth.ie/puma_stats/MsgDlv1h.gif"></p>" >> MsgDlv1h.html
echo "</body>" >> MsgDlv1h.html
echo "</html>" >> MsgDlv1h.html

txt2html deliver_log.txt > deliver_log.html
cp deliver_log.html /usr/local/apache/htdocs/puma_stats/
cp MsgDlv1h.html /usr/local/apache/htdocs/puma_stats/
cp MsgDlv1h.gif /usr/local/apache/htdocs/puma_stats

}

make_index ()

{

echo "<html>" > index.html
echo "<head>" >> index.html
echo "<title></title>" >> index.html
echo "</head>" >> index.html
echo "<body>" >> index.html
echo "<p><font face="Verdana" size="1">puma statistics for June 2002</font> " >> index.html
echo "<ul>" >> index.html
echo "<li><a href="MsgSent.html"><font face="Verdana" size="1">Messages Sent</font></a></li>" >> index.html
echo "<li><a href="MsgRec.html"><font face="Verdana" size="1">Messages Recieved</font></a></li>" >> index.html
echo "<li><a href="MsgDlv1h.html"><font face="Verdana" size="1">Messages Delivered</font></a></li>" >> index.html
echo "</ul>" >> index.html
echo "</body>" >> index.html
echo "</html>" >> index.html

cp index.html /usr/local/apache/htdocs/puma_stats/

}

###################################################
##
## End of functions
##
###################################################

sent_messages
recieve_messages
delivered_messages