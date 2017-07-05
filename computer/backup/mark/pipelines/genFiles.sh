'
for((i=0; i<87; i++))
do

./ifilter -f seq2stack -i /groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/tmp/files$i.txt -o /groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/tmp/warpedstack$i.nii

done

'

for((i=0; i<99; i++))
do

./ifilter -f seq2stack -i /groups/jacs/jacsShare/yuTest/Share4Mark/wb1335043/alignment/blue/files$i.txt -o /groups/jacs/jacsShare/yuTest/Share4Mark/wb1335043/alignment/blue/warpedstack$i.nii

done
