

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

SC=$PRE$i"/f"$i"t"$j"_l_byte.txt"


while read LINE
do

read score

done < $SC

echo $score >> $OUT


done

#echo "\n" >> $OUT

done

