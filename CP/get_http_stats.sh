#!/usr/local/bin/bash

http_connect ()

{

rm *.out
rm http_connect.txt

for file in *.log

do
        echo "Reading $file"
        grep HTTPConnect1h $file >> HTTPConnect1h.out

done

number=10
count=0

while [ $count -lt $number ]

do
        echo "grepping number 0$count"
        grep " 0$count:" HTTPConnect1h.out > 0$count.grep
        awk -F : '{ print $4 }' 0$count.grep > 0$count.out
        rm 0$count.grep
        sh addup.sh 1 0$count.out
        stat=`sh addup.sh 1 0$count.out`
        echo "0$count:00 $stat" >> http_connect.txt

        let "count += 1"

done

number=23
count=10

while [ $count -le $number ]

do
        echo "grepping number $count"
        grep " $count:" HTTPConnect1h.out > $count.grep
        awk -F : '{ print $4 }' $count.grep > $count.out
        rm $count.grep
        stat=`sh addup.sh 1 $count.out`
        echo "$count:00 $stat" >> http_connect.txt
        let "count += 1"
done

# Get the date
plot_time=`date`

gnuplot <<EOF
set terminal gif
set output 'HTTPConnect1h.gif'
set title "HTTP Connections over a 24 hour period"
set xlabel "Time (Hour)"
set ylabel "Number of Messages Sent"
set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
set grid
set border
plot "http_connect.txt" with lines
EOF

echo "<html>" > HTTPConnect.html
echo "<head>" >> HTTPConnect.html
echo "<title>Number of Messages Sent</title>" >> HTTPConnect.html
echo "<META HTTP-EQUIV="Expires" CONTENT="-1">" >> HTTPConnect.html
echo "<META HTTP-EQUIV="Pragma" CONTENT="no-cache">" >> HTTPConnect.html
echo "</head>" >> HTTPConnect.html
echo " " >> HTTPConnect.html
echo "<body bgcolor="#FFFFFF" text="#000000">" >> HTTPConnect.html
echo "<p><b><font face="Verdana" size="1">Number of Messages Sent at certain hours</font></b></p>" >> HTTPConnect.html
echo "<p><font face="Verdana" size="1">Plotted at $plot_time</font></p>" >> HTTPConnect.html
echo "<p><font face="Verdana" size="1">The graphic shows the peaks for message sending measured over one months traffic</font></p>" 
>> HTTPConnect.html
echo "<p><font face="Verdana" size="1">click <a href="http_connect.html">here</a> for exact breakdown</font></p>" >> HTTPConnect.htm
l
echo "<p><img src="http://qa.cpth.ie/puma_stats/HTTPConnect1h.gif"></p>" >> HTTPConnect.html
echo "</body>" >> HTTPConnect.html
echo "</html>" >> HTTPConnect.html

txt2html http_connect.txt > http_connect.html
cp http_connect.html /usr/local/apache/htdocs/puma_stats/
cp HTTPConnect.html /usr/local/apache/htdocs/puma_stats
cp HTTPConnect1h.gif /usr/local/apache/htdocs/puma_stats

}

http_get ()

