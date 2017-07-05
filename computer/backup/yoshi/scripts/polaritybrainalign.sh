#!/bin/bash
#
# fly brain alignment pipeline for polarity data. Oct 5, 2012. Yang Yu. 
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
# The pipeline is developed for aligning polarity fly brains.
#
################################################################################

##################
# TOOLKITS
##################

#Vaa3D
Vaa3D="/groups/scicomp/jacsData/yuTest/YoshiMB/toolkits/Vaa3D/vaa3d"

#ANTS
ANTS="/groups/scicomp/jacsData/yuTest/YoshiMB/toolkits/ANTS/ANTS"
WARP="/groups/scicomp/jacsData/yuTest/YoshiMB/toolkits/ANTS/WarpImageMultiTransform"
SMPL="/groups/scicomp/jacsData/yuTest/YoshiMB/toolkits/ANTS/ResampleImageBySpacing"


##################
# Inputs
##################

NUMPARAMS=$#
if [ $NUMPARAMS -lt 15 ]
then
echo " "
echo " USAGE ::  "
echo " sh polaritybrainalign target20x target20x_ref_no target63x target63x_ref_no subject20x subject20x_ref_no subject63x subject63x_ref_no output resx20x resy20x resz20x resx63x resy63x resz63"
echo " "
exit
fi

# target
TARTX=$1
TARTXREF=$2
TARSX=$3
TARSXREF=$4

# subject
SUBTX=$5
SUBTXREF=$6
SUBSX=$7
SUBSXREF=$8

# output
OUTPUT=$9

# subject's resolution
RESTXX=${10}
RESTXY=${11}
RESTXZ=${12}
RESSXX=${13}
RESSXY=${14}
RESSXZ=${15}

STR=`echo $OUTPUT | awk -F\. '{print $1}'`

echo "1  TARTX: $TARTX"
echo "2  TARTXREF: $TARTXREF"
echo "3  TARSX: $TARSX"
echo "4  TARSXREF: $TARSXREF"
echo "5  SUBTX: $SUBTX"
echo "6  SUBTXREF: $SUBTXREF"
echo "7  SUBSX: $SUBSX"
echo "8  SUBSXREF: $SUBSXREF"
echo "9  OUTPUT: $OUTPUT"
echo "10 RESTXX: $RESTXX"
echo "11 RESTXY: $RESTXY"
echo "12 RESTXZ: $RESTXZ"
echo "13 RESSXX: $RESSXX"
echo "14 RESSXY: $RESSXY"
echo "15 RESSXZ: $RESSXZ"


######################################################
# STEP 1. Align 20x subject to 20x unified target
######################################################

####################################
# A. Isotropic Sampling
####################################

SRZ=`echo $RESTXZ/$RESTXY | bc -l`
SRZC=$(bc <<< "$SRZ - 1.0")
ASRZC=`echo $SRZC | awk '{ print ($1 >= 0) ? $1 : 0 - $1}'`

if [ $(bc <<< "$ASRZC < 0.01") -eq 1 ]; then

echo "No isotropic interpolation needed!"

else

SUBTXIS=$STR"Isotropic.v3draw"

#---exe---#
#-#$Vaa3D -x ireg -f isampler -i $SUBTX -o $SUBTXIS -p "#x 1.0 #y 1.0 #z $SRZ"

SUBTX=$SUBTXIS

fi

####################################
# B. Alignment
####################################

#
### global alignment using ANTS Rigid Registration
#

TARTXREF=$((TARTXREF-1));
SUBTXREF=$((SUBTXREF-1));

MAXITERATIONS=10000x10000x10000x10000x10000
GRADDSCNTOPTS=0.5x0.95x1.e-4x1.e-4

SAMPLERATIO=2

STRT=`echo $TARTX | awk -F\. '{print $1}'`
STRS=`echo $SUBTX | awk -F\. '{print $1}'`

FIXED=$STRT"_c"$TARTXREF".nii"
MOVING=$STRS"_c"$SUBTXREF".nii"

MOVINGC1=$STRS"_c0.nii"
MOVINGC2=$STRS"_c1.nii"
MOVINGC3=$STRS"_c2.nii"
MOVINGC4=$STRS"_c3.nii"

