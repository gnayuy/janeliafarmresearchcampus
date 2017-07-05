#!/bin/bash
#
# fly brain alignment pipeline 3.0. Sep 20, 2012. Yang Yu. 
#

PORT=1031
while (test -f "/tmp/.X${PORT}-lock") || (netstat -atwn | grep "^.*:${PORT}.*:\*\s*LISTEN\s*$")
do PORT=$(( ${PORT} + 1 ))
done
/usr/bin/Xvfb :${PORT} -screen 0 1x1x24 -sp /usr/lib64/xserver/SecurityPolicy -fp /usr/share/X11/fonts/misc &
MYPID=$!
export DISPLAY="localhost:${PORT}.0"

################################################################################
# 
# The pipeline is developed for solving 63x fly brain alignment problems.
#
# Target brain's resolution (0.38x0.38x0.38 um)
#
################################################################################

##################
# TOOLKITS
##################

#Vaa3D
Vaa3D="/groups/scicomp/jacsData/yuTest/YoshiMB/toolkits/Vaa3D/vaa3d"

#JBA
JBA="/groups/scicomp/jacsData/yuTest/Tanya/toolkits/JBA/brainaligner"

#ANTS
ANTS="/groups/scicomp/jacsData/yuTest/YoshiMB/toolkits/ANTS/ANTS"
WARP="/groups/scicomp/jacsData/yuTest/YoshiMB/toolkits/ANTS/WarpImageMultiTransform"
SMPL="/groups/scicomp/jacsData/yuTest/YoshiMB/toolkits/ANTS/ResampleImageBySpacing"


##################
# Inputs
##################

NUMPARAMS=$#
if [ $NUMPARAMS -lt 10 ]
then
echo " "
echo " USAGE ::  "
echo " sh brainalign63x.sh target target_ref_no target_marker subject subject_ref_no output target_ori res_x res_y res_z"
echo " "
exit
fi

# landmarks
TARLANDMARKS=$3

# target
TAR=$1
TARREF=$2

# subject
SUB=$4
SUBREF=$5

# output
OUTPUT=$6

# origianl target
ATLAS=$7

# subject's resolution
RESX=$8
RESY=$9
RESZ=${10}


STR=`echo $OUTPUT | awk -F\. '{print $1}'`

echo "1  TARLANDMARKS: $TARLANDMARKS"
echo "2  TAR: $TAR"
echo "3  TARREF: $TARREF"
echo "4  SUB: $SUB"
echo "5  SUBREF: $SUBREF"
echo "6  OUTPUT: $OUTPUT"
echo "7  ATLAS: $ATLAS"
echo "8  RESX: $RESX"
echo "9  RESY: $RESY"
echo "10 RESZ: $RESZ"

##################
# Sampling
##################

RES_X=0.38
RES_Y=0.38
RES_Z=0.38

SRX=`echo $RESX/$RES_X | bc -l`
SRY=`echo $RESY/$RES_Y | bc -l`
SRZ=`echo $RESZ/$RES_Z | bc -l`

SRXC=$(bc <<< "$SRX - 1.0")
SRYC=$(bc <<< "$SRY - 1.0")
SRZC=$(bc <<< "$SRZ - 1.0")

ASRXC=`echo $SRXC | awk '{ print ($1 >= 0) ? $1 : 0 - $1}'`
ASRYC=`echo $SRYC | awk '{ print ($1 >= 0) ? $1 : 0 - $1}'`
ASRZC=`echo $SRZC | awk '{ print ($1 >= 0) ? $1 : 0 - $1}'`


if [ $(bc <<< "$ASRXC < 0.01") -eq 1 ] && [ $(bc <<< "$ASRYC < 0.01") -eq 1 ] && [ $(bc <<< "$ASRZC < 0.01") -eq 1 ]; then

echo "No interpolation needed!"

else

SUBIS=$STR"Isotropic.v3draw"

#---exe---#
$Vaa3D -x ireg -f isampler -i $SUB -o $SUBIS -p "#x $SRX #y $SRY #z $SRZ"

SUB=$SUBIS

fi


##################
# flip along z
##################

SUBFLIP=$STR"zFliped.v3draw"

#---exe---#
##$Vaa3D -x ireg -f zflip -i $SUB -o $SUBFLIP
##SUB=$SUBFLIP


##################
# Alignment
##################

#
### global alignment using ANTS Rigid/Affine Registration
#

TARREF=$((TARREF-1));
SUBREF=$((SUBREF-1));

