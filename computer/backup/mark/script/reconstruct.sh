# preprocess

N=$1
PRE=$2
WARPPRE=$3
FIX=$4

for((i=1; i<N; i++))
do

p=$((i-1))

if((p<10))
then
p="000"$p;
elif((p<100))
then
p="00"$p;
elif((p<1000))
then
p="0"$p;
fi

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

FIX=$PRE$p.tif
MOV=$PRE$n.tif

#time ./ANTS 2 -m MI[$FIX, $MOV, 1, 32 ] -o $WARPPRE$i -i 0 --number-of-affine-iterations 10000x10000x10000x10000

time ./ANTS 2 -m  CC[ $FIX, $MOV, 1, 4] -t SyN[0.25] -r Gauss[3,0] -o $WARPPRE$i -i 90x20x30 #--initial-affine $WARPPRE${i}Affine.txt

OUT=$WARPPRE${n}".tif"

time ./WarpImageMultiTransform 2 $MOV $OUT -R $MOV $WARPPRE${i}Warp.nii.gz $WARPPRE${i}Affine.txt 


done

