ANTS=/groups/scicomp/jacsData/yuTest/toolkits/ANTS/ANTS
WARP=/groups/scicomp/jacsData/yuTest/toolkits/ANTS/WarpImageMultiTransform
Vaa3D=/groups/scicomp/jacsData/yuTest/toolkits/Vaa3D/vaa3d

WORKDIR=/groups/scicomp/jacsData/yuTest/markReconstruction/workdir/wholeBrain1335043/workdir

ls $WORKDIR

### step 1
pre=/groups/scicomp/jacsData/yuTest/markReconstruction/workdir/wholeBrain1335043/ori/1335043_

for i in /groups/scicomp/jacsData/yuTest/markReconstruction/workdir/wholeBrain1335043/ori/*.tif; do j=${i#$pre*}; k=${j%*_*}; l="_"${j#*_*}; if((k<10)); then k="0"$k; fi; mv $i $pre$k$l; done

prefix=/groups/scicomp/jacsData/yuTest/markReconstruction/workdir/wholeBrain1335043/sectionra/section
suffix=.tif

cnt=1;

for i in /groups/scicomp/jacsData/yuTest/markReconstruction/workdir/wholeBrain1335043/ori/*.tif
do
#ln -s $i $prefix$cnt$suffix;
#-#./ifilter -f resizeImage -i $i -o $prefix$cnt$suffix;
cnt=$((cnt+1));
done

cnt=$((cnt-1));

### step 2

MOV0=${prefix}${cnt}_ref_c0.nii

ln -s $MOV0 ${prefix}${cnt}"_ref_c0_warped.nii"


for((i=$cnt; i>0; i--))
do

#time ./ifilter -f convertColor2Grayscale -i ${prefix}${i}.tif -o ${prefix}${i}_ref.tif
#time $Vaa3D -x ireg -f NiftiImageConverter -i ${prefix}${i}.tif
#time $Vaa3D -x ireg -f NiftiImageConverter -i ${prefix}${i}_ref.tif

echo "$cnt $i"

done

cnt=$((cnt-1));

for((i=$cnt; i>0; i--))
do

nn=$((i+1))
n=$i;


FIX=${prefix}${nn}"_ref_c0_warped.nii"
MOV=${prefix}${n}"_ref_c0.nii"
OUTPUT=${prefix}${n}"_ref_c0_warped.nii"
AFFINE=$WORKDIR/affine/mi_$n"_"$nn


time $ANTS 2 -m MI[$FIX,${MOV}, 1, 32 ] -o $AFFINE -i 0 --number-of-affine-iterations 10000x10000x10000x10000 --rigid-affine true

time $WARP 2 ${MOV} ${OUTPUT} -R $FIX ${AFFINE}"Affine.txt"

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


Io=${prefix}${n}".tif"
Ir=${prefix}${n}"_aligned.tif"

time ./ifilter -f rescaleIntensity -i $I -o $Ir -p "-f  $Io"


done