{

rm *.out
rm http_get.txt

for file in *.log

do
        echo "Reading $file"
        grep HTTPMailGet1h $file >> HTTPMailGet1h.out

done

number=10
count=0

while [ $count -lt $number ]

do
        echo "grepping number 0$count"
        grep " 0$count:" HTTPMailGet1h.out > 0$count.grep
        awk -F : '{ print $4 }' 0$count.grep > 0$count.out
        rm 0$count.grep
        sh addup.sh 1 0$count.out
        stat=`sh addup.sh 1 0$count.out`
        echo "0$count:00 $stat" >> http_get.txt

        let "count += 1"

done

number=23
count=10

while [ $count -le $number ]

do
        echo "grepping number $count"
        grep " $count:" HTTPMailGet1h.out > $count.grep
        awk -F : '{ print $4 }' $count.grep > $count.out
        rm $count.grep
        stat=`sh addup.sh 1 $count.out`
        echo "$count:00 $stat" >> http_get.txt
        let "count += 1"
done

# Get the date
plot_time=`date`

gnuplot <<EOF
set terminal gif
set output 'HTTPMailGet1h.gif'
set title "HTTP Connections over a 24 hour period"
set xlabel "Time (Hour)"
set ylabel "Number of Messages Sent"
set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
set grid
set border
plot "http_get.txt" with lines
EOF

echo "<html>" > HTTPGet.html
echo "<head>" >> HTTPGet.html
echo "<title>Number of Messages Sent</title>" >> HTTPGet.html
echo "<META HTTP-EQUIV="Expires" CONTENT="-1">" >> HTTPGet.html
echo "<META HTTP-EQUIV="Pragma" CONTENT="no-cache">" >> HTTPGet.html
echo "</head>" >> HTTPGet.html
echo " " >> HTTPGet.html
echo "<body bgcolor="#FFFFFF" text="#000000">" >> HTTPGet.html
echo "<p><b><font face="Verdana" size="1">Number of Messages Sent at certain hours</font></b></p>" >> HTTPGet.html
echo "<p><font face="Verdana" size="1">Plotted at $plot_time</font></p>" >> HTTPGet.html
echo "<p><font face="Verdana" size="1">The graphic shows the peaks for message sending measured over one months traffic</font></p>" 
>> HTTPGet.html
echo "<p><font face="Verdana" size="1">click <a href="http_get.html">here</a> for exact breakdown</font></p>" >> HTTPGet.html
echo "<p><img src="http://qa.cpth.ie/puma_stats/HTTPMailGet1h.gif"></p>" >> HTTPGet.html
echo "</body>" >> HTTPGet.html
echo "</html>" >> HTTPGet.html

txt2html http_get.txt > http_get.html
cp http_get.html /usr/local/apache/htdocs/puma_stats/
cp HTTPGet.html /usr/local/apache/htdocs/puma_stats
cp HTTPMailGet1h.gif /usr/local/apache/htdocs/puma_stats

}

http_post ()

{

rm *.out
rm http_post.txt

for file in *.log

do
        echo "Reading $file"
        grep HTTPMailPost1h $file >> HTTPMailPost1h.out

done

number=10
count=0

while [ $count -lt $number ]

do
        echo "grepping number 0$count"
        grep " 0$count:" HTTPMailPost1h.out > 0$count.grep
        awk -F : '{ print $4 }' 0$count.grep > 0$count.out
        rm 0$count.grep
        sh addup.sh 1 0$count.out
        stat=`sh addup.sh 1 0$count.out`
        echo "0$count:00 $stat" >> http_post.txt

        let "count += 1"

done

number=23
count=10

while [ $count -le $number ]

do
        echo "grepping number $count"
        grep " $count:" HTTPMailPost1h.out > $count.grep
        awk -F : '{ print $4 }' $count.grep > $count.out
        rm $count.grep
        stat=`sh addup.sh 1 $count.out`
        echo "$count:00 $stat" >> http_post.txt
        let "count += 1"
done

# Get the date
plot_time=`date`

gnuplot <<EOF
set terminal gif
set output 'HTTPMailPost1h.gif'
set title "HTTP Connections over a 24 hour period"
set xlabel "Time (Hour)"
set ylabel "Number of Messages Sent"
set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
set grid
set border
plot "http_post.txt" with lines
EOF

echo "<html>" > HTTPPost.html
echo "<head>" >> HTTPPost.html
echo "<title>Number of Messages Sent</title>" >> HTTPPost.html
echo "<META HTTP-EQUIV="Expires" CONTENT="-1">" >> HTTPPost.html
echo "<META HTTP-EQUIV="Pragma" CONTENT="no-cache">" >> HTTPPost.html
echo "</head>" >> HTTPPost.html
echo " " >> HTTPPost.html
echo "<body bgcolor="#FFFFFF" text="#000000">" >> HTTPPost.html
echo "<p><b><font face="Verdana" size="1">Number of Messages Sent at certain hours</font></b></p>" >> HTTPPost.html
echo "<p><font face="Verdana" size="1">Plotted at $plot_time</font></p>" >> HTTPPost.html
echo "<p><font face="Verdana" size="1">The graphic shows the peaks for message sending measured over one months traffic</font></p>" 
>> HTTPPost.html
echo "<p><font face="Verdana" size="1">click <a href="http_post.html">here</a> for exact breakdown</font></p>" >> HTTPPost.html
echo "<p><img src="http://qa.cpth.ie/puma_stats/HTTPMailPost1h.gif"></p>" >> HTTPPost.html
echo "</body>" >> HTTPPost.html
echo "</html>" >> HTTPPost.html

txt2html http_post.txt > http_post.html
cp http_post.html /usr/local/apache/htdocs/puma_stats/
cp HTTPPost.html /usr/local/apache/htdocs/puma_stats
cp HTTPMailPost1h.gif /usr/local/apache/htdocs/puma_stats

}

