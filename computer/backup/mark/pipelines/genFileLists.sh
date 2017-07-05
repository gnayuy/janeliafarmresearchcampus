
'

for((i=0; i<87; i++))
do

for((j=0; j<528; j++))
do

echo "/groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/alignment/sec$i/f${i}t${j}.nii">>/groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/tmp/files$i.txt

done #j


done #i



for((j=0; j<528; j++))
do

p=$j

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

echo "/groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/targetseq/atlasSec${p}.tif">>/groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/tmp/templatefiles.txt

done #j

'

for((i=0; i<99; i++))
do

for((j=0; j<528; j++))
do

echo "/groups/jacs/jacsShare/yuTest/Share4Mark/wb1335043/alignment/blue/sec$i/f${i}t${j}.nii">>/groups/jacs/jacsShare/yuTest/Share4Mark/wb1335043/alignment/blue/files$i.txt

done #j


done #i


