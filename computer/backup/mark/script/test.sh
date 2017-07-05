ANTS=/groups/scicomp/jacsData/yuTest/toolkits/ANTS/ANTS
WarpImageMultiTransform=/groups/scicomp/jacsData/yuTest/toolkits/ANTS/WarpImageMultiTransform

#FIXEDDS=/groups/scicomp/jacsData/yuTest/markReconstruction/Alignment/target/atlasVolume.tif
#MOVINGDS=/groups/scicomp/jacsData/yuTest/markReconstruction/Alignment/subject/subject_b.tif

FIXEDDS=/groups/scicomp/jacsData/yuTest/markReconstruction/Alignment/target.nii
MOVINGDS=/groups/scicomp/jacsData/yuTest/markReconstruction/Alignment/subject_b_w.nii

INITAFFINE=/groups/scicomp/jacsData/yuTest/markReconstruction/Alignment/subject/globalalignAffine.txt

SIMMETRIC=/groups/scicomp/jacsData/yuTest/markReconstruction/Alignment/subject/test4
MAXITERSCC=20x0

#time $ANTS 3 -m  CC[ $FIXEDDS, $MOVINGDS, 0.75, 4] -m MI[ $FIXEDDS, $MOVINGDS, 0.25, 32] -t SyN[0.25]  -r Gauss[3,0] -o $SIMMETRIC -i $MAXITERSCC --initial-affine $INITAFFINE

#time $WarpImageMultiTransform 3 $MOVINGDS /groups/scicomp/jacsData/yuTest/markReconstruction/Alignment/subject/subject_b_la.tif -R $FIXEDDS /groups/scicomp/jacsData/yuTest/markReconstruction/Alignment/subject/laWarp.nii.gz /groups/scicomp/jacsData/yuTest/markReconstruction/Alignment/subject/laAffine.txt --use-BSpline


#time $ANTS 3 -m MI[ $FIXEDDS, $MOVINGDS, 1, 32] -t SyN[0.25]  -r Gauss[3,0] -o $SIMMETRIC -i $MAXITERSCC --initial-affine $INITAFFINE


time $ANTS 3 -m MI[ $FIXEDDS, $MOVINGDS, 1, 32] -t SyN[0.25]  -r Gauss[3,0] -o $SIMMETRIC -i $MAXITERSCC