MAXITERATIONS=10000x10000x10000x10000x10000
GRADDSCNTOPTS=0.5x0.95x1.e-4x1.e-4

SAMPLERATIO=4

STRT=`echo $TAR | awk -F\. '{print $1}'`
STRS=`echo $SUB | awk -F\. '{print $1}'`

FIXED=$STRT"_c"$TARREF".nii"
MOVING=$STRS"_c"$SUBREF".nii"

MOVINGC1=$STRS"_c0.nii"
MOVINGC2=$STRS"_c1.nii"
MOVINGC3=$STRS"_c2.nii"
MOVINGC4=$STRS"_c3.nii"

SUBGAC1=$STRS"_rrc0.nii"
SUBGAC2=$STRS"_rrc1.nii"
SUBGAC3=$STRS"_rrc2.nii"
SUBGAC4=$STRS"_rrc3.nii"

SUBDeformed=$STR"Aligned63Scaled.v3draw"

STRT=`echo $FIXED | awk -F\. '{print $1}'`
FIXEDDS=$STRT"_ds.nii"
STRS=`echo $MOVING | awk -F\. '{print $1}'`
MOVINGDS=$STRS"_ds.nii"

#---exe---#
##$Vaa3D -x ireg -f NiftiImageConverter -i $TAR
$Vaa3D -x ireg -f NiftiImageConverter -i $SUB

#---exe---#
##$SMPL 3 $FIXED $FIXEDDS $SAMPLERATIO $SAMPLERATIO $SAMPLERATIO
$SMPL 3 $MOVING $MOVINGDS $SAMPLERATIO $SAMPLERATIO $SAMPLERATIO 

SIMMETRIC=$STR"cc"
AFFINEMATRIX=$STR"ccAffine.txt"
FWDDISPFIELD=$STR"ccWarp.nii.gz"
BWDDISPFIELD=$STR"ccInverseWarp.nii.gz"

MAXITERSCC=30x90x20
MAXITERSMI=32x77045760

#---exe---#
##$ANTS 3 -m  MI[ $FIXEDDS, $MOVINGDS, 1, 32] -o $SIMMETRIC -i 0 --use-Histogram-Matching  --number-of-affine-iterations $MAXITERATIONS --rigid-affine true --affine-gradient-descent-option $GRADDSCNTOPTS 
$ANTS 3 -m  MI[ $FIXEDDS, $MOVINGDS, 1, 32] -o $SIMMETRIC -i 0 --use-Histogram-Matching  --number-of-affine-iterations $MAXITERATIONS --rigid-affine false

#
### local alignment using ANTS SyN
#

#---exe---#
$ANTS 3 -m  CC[ $FIXEDDS, $MOVINGDS, 0.75, 4] -m MI[ $FIXEDDS, $MOVINGDS, 0.25, 32] -t SyN[0.25]  -r Gauss[3,0] -o $SIMMETRIC -i $MAXITERSCC --initial-affine $AFFINEMATRIX


#---exe---#
$WARP 3 $MOVINGC1 $SUBGAC1 -R $FIXED $FWDDISPFIELD $AFFINEMATRIX --use-BSpline
$WARP 3 $MOVINGC2 $SUBGAC2 -R $FIXED $FWDDISPFIELD $AFFINEMATRIX --use-BSpline
$WARP 3 $MOVINGC3 $SUBGAC3 -R $FIXED $FWDDISPFIELD $AFFINEMATRIX --use-BSpline
$WARP 3 $MOVINGC4 $SUBGAC4 -R $FIXED $FWDDISPFIELD $AFFINEMATRIX --use-BSpline

#---exe---#
$Vaa3D -x ireg -f NiftiImageConverter -i $SUBGAC1 $SUBGAC2 $SUBGAC3 $SUBGAC4 -o $SUBDeformed -p "#b 1 #v 1"


##################
# 20x scale result
##################

LARS=$STR"cnvt20xscale.v3draw"
LAOUTPUTRS=$STR"Aligned20xScale.v3draw"

#---exe---#
$Vaa3D -x ireg -f isampler -i $SUBDeformed -o $LARS -p "#x 0.6129 #y 0.6129 #z 0.6129"

#---exe---#
$Vaa3D -x ireg -f prepare20xData -o $LAOUTPUTRS -p "#s $LARS #t $ATLAS"


##################
# clean temp files
##################

#---exe---#
##rm $FIXED $MOVING

# We're done with the frame buffer
kill -9 $MYPID


