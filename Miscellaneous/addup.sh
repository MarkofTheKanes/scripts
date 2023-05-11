#!/usr/local/bin/bash


# Utility to add up the values in a column
# Give a colum number and it will sum that colum number through awk
#
#
# Paulo 12th August 2002



case "$1" in
[1-9]*) colnum="$1"; shift;;
*) echo "Usage: `basename $0` colnum [files]" 1>&2; exit 1;;
esac

# Use integer output, but switch to %.4f format if "." in input.
awk '{sum += $col}
END {print sum}' col=$colnum OFMT='%.4f' ${1+"$@"}