SUBGAC1=$STRS"_rrc0.nii"
SUBGAC2=$STRS"_rrc1.nii"
SUBGAC3=$STRS"_rrc2.nii"
SUBGAC4=$STRS"_rrc3.nii"

SUBDeformed=$STR"TXAligned.v3draw"

STRT=`echo $FIXED | awk -F\. '{print $1}'`
FIXEDDS=$STRT"_ds.nii"
STRS=`echo $MOVING | awk -F\. '{print $1}'`
MOVINGDS=$STRS"_ds.nii"

#---exe---#
$Vaa3D -x ireg -f NiftiImageConverter -i $TARTX
#-#$Vaa3D -x ireg -f NiftiImageConverter -i $SUBTX

#---exe---#
$SMPL 3 $FIXED $FIXEDDS $SAMPLERATIO $SAMPLERATIO $SAMPLERATIO
#-#$SMPL 3 $MOVING $MOVINGDS $SAMPLERATIO $SAMPLERATIO $SAMPLERATIO 

SIMMETRIC=$STR"TXcc"
AFFINEMATRIX=$STR"TXccAffine.txt"
FWDDISPFIELD=$STR"TXccWarp.nii.gz"
BWDDISPFIELD=$STR"TXccInverseWarp.nii.gz"

MAXITERSCC=30x90x20

#---exe---#
##$ANTS 3 -m  MI[ $FIXEDDS, $MOVINGDS, 1, 32] -o $SIMMETRIC -i 0 --use-Histogram-Matching  --number-of-affine-iterations $MAXITERATIONS --rigid-affine true --affine-gradient-descent-option $GRADDSCNTOPTS 
$ANTS 3 -m  MI[ $FIXEDDS, $MOVINGDS, 1, 32] -o $SIMMETRIC -i 0 --use-Histogram-Matching  --number-of-affine-iterations $MAXITERATIONS --rigid-affine false

#
### local alignment using ANTS SyN
#

#---exe---#
$ANTS 3 -m  CC[ $FIXEDDS, $MOVINGDS, 0.75, 4] -m MI[ $FIXEDDS, $MOVINGDS, 0.25, 32] -t SyN[0.25]  -r Gauss[3,0] -o $SIMMETRIC -i $MAXITERSCC --initial-affine $AFFINEMATRIX

#---exe---#
#-#$WARP 3 $MOVINGC1 $SUBGAC1 -R $FIXED $FWDDISPFIELD $AFFINEMATRIX --use-BSpline
#-#$WARP 3 $MOVINGC2 $SUBGAC2 -R $FIXED $FWDDISPFIELD $AFFINEMATRIX --use-BSpline
#-#$WARP 3 $MOVINGC3 $SUBGAC3 -R $FIXED $FWDDISPFIELD $AFFINEMATRIX --use-BSpline
#-#$WARP 3 $MOVINGC4 $SUBGAC4 -R $FIXED $FWDDISPFIELD $AFFINEMATRIX --use-BSpline

#---exe---#
#-#$Vaa3D -x ireg -f NiftiImageConverter -i $SUBGAC1 $SUBGAC2 $SUBGAC3 $SUBGAC4 -o $SUBDeformed -p "#b 1 #v 1"


######################################################
# STEP 2. Align 63x subject to upsampled 20x subject
######################################################


####################################
# A. Up-Sampling
####################################

SUBTXISREF=${STR}"_isref.v3draw"

STRT=`echo $SUBTXISREF | awk -F\. '{print $1}'`
SUBTXUSRAW=${STRT}"_us.v3draw"

# isotropic resx=resy=resz
#RESTXX=0.62
SRX=`echo $RESTXX/$RESSXX | bc -l`
SRY=`echo $RESTXX/$RESSXY | bc -l`
SRZ=`echo $RESTXX/$RESSXZ | bc -l`

#---exe---#
#-#$Vaa3D -x ireg -f NiftiImageConverter -i $MOVING -o $SUBTXISREF -p "#b 1 #v 1"
#-#$Vaa3D -x ireg -f isampler -i $SUBTXISREF -o $SUBTXUSRAW -p "#x ${SRX} #y ${SRY} #z ${SRZ}"

