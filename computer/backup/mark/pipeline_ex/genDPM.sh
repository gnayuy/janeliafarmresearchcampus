
### input

NM=$1
NF=$2

PRE=$3
OUT=$4


### pipeline

for((i=0; i<$NM; i++))
do

n=$i

for((j=0; j<$NF; j++))
do

p=$j

SC=$PRE/sec$i"/nccf"$j"t"$i".txt"

#echo $SC

while read score
do

echo $score >> $OUT

done < $SC

done

#echo "\n" >> $OUT

done
