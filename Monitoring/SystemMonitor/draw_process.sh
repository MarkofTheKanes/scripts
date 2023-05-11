if [ $# -ne 2 ]
then
	clear
        echo " "
        echo " Usage $0 [hostname] [process]" 
	echo " "
	echo " [hostname] : not fully qualified hostname!"
        echo " "
	exit 2
fi
	
host=$1
process=$2
gnuplot <<EOF
set terminal gif
set grid
set border
set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
set output '$host.$process.cpu.gif'
set title "% CPU Usage for $process on $host."
set xlabel "Sessions in minutes"
set ylabel "% CPU Usage"
plot "$host.$process.cpu" with lines
set output '$host.$process.mem.gif'
set title "Memory size used by $process on $host"
set xlabel "Sessions in minutes"
set ylabel "Memory size (Mega Bytes)"
plot "$host.$process.mem" with lines
exit
EOF
	
