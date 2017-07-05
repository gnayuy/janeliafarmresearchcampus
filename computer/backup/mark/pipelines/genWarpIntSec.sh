# genWarpIntSec.sh
# Yang Yu <yuy@janelia.hhmi.org>

### input

SLIST=$1
PRE=$2


###
i=0
while read line
do

n=($line); 

seclist[$i]=${n[1]};
i=$((i+1))

done < $SLIST

#

n=$i;

cur=${seclist[0]};

for((i=1; i<n; i++))
do

##
nxt=${seclist[$i]};

nnxt=$((cur+1));

##
if(( nnxt < nxt ))
then

oricur=$cur
mid=$(( (nxt+cur)/2 ));

#echo "mid $mid"

if((nnxt<=mid))
then
# condition 3

echo $PRE $cur $nnxt 3

while(( nnxt < mid ))
do

cur=$nnxt
nnxt=$((nnxt+1))

echo $PRE $cur $nnxt 4

done # while nnxt

cur=$nxt
nnxt=$((cur-1))

echo $PRE $cur $nnxt 1

while(( nnxt > mid+1 ))
do

cur=$nnxt
nnxt=$((nnxt-1))

echo $PRE $cur $nnxt 2

done # while nnxt

fi

fi

cur=$nxt


done # for


