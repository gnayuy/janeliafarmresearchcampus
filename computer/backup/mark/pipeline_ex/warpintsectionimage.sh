# warpintsectionimage.sh
# Yang Yu <yuy@janelia.hhmi.org>

### input

PRE=$1
WARPFOLDER=$2

SN=$3
TN=$4

condition=$5

DIM=2

### pipeline

p=$SN
n=$TN

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


if((condition==1)) # 1>2 case 1
then

ORDER="f"$SN"t"$TN

SUB=$PRE/found/sec${p}.nii

OUT=$PRE/interpolation/sec${n}.nii

WF=$WARPFOLDER/${ORDER}Warp.nii.gz

AFF=$WARPFOLDER/${ORDER}Affine.txt

/nobackup/scicompsoft/yuTest/jacs/toolkits/ANTS/WarpImageMultiTransform $DIM $SUB $OUT -R $SUB $AFF --use-BSpline

elif((condition==2)) # 1>2 case 2 
then

ORDER="f"$SN"t"$TN

SUB=$PRE/interpolation/sec${p}.nii

OUT=$PRE/interpolation/sec${n}.nii

WF=$WARPFOLDER/${ORDER}Warp.nii.gz

AFF=$WARPFOLDER/${ORDER}Affine.txt

/nobackup/scicompsoft/yuTest/jacs/toolkits/ANTS/WarpImageMultiTransform $DIM $SUB $OUT -R $SUB $AFF --use-BSpline

elif((condition==3)) # 1<2 case 1
then

ORDER="f"$TN"t"$SN

SUB=$PRE/found/sec${p}.nii

OUT=$PRE/interpolation/sec${n}.nii

WF=$WARPFOLDER/${ORDER}InverseWarp.nii.gz

AFF=$WARPFOLDER/${ORDER}Affine.txt

/nobackup/scicompsoft/yuTest/jacs/toolkits/ANTS/WarpImageMultiTransform $DIM $SUB $OUT -R $SUB -i $AFF --use-BSpline

elif((condition==4)) # 1<2 case 2
then

ORDER="f"$TN"t"$SN

SUB=$PRE/interpolation/sec${p}.nii

OUT=$PRE/interpolation/sec${n}.nii

WF=$WARPFOLDER/${ORDER}InverseWarp.nii.gz

AFF=$WARPFOLDER/${ORDER}Affine.txt

/nobackup/scicompsoft/yuTest/jacs/toolkits/ANTS/WarpImageMultiTransform $DIM $SUB $OUT -R $SUB -i $AFF --use-BSpline

fi



