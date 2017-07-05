# warpsectionimage.sh
# Yang Yu <yuy@janelia.hhmi.org>


### input

PRE=$1
SUFFIX=$2
FIX=$3
OUT=$4

SN=$5
TN=$6

WARPFOLDER=$7

DIM=$8


### pipeline

n=$SN
p=$TN

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

ORDER="f"$SN"t"$TN

./WarpImageMultiTransform $DIM ${PRE}${n}${SUFFIX} ${OUT}${p}.nii -R ${PRE}${n}${SUFFIX} $WARPFOLDER/${ORDER}"Warp.nii.gz" $WARPFOLDER/${ORDER}"Affine.txt" --use-BSpline


