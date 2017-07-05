
pp=$1
nn=$2

condition=$3

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

if((condition==1)) # 1>2 case 1
then

SUB=/groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/result/found/sec${p}.nii

OUT=/groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/result/interpolation/sec${n}.nii

WF=/groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/atlasTransforms/f${pp}t${nn}Warp.nii.gz

AFF=/groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/atlasTransforms/f${pp}t${nn}Affine.txt

./WarpImageMultiTransform 2  $SUB $OUT -R $SUB $WF $AFF --use-BSpline

elif((condition==2)) # 1>2 case 2 
then

SUB=/groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/result/interpolation/sec${p}.nii

OUT=/groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/result/interpolation/sec${n}.nii

WF=/groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/atlasTransforms/f${pp}t${nn}Warp.nii.gz

AFF=/groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/atlasTransforms/f${pp}t${nn}Affine.txt

./WarpImageMultiTransform 2  $SUB $OUT -R $SUB $WF $AFF --use-BSpline

elif((condition==3)) # 1<2 case 1
then

SUB=/groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/result/found/sec${p}.nii

OUT=/groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/result/interpolation/sec${n}.nii

WF=/groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/atlasTransforms/f${nn}t${pp}InverseWarp.nii.gz

AFF=/groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/atlasTransforms/f${nn}t${pp}Affine.txt

./WarpImageMultiTransform 2  $SUB $OUT -R $SUB -i $AFF $WF --use-BSpline

elif((condition==4)) # 1<2 case 2
then

SUB=/groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/result/interpolation/sec${p}.nii

OUT=/groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/result/interpolation/sec${n}.nii

WF=/groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/atlasTransforms/f${nn}t${pp}InverseWarp.nii.gz

AFF=/groups/jacs/jacsShare/yuTest/Share4Mark/wbLypd1/downsample/refrb/workdir/warpedfinal/alignment/atlasTransforms/f${nn}t${pp}Affine.txt

./WarpImageMultiTransform 2  $SUB $OUT -R $SUB -i $AFF $WF --use-BSpline

fi




