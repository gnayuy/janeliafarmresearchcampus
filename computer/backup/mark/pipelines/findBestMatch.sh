

for((i=0; i<87; i++))
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

for((j=0; j<528; j++))
do

p=$j

ORDER="f"$i"t"$j

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

./ireg -f imageCompare -i /groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/alignment/sec$i/$ORDER.nii -o /groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/alignment/sec$i/ncc$i.txt -p "-r /groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/targetseq/atlasSec${p}.tif -s 2"

#./ireg -f sumVectorMagnitude -i /groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/alignment/${ORDER}"Warp.nii.gz" -o /groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/alignment/sec0/vecmag.txt

done # j

done # i


