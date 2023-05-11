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
set yrange [0:]
set title "% CPU Usage for $process on $host."
set xlabel "Time (mins)"
set ylabel "% CPU Usage"
plot "$host.$process.cpu" with lines
set output '$host.$process.mem.gif'
set yrange [0:]
set title "Memory size used by $process on $host"
set xlabel "Time (mins)"
set ylabel "Memory usage (MB)"
plot "$host.$process.mem" with lines
exit
EOF
	
