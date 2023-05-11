#!/usr/bin/bash

workdir=$1
line=$2
email=$3
host=`echo $line | cut -f1 -d"+"`
component=`echo $line | cut -f2 -d"+"`

date=`date '+%H:%M on %d-%m-%y'`

title1="Monitoring Results for $component on $host"
title2="Monitoring Results for $component on $host"
desc="This page displays the monitor results for $component on $host"
started="Monitoring started: `cat start.txt`"

####################################################################################

echo "<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">"
echo "<html>"
echo "<head>"
echo "<title>$title1</title>"
echo "</head>"
echo "<body>"
echo "<!-- Do not edit this line --><!--#exec cmd="/disk0/apache2/cgi-bin/header.pl" -->"
echo "<!-- Do not edit this line --><!--#exec cmd="/disk0/apache2/cgi-bin/nav.pl" -->"
echo "<p class="headLine">$title2</p>"
echo "<p class="intro">$desc</p>"


###################################################################################################
# make machine process page


echo "<center>"

i=3
proc=`echo $line | cut -f$i -d"+"`

while [ -n "$proc" ]
do
	echo "<A HREF=\"#mem$proc\">$proc memory usage</A> | "
	echo "<A HREF=\"#cpu$proc\">$proc cpu usage</A></br>"
        let i=i+1
        proc=`echo $line | cut -f$i -d"+"`
done

echo "<A HREF=\"#idle\">CPU idle time</A> | "
echo "<A HREF=\"#wait\">CPU I/O Wait Percentage</A> | "
echo "<A HREF=\"#memory\">Free Memory Size</A></br>"
echo "</center>"


echo "</br></br>"

i=3
proc=`echo $line | cut -f$i -d"+"`

while [ -n "$proc" ]
do
	echo "<A NAME=\"mem$proc\">"
	echo "<H1 ALIGN=center><IMG SRC=\"$host.$proc.mem.gif\" ALT=\"$proc memory usage\"></H1></A>"
	echo "</br></br>"
	echo "<p align=right><small><A HREF=\"#top\">back to top</A></small></right></br></br></br></br></p>"

	echo "<A NAME=\"cpu$proc\">"
	echo "<H1 ALIGN=center><IMG SRC=\"$host.$proc.cpu.gif\" ALT=\"$proc cpu usage\"></H1></A>"
	echo "</br></br>"
	echo "<p align=right><small><A HREF=\"#top\">back to top</A></small></right></br></br></br></br></p>"
        let i=i+1
        proc=`echo $line | cut -f$i -d"+"`
done

echo "<A NAME=\"idle\">"
echo "<H1 ALIGN=center><IMG SRC=\"$host.id.cpu.gif\" ALT=\"CPU idle time %\"></H1></A>"
echo "</br></br>"
echo "<p align=right><small><A HREF=\"#top\">back to top</A></small></right></br></br></br></br></p>"

echo "<A NAME=\"wait\">"
echo "<H1 ALIGN=center><IMG SRC=\"$host.wt.cpu.gif\" ALT=\"CPU I/O wait time \%\"></H1></A>"
echo "</br></br>"
echo "<p align=right><small><A HREF=\"#top\">back to top</A></small></right></br></br></br></br></p>"

echo "<A NAME=\"memory\">"
echo "<H1 ALIGN=center><IMG SRC=\"$host.memory.gif\" ALT=\"CPU free memory size\"></H1></A>"
echo "</br></br>"
echo "<p align=right><small><A HREF=\"#top\">back to top</A></small></right></br></p>"



echo "<small><center>"

i=3
proc=`echo $line | cut -f$i -d"+"`

while [ -n "$proc" ]
do
	echo "<A HREF=\"#mem$proc\">$proc memory usage</A> | "
	echo "<A HREF=\"#cpu$proc\">$proc cpu usage</A></br>"
        let i=i+1
        proc=`echo $line | cut -f$i -d"+"`
done

echo "<A HREF=\"#idle\">CPU idle time</A> | "
echo "<A HREF=\"#wait\">CPU I/O Wait Percentage</A> | "
echo "<A HREF=\"#memory\">Free Memory Size</A></br>"

echo "</center></small>"

echo "<h6 style=\"font-family: helvetica,arial,sans-serif;\">"
echo "</h6>"



###################################################################################################

echo "<hr style=\"font-family: helvetica,arial,sans-serif;\">"
echo "<table width=\"100%\" style=\"font-family: helvetica,arial,sans-serif;\">"



         echo "<tbody>"
    echo "<tr align=\"right\">"
                 echo "<td><font size=\"1\"> Last Updated: $date</font></td>"
         echo "</tr>"
         echo "<tr align=\"right\">"
                 echo "<td><font size=\"1\"> Contact: <a href=\"mailto:$email\">$email</a></font></td>"
 echo "</tr>"
 
  echo "</tbody>"
echo "</table>"



 
echo "<hr style=\"font-family: helvetica,arial,sans-serif;\">  <br style=\"font-family: helvetica,arial,sans-serif;\">"

echo "</table>"

echo "<br style=\"font-family: helvetica,arial,sans-serif;\">"



echo "<br>"
echo "</body></html>"
