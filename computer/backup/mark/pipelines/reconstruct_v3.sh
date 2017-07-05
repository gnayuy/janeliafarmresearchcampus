#
##
#

ANTS=/groups/jacs/jacsShare/yuTest/toolkits/ANTS/ANTS
WARP=/groups/jacs/jacsShare/yuTest/toolkits/ANTS/WarpImageMultiTransform
Vaa3D=/groups/jacs/jacsShare/yuTest/toolkits/Vaa3D/vaa3d

# example
# sh reconstruct_v2.sh /groups/scicomp/jacsData/yuTest/markReconstruction/workdir/wholeBrain1335043/workdir /groups/scicomp/jacsData/yuTest/markReconstruction/workdir/wholeBrain1335043/ori/1335043_

WORKDIR=$1
prefix=$2

N=86

ls $WORKDIR

### step 1

#for i in ${WORKDIR}/ori/*.tif; do j=${i#$pre*}; k=${j%*_*}; l="_"${j#*_*}; if((k<10)); then k="0"$k; fi; mv $i $pre$k$l; done

#prefix=$WORKDIR"/section/section"
suffix=.tif



#cnt=$((cnt-1));

### step 2

cnt=$((N-1));

MOV0=${prefix}${cnt}_c0.nii

#ln -s $MOV0 ${prefix}${cnt}"_c0_warped.nii"



for((i=$cnt; i>0; i--))
do

nn=$((i+1))

if((nn<10))
then
nn="000"$nn;
elif((nn<100))
then
nn="00"$nn;
elif((nn<1000))
then
nn="0"$nn;
fi

n=$i;

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


FIX=${prefix}${nn}"_c0_warped.nii"
MOV=${prefix}${n}"_c0.nii"
OUTPUT=${prefix}${n}"_c0_warped.nii"
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

#time $WARP 2 ${I1} ${I1w} -R $I1 ${AFFINE};
#time $WARP 2 ${I2} ${I2w} -R $I1 ${AFFINE};
#time $WARP 2 ${I3} ${I3w} -R $I1 ${AFFINE};

I=${prefix}${n}"_aligned.v3draw"

#time $Vaa3D -x ireg -f NiftiImageConverter -i $I1w $I2w $I3w -o $I -p "#b 1 #v 1";


Io=${prefix}${n}".tif"
Ir=${prefix}${n}"_aligned.tif"

#time ./ifilter -f rescaleIntensity -i $I -o $Ir -p "-f  $Io"


done



