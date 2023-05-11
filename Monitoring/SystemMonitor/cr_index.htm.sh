

server=$1
directory=$2 #CSB/4.0/Results
i=$3
email=$4
date=`date '+%H:%M on %d-%m-%y'`

if [ $# -ne 4 ]
then
	clear
        echo " "
        echo " Usage $0 [web server] [ftp base directory] [run id] [email]" 
	echo " "
	echo " [web server]         : fully qualified hostname of the web server"
        echo " [web base directory] : base directory in web server under which new directories will be created"
        echo " [run id]             : suffix of the new directory that will be created in ftp site"
        echo " [email]              : email address of tester to be displayed in result web page"
        echo " "
        exit 2
fi


echo "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"><html><head><title>Monitoring Results - Run $i</title>"
  

  

  

  
  
  
  
  
  echo "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">"



 
  
  
  
  echo "<link rel=\"stylesheet\" href=\"../site.css\" type=\"text/css\"></head><body style=\"background-color: rgb(255,255,255); color: rgb(0,0,0);\" class=\"divTextGrey\"><!--<font face=\"verdana\">-->"
  echo "<font face=\"Helvetica, Arial, sans-serif\" style=\"font-family: helvetica,arial,sans-serif;\"> <a name=\"tp\"></a>  </font>"
echo "<hr style=\"font-family: helvetica,arial,sans-serif;\"> "
echo "<center style=\"font-family: helvetica,arial,sans-serif;\"> "
echo "<h2>System Status - Run $i</h2>"
 echo "</center>"


echo "<hr style=\"font-family: helvetica,arial,sans-serif;\">  "
echo "<p style=\"font-family: helvetica,arial,sans-serif;\"> This page displays the monitor results for machines and processes that are configured for run $i.</p>"



  
echo "<h3 style=\"font-family: helvetica,arial,sans-serif;\"><a name=\"A\"><u>System Status&nbsp;</u></a>  <font size=\"1\"><a href=\"#tp\">[Top of Page]</a></font></h3>"



 
echo "<ul style=\"font-family: helvetica,arial,sans-serif;\">"



echo "</ul>"


#first table
  
echo "<table cellpadding=\"5\" cellspacing=\"1\" border=\"1\" style=\"background-color: rgb(204,204,204); font-family: helvetica,arial,sans-serif;\">"



 echo "<tbody>"
    echo "<tr bgcolor=\"#5f7fba\">"
         echo "<th colspan=\"7\" rowspan=\"1\"><font size=\"5\"><font color=\"#ffffff\"><b> Machine Status - Run $i</b></font></font></th>"
 echo "</tr>"
 echo "<tr>"
      echo "<td valign=\"middle\" bgcolor=\"#9999ff\" style=\"color: rgb(255,255,255); font-weight: bold; text-align: center;\"><small>Host Name<br>"

      echo "</small></td>"
      echo "<td valign=\"middle\" bgcolor=\"#9999ff\" style=\"color: rgb(255,255,255); font-weight: bold; text-align: center;\"><small>Configuration<br>"

      echo "</small></td>"
      echo "<td valign=\"middle\" bgcolor=\"#9999ff\" style=\"color: rgb(255,255,255); font-weight: bold; text-align: center;\"><small>SE Performance<br>"

      echo "</small></td>"
      echo "<td valign=\"middle\" bgcolor=\"#9999ff\" style=\"color: rgb(255,255,255); font-weight: bold; text-align: center;\"><small> % CPU Idle Time<br>"

      echo "</small></td>"
      echo "<td valign=\"middle\" bgcolor=\"#9999ff\" style=\"color: rgb(255,255,255); font-weight: bold; text-align: center;\"><small>&nbsp;% CPU I/O Wait<br>"

      echo "</small></td>"
      echo "<td valign=\"middle\" bgcolor=\"#9999ff\" style=\"color: rgb(255,255,255); font-weight: bold; text-align: center;\"><small>Free Memory Size<br>"

      echo "</small></td>"
    echo "</tr>"

for hosts in $( cat hosts )
do

echo "<tr>"
         echo "<td valign=\"top\"><small>$hosts"
      echo "</small></td>"
      echo "<td valign=\"top\" style=\"text-align: center;\"><small><a href=\"http://$server/$directory/run$i/prtdiag.$hosts\">Details</a>"
      echo "</small></td>"
echo "<td style=\"text-align: center;\" valign=\"top\"><small><a href=\"http://$server/$directory/run$i/se.$hosts\">Status</a>"
      echo "</small></td>"
         echo "<td style=\"text-align: center;\" valign=\"top\"><small><a href=\"http://$server/$directory/run$i/$hosts.id.cpu.gif\">Status</a>"
      echo "</small></td><td valign=\"top\" style=\"text-align: center;\"><small><a href=\"http://$server/$directory/run$i/$hosts.wt.cpu.gif\">Status</a>"
      echo "</small></td>"
      echo "<td valign=\"top\" style=\"text-align: center; font-family: helvetica,arial,sans-serif;\"><small><a href=\"http://$server/$directory/run$i/$hosts.memory.gif\">Status</a><br>"
      echo "</small></td>"

 echo "</tr>"
 
 done
 
  echo "</tbody>"
echo "</table>"

# end of machine table 

echo "<h6 style=\"font-family: helvetica,arial,sans-serif;\"><br>"
echo "</h6>"
echo "<h6 style=\"font-family: helvetica,arial,sans-serif;\"><br>"
echo "</h6>"

#second table for processes

echo "<table cellpadding=\"5\" cellspacing=\"1\" border=\"1\" style=\"background-color: rgb(204,204,204); font-family: helvetica,arial,sans-serif;\">"



 echo "<tbody>"
    echo "<tr bgcolor=\"#5f7fba\">"
         echo "<th colspan=\"7\" rowspan=\"1\"><font size=\"5\"><font color=\"#ffffff\"><b> Process Status - Run $i</b></font></font></th>"
 echo "</tr>"
 echo "<tr>"
      echo "<td valign=\"middle\" bgcolor=\"#9999ff\" style=\"color: rgb(255,255,255); font-weight: bold; text-align: center;\"><small>Process Name<br>"

      echo "</small></td>"
      echo "<td valign=\"middle\" bgcolor=\"#9999ff\" style=\"color: rgb(255,255,255); font-weight: bold; text-align: center;\"><small>% CPU usage<br>"

      echo "</small></td>"
      echo "<td valign=\"middle\" bgcolor=\"#9999ff\" style=\"color: rgb(255,255,255); font-weight: bold; text-align: center;\"><small> Memory Size<br>"

    echo "</tr>"

for lines in $( cat processes )
do

host=`echo $lines | cut -f1 -d"+"`
process=`echo $lines | cut -f2 -d"+"`

echo "<tr>"
      echo "<td valign=\"top\"><small>$lines"
      echo "</small></td>"
      echo "<td valign=\"top\" style=\"text-align: center;\"><small><a href=\"http://$server/$directory/run$i/$host.$process.cpu.gif\">Status</a>"
      echo "</small></td>"
      echo "<td style=\"text-align: center;\" valign=\"top\"><small><a href=\"http://$server/$directory/run$i/$host.$process.mem.gif\">Status</a>"
      echo "</small></td>"

 echo "</tr>"
 
 done
 
  echo "</tbody>"
echo "</table>"

# end of process table
 
echo "<h6 style=\"font-family: helvetica,arial,sans-serif;\"><br>"
echo "</h6>"



  
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



echo "<br style=\"font-family: helvetica,arial,sans-serif;\">"



echo "<br>"
echo "</body></html>"
