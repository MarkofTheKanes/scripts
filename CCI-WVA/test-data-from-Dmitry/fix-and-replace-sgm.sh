#!/bin/bash


for f in *.csv ; do 
   cat $f | sed 's/""/"/g' | sed 's/^"//' | sed 's/"$//' > ${f}1
done




for i in *.csv1 ; do
   head -n 1 $i > ${i}s
   tail -n+2 $i | awk -v OFS='|' -F '|' '{$5="0"; print }'  >> ${i}s
done 

