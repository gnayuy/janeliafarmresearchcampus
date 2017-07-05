

### input

N=$1

PREFIX=$2
SUFFIX=$3
OUTPRE=$4

AFFINE=$5

DIM=$6

### pipeline

#p=0;

for((i=1; i<$N; i++))
do

n=$i

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

mov=$PREFIX$p$SUFFIX
out=$OUTPRE$p.nii
#aff=$AFFINE"_"$p"_"$n"Affine.txt"
aff=$AFFINE"_"$i"_"$((i+1))"Affine.txt"


./WarpImageMultiTransform $DIM ${mov} ${out} -R ${mov} ${aff} --use-BSpline

done