http_login ()

{

rm *.out
rm http_login.txt

for file in *.log

do
        echo "Reading $file"
        grep HTTPLogin1h $file >> HTTPLogin1h.out

done

number=10
count=0

while [ $count -lt $number ]

do
        echo "grepping number 0$count"
        grep " 0$count:" HTTPLogin1h.out > 0$count.grep
        awk -F : '{ print $4 }' 0$count.grep > 0$count.out
        rm 0$count.grep
        sh addup.sh 1 0$count.out
        stat=`sh addup.sh 1 0$count.out`
        echo "0$count:00 $stat" >> http_login.txt

        let "count += 1"

done

number=23
count=10

while [ $count -le $number ]

do
        echo "grepping number $count"
        grep " $count:" HTTPLogin1h.out > $count.grep
        awk -F : '{ print $4 }' $count.grep > $count.out
        rm $count.grep
        stat=`sh addup.sh 1 $count.out`
        echo "$count:00 $stat" >> http_login.txt
        let "count += 1"
done

# Get the date
plot_time=`date`

gnuplot <<EOF
set terminal gif
set output 'HTTPLogin1h.gif'
set title "HTTP Connections over a 24 hour period"
set xlabel "Time (Hour)"
set ylabel "Number of Messages Sent"
set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
set grid
set border
plot "http_login.txt" with lines
EOF

echo "<html>" > HTTPLogin.html
echo "<head>" >> HTTPLogin.html
echo "<title>Number of Messages Sent</title>" >> HTTPLogin.html
echo "<META HTTP-EQUIV="Expires" CONTENT="-1">" >> HTTPLogin.html
echo "<META HTTP-EQUIV="Pragma" CONTENT="no-cache">" >> HTTPLogin.html
echo "</head>" >> HTTPLogin.html
echo " " >> HTTPLogin.html
echo "<body bgcolor="#FFFFFF" text="#000000">" >> HTTPLogin.html
echo "<p><b><font face="Verdana" size="1">Number of Messages Sent at certain hours</font></b></p>" >> HTTPLogin.html
echo "<p><font face="Verdana" size="1">Plotted at $plot_time</font></p>" >> HTTPLogin.html
echo "<p><font face="Verdana" size="1">The graphic shows the peaks for message sending measured over one months traffic</font></p>" 
>> HTTPLogin.html
echo "<p><font face="Verdana" size="1">click <a href="http_login.html">here</a> for exact breakdown</font></p>" >> HTTPLogin.html
echo "<p><img src="http://qa.cpth.ie/puma_stats/HTTPLogin1h.gif"></p>" >> HTTPLogin.html
echo "</body>" >> HTTPLogin.html
echo "</html>" >> HTTPLogin.html

txt2html http_login.txt > http_login.html
cp http_login.html /usr/local/apache/htdocs/puma_stats/
cp HTTPLogin.html /usr/local/apache/htdocs/puma_stats
cp HTTPLogin1h.gif /usr/local/apache/htdocs/puma_stats

}




########################################################
##
## End of Functions
##
########################################################

http_connect
http_get
http_post
http_login