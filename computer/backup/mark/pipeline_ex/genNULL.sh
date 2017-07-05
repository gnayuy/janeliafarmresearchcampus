# sh genNULL.sh 0 527 /nobackup/scicompsoft/yuTest/markCembrowski/workdir/aligned/blue/links/sec0000.nii /nobackup/scicompsoft/yuTest/markCembrowski/wholeBrainKlk8Inj040214/workdir/dapi/links

S=$1
E=$2

NULL=$3
PRE=$4

for((i=$S; i<=$E; i++))
do

n=$i;

if((n<10))
then
n="000"$n;
elif((n<100))
then
n="00"$n;
elif((n<1000))
then
n="0"$n;
fi

cp $NULL $PRE/sec$n.nii

done
