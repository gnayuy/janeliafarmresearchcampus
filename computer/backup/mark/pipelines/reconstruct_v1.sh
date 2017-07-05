ANTS=/groups/scicomp/jacsData/yuTest/toolkits/ANTS/ANTS
WARP=/groups/scicomp/jacsData/yuTest/toolkits/ANTS/WarpImageMultiTransform
Vaa3D=/groups/scicomp/jacsData/yuTest/toolkits/Vaa3D/vaa3d

WORKDIR=/groups/scicomp/jacsData/yuTest/markReconstruction/MouseBrain1335038/temp

prefix=/groups/scicomp/jacsData/yuTest/markReconstruction/MouseBrain1335038/temp/section
suffix=.tif

MOV0=${prefix}101_ref_c0.nii

for((i=100; i>0; i--))
do

#time ./ireg -f convertColor2Grayscale -i ${prefix}${i}.tif -o ${prefix}${i}_ref.tif

nn=$((i+1))
n=$i;


FIX=${prefix}${nn}"_ref_c0_warped.nii"
MOV=${prefix}${n}"_ref_c0.nii"
OUTPUT=${prefix}${n}"_ref_c0_warped.nii"
AFFINE=$WORKDIR/affine/mi_$n"_"$nn


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


I1=${prefix}${n}"_c0.nii"
I2=${prefix}${n}"_c1.nii"
I3=${prefix}${n}"_c2.nii"

I1w=${prefix}${n}"_c0_w.nii"
I2w=${prefix}${n}"_c1_w.nii"
I3w=${prefix}${n}"_c2_w.nii"

AFFINE=$WORKDIR/affine/mi_$n"_"$nn"Affine.txt"

time $WARP 2 ${I1} ${I1w} -R $I1 ${AFFINE};
time $WARP 2 ${I2} ${I2w} -R $I1 ${AFFINE};
time $WARP 2 ${I3} ${I3w} -R $I1 ${AFFINE};

I=${prefix}${n}"_aligned.v3draw"

time $Vaa3D -x ireg -f NiftiImageConverter -i $I1w $I2w $I3w -o $I -p "#b 1 #v 1";


done