#-#SUBTXUSRZ=${STRT}"_usrz.v3draw"
#-##---exe---#
#-##-#$Vaa3D -x ireg -f prepare20xData -o $SUBTXUSRZ -p "#s $SUBTXUSRAW #t $TARSX"

SUBTXUSDS=${STRT}"_us_ds.v3draw"

SRX=`echo 1.0/$SAMPLERATIO | bc -l`
SRY=`echo 1.0/$SAMPLERATIO | bc -l`
SRZ=`echo 1.0/$SAMPLERATIO | bc -l`

#---exe---#
#-#$Vaa3D -x ireg -f isampler -i $SUBTXUSRAW -o $SUBTXUSDS -p "#x ${SRX} #y ${SRY} #z ${SRZ}"

####################################
# B. Alignment
####################################

#
### global alignment using ANTS Rigid Registration
#

SUBSXREF=$((SUBSXREF-1));

#SAMPLERATIO=2

STRT=`echo $SUBTXUSDS | awk -F\. '{print $1}'`
STRS=`echo $SUBSX | awk -F\. '{print $1}'`

FIXED=$STRT"_c"$TARTXREF".nii"
MOVING=$STRS"_c"$SUBSXREF".nii"

MOVINGC1=$STRS"_c0.nii"
MOVINGC2=$STRS"_c1.nii"
MOVINGC3=$STRS"_c2.nii"
MOVINGC4=$STRS"_c3.nii"

SUBGAC1=$STRS"_rrc0.nii"
SUBGAC2=$STRS"_rrc1.nii"
SUBGAC3=$STRS"_rrc2.nii"
SUBGAC4=$STRS"_rrc3.nii"

SUBSXDeformed=$STR"SXAligned.v3draw"

STRT=`echo $FIXED | awk -F\. '{print $1}'`
FIXEDDS=$STRT"_ds_c0.nii"
FIXEDDS=$FIXED

STRS=`echo $MOVING | awk -F\. '{print $1}'`
MOVINGDS=$STRS"_ds_c0.nii"

#---exe---#
#-#$Vaa3D -x ireg -f NiftiImageConverter -i $SUBTXUSDS
#-#$Vaa3D -x ireg -f NiftiImageConverter -i $SUBSX

#---exe---#
#$SMPL 3 $FIXED $FIXEDDS $SAMPLERATIO $SAMPLERATIO $SAMPLERATIO
#-#$SMPL 3 $MOVING $MOVINGDS $SAMPLERATIO $SAMPLERATIO $SAMPLERATIO

SIMMETRIC=$STR"SXcc"
AFFINEMATRIX=$STR"SXccAffine.txt"
FWDDISPFIELD=$STR"SXccWarp.nii.gz"
BWDDISPFIELD=$STR"SXccInverseWarp.nii.gz"

MAXITERSCC=30x90x20

#---exe---#
##$ANTS 3 -m  MI[ $FIXEDDS, $MOVINGDS, 1, 32] -o $SIMMETRIC -i 0 --use-Histogram-Matching  --number-of-affine-iterations $MAXITERATIONS --rigid-affine true --affine-gradient-descent-option $GRADDSCNTOPTS 
#-#$ANTS 3 -m  MI[ $FIXEDDS, $MOVINGDS, 1, 32] -o $SIMMETRIC -i 0 --use-Histogram-Matching  --number-of-affine-iterations $MAXITERATIONS --rigid-affine false

#-#echo "$ANTS 3 -m  MI[ $FIXEDDS, $MOVINGDS, 1, 32] -o $SIMMETRIC -i 0 --use-Histogram-Matching  --number-of-affine-iterations $MAXITERATIONS --rigid-affine false "


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
$Vaa3D -x ireg -f NiftiImageConverter -i $SUBGAC1 $SUBGAC2 $SUBGAC3 $SUBGAC4 -o $SUBSXDeformed -p "#b 1 #v 1"

######################################################
# clean temp files
######################################################

#---exe---#
##rm $FIXED $MOVING

# We're done with the frame buffer
kill -9 $MYPID


