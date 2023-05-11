
for i in *.csv1s ; do 

  echo $i
  columns=$(head -n 1 $i | tr '|' ',')
  ./cql -e "copy tnf.hrcc_historical_d_1 ($(echo $columns))  from '$(echo $i)'   with header = true and delimiter = '|'"

done
 