


for((i=0; i<99; i++))
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

#./WarpImageMultiTransform 2 /groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/subjectseq/ga_ds_rc${n}.tif /groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/alignment/sec${i}/$ORDER.nii -R /groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/targetseq/atlasSec$p.tif /groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/alignment/${ORDER}"Warp.nii.gz" /groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/alignment/${ORDER}"Affine.txt" --use-BSpline


./WarpImageMultiTransform 2 /groups/jacs/jacsShare/yuTest/Share4Mark/wb1335043/ga/blue_ds_rc/blue_ds_rc${n}.tif /groups/jacs/jacsShare/yuTest/Share4Mark/wb1335043/alignment/blue/sec${i}/$ORDER.nii -R /groups/jacs/jacsShare/yuTest/Share4Mark/AMBA/resliced/targetseq/atlasSec$p.tif /groups/jacs/jacsShare/yuTest/Share4Mark/wb1335043/alignment/blue/sec${i}/${ORDER}"Warp.nii.gz" /groups/jacs/jacsShare/yuTest/Share4Mark/wb1335043/alignment/blue/sec${i}/${ORDER}"Affine.txt" --use-BSpline

done # j

done # i
