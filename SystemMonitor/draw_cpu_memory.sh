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
set yrange [0:]
set title "CPU Idle Time Percantage on $host."
set xlabel "Time (mins)"
set ylabel "CPU Idle Time Percantage"
plot "$host.id.cpu" with lines
set output '$host.wt.cpu.gif'
set yrange [0:]
set title "CPU I/O Wait Percantage on $host."
set xlabel "Time (mins)"
set ylabel "CPU I/O Wait I/O Percantage"
plot "$host.wt.cpu" with lines
set output '$host.memory.gif'
set yrange [0:]
set title "Free memory size on $host"
set xlabel "Time (mins)"
set ylabel "Free memory (MB)"
plot "$host.memory" with lines
exit
EOF
	
