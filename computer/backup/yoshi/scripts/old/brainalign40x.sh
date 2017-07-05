#!/bin/bash
#
# fly brain alignment pipeline 1.0, Aug 9, 2012 
#

PORT=1031
while (test -f "/tmp/.X${PORT}-lock") || (netstat -atwn | grep "^.*:${PORT}.*:\*\s*LISTEN\s*$")
do PORT=$(( ${PORT} + 1 ))
done
/usr/bin/Xvfb :${PORT} -screen 0 1x1x24 -sp /usr/lib64/xserver/SecurityPolicy -fp /usr/share/X11/fonts/misc &
MYPID=$!
export DISPLAY="localhost:${PORT}.0"

#######################################################################
# 
# The pipeline is developed for solving 40x fly brain
# alignment problems.
#
# The outputs will be aligned results in 40x scale (0.3x0.3x0.3) and
# in 20x scale (0.62x0.62x0.62) respectively.
#
#######################################################################

##################
# TOOLKITS
##################

#Vaa3D
Vaa3D="/groups/scicomp/jacsData/yuTest/YoshiMB/toolkits/Vaa3D/vaa3d"

#JBA
JBA="/groups/scicomp/jacsData/yuTest/YoshiMB/toolkits/JBA/brainaligner"

#ANTS
ANTS="/groups/scicomp/jacsData/yuTest/YoshiMB/toolkits/ANTS/ANTS"
WARP="/groups/scicomp/jacsData/yuTest/YoshiMB/toolkits/ANTS/WarpImageMultiTransform"
SMPL="/groups/scicomp/jacsData/yuTest/YoshiMB/toolkits/ANTS/ResampleImageBySpacing"


##################
# Inputs
##################

NUMPARAMS=$#
if [ $NUMPARAMS -lt 7 ]
then
echo " "
echo " USAGE ::  "
echo " sh brainalign40x.sh target target_ref_no target_marker subject subject_ref_no output target_ori"
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

STR=`echo $OUTPUT | awk -F\. '{print $1}'`

##################
# Alignment
##################

#
### resize and convert to 8-bit data
#

SUBPP=$STR"PreProcessed.v3draw"

#---exe---#
$Vaa3D -x ireg -f prepare20xData -o $SUBPP -p "#s $SUB #t $TAR"

#
### global alignment using ANTS Rigid Registration
#

TARREF=$((TARREF-1));
SUBREF=$((SUBREF-1));

MAXITERATIONS=10000x10000x10000x10000x10000
GRADDSCNTOPTS=0.5x0.95x1.e-4x1.e-4

SAMPLERATIO=4

STRT=`echo $TAR | awk -F\. '{print $1}'`
STRS=`echo $SUBPP | awk -F\. '{print $1}'`

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

SUBGA=$STR"_ga.v3draw"

STRT=`echo $FIXED | awk -F\. '{print $1}'`
FIXEDDS=$STRT"_ds.nii"
STRS=`echo $MOVING | awk -F\. '{print $1}'`
MOVINGDS=$STRS"_ds.nii"

RGDOUT=$STR"Global"
RGDMAT=$RGDOUT"Affine.txt"

#---exe---#
$Vaa3D -x ireg -f NiftiImageConverter -i $TAR
$Vaa3D -x ireg -f NiftiImageConverter -i $SUBPP

#---exe---#
$SMPL 3 $FIXED $FIXEDDS $SAMPLERATIO $SAMPLERATIO $SAMPLERATIO
$SMPL 3 $MOVING $MOVINGDS $SAMPLERATIO $SAMPLERATIO $SAMPLERATIO 

#---exe---#
$ANTS 3 -m  MI[ $FIXEDDS, $MOVINGDS, 1, 32] -o $RGDOUT -i 0 --use-Histogram-Matching  --number-of-affine-iterations $MAXITERATIONS --rigid-affine true --affine-gradient-descent-option $GRADDSCNTOPTS

#---exe---#
$WARP 3 $MOVINGC1 $SUBGAC1 -R $FIXED $RGDMAT
$WARP 3 $MOVINGC2 $SUBGAC2 -R $FIXED $RGDMAT
$WARP 3 $MOVINGC3 $SUBGAC3 -R $FIXED $RGDMAT
$WARP 3 $MOVINGC4 $SUBGAC4 -R $FIXED $RGDMAT

#---exe---#
$Vaa3D -x ireg -f NiftiImageConverter -i $SUBGAC1 $SUBGAC2 $SUBGAC3 $SUBGAC4 -o $SUBGA -p "#b 1 #v 1"

#
### local alignment using JBA
#

GAOUTPUTC0=$STR"_ga_c0.v3draw"
GAOUTPUTC1=$STR"_ga_c1.v3draw"
GAOUTPUTC2=$STR"_ga_c2.v3draw"
GAOUTPUTC3=$STR"_ga_c3.v3draw"

#---exe---#
$Vaa3D -x ireg -f splitColorChannels -i $SUBGA

LAOUTPUTC0=$STR"_la_c0.v3draw"
LAOUTPUTC1=$STR"_la_c1.v3draw"
LAOUTPUTC2=$STR"_la_c2.v3draw"
LAOUTPUTC3=$STR"_la_c3.v3draw"

CSVT=$LAOUTPUTC3"_target.csv"
CSVS=$LAOUTPUTC3"_subject.csv"

#---exe---#
$JBA -t $TAR -s $GAOUTPUTC3 -w 10 -o $LAOUTPUTC3 -L $TARLANDMARKS -B 2048 -H 2

#---exe---#
$JBA -t $TAR -s $GAOUTPUTC0 -w 10 -o $LAOUTPUTC0 -L $CSVT -l $CSVS -B 2048 -H 2
$JBA -t $TAR -s $GAOUTPUTC1 -w 10 -o $LAOUTPUTC1 -L $CSVT -l $CSVS -B 2048 -H 2
$JBA -t $TAR -s $GAOUTPUTC2 -w 10 -o $LAOUTPUTC2 -L $CSVT -l $CSVS -B 2048 -H 2

LAOUTPUT=$STR"Aligned40xScale.v3draw"

#---exe---#
$Vaa3D -x ireg -f mergeColorChannels -i $LAOUTPUTC0 $LAOUTPUTC1 $LAOUTPUTC2 $LAOUTPUTC3 -o $LAOUTPUT

##################
# 20x scale result
##################

LARS=$STR"cnvt20xscale.v3draw"
LAOUTPUTRS=$STR"Aligned20xScale.v3draw"

#---exe---#
$Vaa3D -x ireg -f isampler -i $LAOUTPUT -o $LARS -p "#x 0.48387 #y 0.48387 #z 0.6129"

#---exe---#
$Vaa3D -x ireg -f prepare20xData -o $LAOUTPUTRS -p "#s $LARS #t $ATLAS"

##################
# clean temp files
##################

#---exe---#
##rm $SUBPP $FIXED $MOVING

# We're done with the frame buffer
kill -9 $MYPID


