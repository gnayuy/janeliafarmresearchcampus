pp=$1
nn=$2

PRE=$3
OUT=$4

p=$pp

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

n=$nn

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

cp ${PRE}/sec$nn/f${pp}t${nn}.nii  ${OUT}/found/sec${n}.nii
