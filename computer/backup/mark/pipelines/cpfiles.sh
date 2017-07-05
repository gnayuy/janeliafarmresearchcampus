pp=$1
nn=$2


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

cp /groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/alignment/sec$pp/f${pp}t${nn}.nii  /groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/result/found/sec${n}.nii
