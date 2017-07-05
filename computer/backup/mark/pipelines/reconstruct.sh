ANTS=/groups/scicomp/jacsData/yuTest/toolkits/ANTS/ANTS
WARP=/groups/scicomp/jacsData/yuTest/toolkits/ANTS/WarpImageMultiTransform
Vaa3D=/groups/scicomp/jacsData/yuTest/toolkits/Vaa3D/vaa3d

WORKDIR=/home/yuy/work/data/markCembrowski/wholeBrain1327783/section
MOV0=/home/yuy/work/data/markCembrowski/wholeBrain1327783/section/section_001_ref_c0.nii


for((i=96; i<97; i++))
do

nn=$((i-1))

if((i<10))
then

n="00"$i;

else #((i<100))

n="0"$i;

fi

if((nn<10))
then

nn="00"$nn;

else #((i<100))

nn="0"$nn;

fi


FIX="$WORKDIR/section_"$nn"_ref_c0_warped.nii"
MOV="$WORKDIR/section_"$n"_ref_c0.nii"
OUTPUT="$WORKDIR/section_"$n"_ref_c0_warped.nii"
AFFINE=$WORKDIR/affine/mi_$n"_"$nn

echo $FIX $MOV


time $ANTS 2 -m MI[$FIX,${MOV}, 1, 32 ] -o $AFFINE -i 0 --number-of-affine-iterations 10000x10000x10000x10000 --rigid-affine true

time $WARP 2 ${MOV} ${OUTPUT} -R $FIX ${AFFINE}"Affine.txt"

MOV2="$WORKDIR/workdir/section_1327717_"$((i+1))"_yflip_c2.nii"
OUTPUT2="$WORKDIR/workdir/section_1327717_"$((i+1))"_yflip_c2_warped.nii"


#time $WARP 2 ${MOV} ${OUTPUT} -R $FIX ${AFFINE}"Affine.txt"
#time $WARP 2 ${MOV2} ${OUTPUT2} -R $FIX ${AFFINE}"Affine.txt"

#MOV0="$WORKDIR/workdir/section_1327717_"$((i+1))"_yflip_c0.nii"

#time $Vaa3D -x NiftiImageConverter -i $MOV0 $OUTPUT $OUTPUT2 -o "$WORKDIR/workdir/section_1327717_"$i"_aligned.v3draw" -p "#b 1 #v 1"
#time $Vaa3D -x NiftiImageConverter -i $OUTPUT $OUTPUT2 -o "$WORKDIR/workdir/section_1327717_"$i"_aligned.v3draw" -p "#b 1 #v 1"

OUTTIF1=${OUTPUT%*.nii}.tif
OUTTIF2=${OUTPUT2%*.nii}.tif

#./ireg -f imageReadWrite -i $OUTPUT -o $OUTTIF1
#./ireg -f imageReadWrite -i $OUTPUT2 -o $OUTTIF2

#$Vaa3D -x ireg -f yflip -i $OUTTIF1 -o ${OUTTIF1%*.tif}.v3draw;
#$Vaa3D -x ireg -f yflip -i $OUTTIF2 -o ${OUTTIF2%*.tif}.v3draw;

#time $Vaa3D -x ireg -f mergeColorChannels -i $MOV0 ${OUTTIF1%*.tif}.v3draw ${OUTTIF2%*.tif}.v3draw -o "$WORKDIR/workdir/section_1327717_"$i"_aligned.v3draw"


I1="$WORKDIR/section_"$n"_c0.nii"
I2="$WORKDIR/section_"$n"_c1.nii"
I3="$WORKDIR/section_"$n"_c2.nii"

I1w="$WORKDIR/section_"$n"_c0_w.nii"
I2w="$WORKDIR/section_"$n"_c1_w.nii"
I3w="$WORKDIR/section_"$n"_c2_w.nii"

AFFINE=$WORKDIR/affine/mi_$n"_"$nn"Affine.txt"

$WARP 2 ${I1} ${I1w} -R $I1 ${AFFINE};
$WARP 2 ${I2} ${I2w} -R $I1 ${AFFINE};
$WARP 2 ${I3} ${I3w} -R $I1 ${AFFINE};

I="$WORKDIR/section_"$n"_aligned.v3draw"

$Vaa3D -x ireg -f NiftiImageConverter -i $I1w $I2w $I3w -o $I -p "#b 1 #v 1";


done



