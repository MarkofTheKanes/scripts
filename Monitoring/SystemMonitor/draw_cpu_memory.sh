if [ $# -ne 1 ]
then
	clear
        echo " "
        echo " Usage $0 [hostname]" 
	echo " "
	echo " [hostname] : not fully qualified hostname!"
        echo " "
	exit 2
fi
	
host=$1
gnuplot <<EOF
set terminal gif
set grid
set border
set timestamp "%d/%m/%y %H:%M" 80,-2 "Verdana"
set output '$host.id.cpu.gif'
set title "CPU Idle Time Percantage on $host."
set xlabel "Sessions in minutes"
set ylabel "CPU Idle Time Percantage"
plot "$host.id.cpu" with lines
set output '$host.wt.cpu.gif'
set title "CPU I/O Wait Percantage on $host."
set xlabel "Sessions in minutes"
set ylabel "CPU I/O Wait I/O Percantage"
plot "$host.wt.cpu" with lines
set output '$host.memory.gif'
set title "Free memory size on $host"
set xlabel "Sessions in minutes"
set ylabel "Free memory size (Mega Bytes)"
plot "$host.memory" with lines
exit
EOF
	
