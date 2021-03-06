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
# The pipeline is developed for solving 63x fly brain
# alignment problems.
#
# The outputs will be aligned results in 63x scale (0.38x0.38x0.38) and
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
echo " sh brainalign63x.sh target target_ref_no target_marker subject subject_ref_no output target_ori"
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


TARREF=$((TARREF-1));

STRT=`echo $TAR | awk -F\. '{print $1}'`
FIXED=$STRT"_c"$TARREF".nii"

STRT=`echo $FIXED | awk -F\. '{print $1}'`
FIXEDDS=$STRT"_ds.nii"

##################
# local align
##################

#
### 7th iteration for local alignment
#

LAOUTPUTC0=$LAOUTPUTC0C0
LAOUTPUTC1=$LAOUTPUTC1C1
LAOUTPUTC2=$LAOUTPUTC2C2
LAOUTPUTC3=$LAOUTPUTC3C3

LAOUTPUTC0C0=$STR"_la_c0_7th.v3draw"
LAOUTPUTC1C1=$STR"_la_c1_7th.v3draw"
LAOUTPUTC2C2=$STR"_la_c2_7th.v3draw"
LAOUTPUTC3C3=$STR"_la_c3_7th.v3draw"

CSVT=$LAOUTPUTC3C3"_target.csv"
CSVS=$LAOUTPUTC3C3"_subject.csv"

#---exe---#
##$JBA -t $TAR -s $LAOUTPUTC3 -w 10 -o $LAOUTPUTC3C3 -L $TARLANDMARKS -B 1672 -H 2

#---exe---#
##$JBA -t $TAR -s $LAOUTPUTC0 -w 10 -o $LAOUTPUTC0C0 -L $CSVT -l $CSVS -B 1672 -H 2
##$JBA -t $TAR -s $LAOUTPUTC1 -w 10 -o $LAOUTPUTC1C1 -L $CSVT -l $CSVS -B 1672 -H 2
##$JBA -t $TAR -s $LAOUTPUTC2 -w 10 -o $LAOUTPUTC2C2 -L $CSVT -l $CSVS -B 1672 -H 2

LAOUTPUT=$STR"Aligned63xScale7thItered.v3draw"

#---exe---#
##$Vaa3D -x ireg -f mergeColorChannels -i $LAOUTPUTC0C0 $LAOUTPUTC1C1 $LAOUTPUTC2C2 $LAOUTPUTC3C3 -o $LAOUTPUT

LARS=$STR"cnvt20xscale7thItered.v3draw"
LAOUTPUTRS=$STR"Aligned20xScale7thItered.v3draw"

#---exe---#
##$Vaa3D -x ireg -f isampler -i $LAOUTPUT -o $LARS -p "#x 0.6129 #y 0.6129 #z 0.6129"

#---exe---#
##$Vaa3D -x ireg -f prepare20xData -o $LAOUTPUTRS -p "#s $LARS #t $ATLAS"

MOVINGC0=$STR"Aligned63xScale7thItered_c0.nii"
MOVINGC1=$STR"Aligned63xScale7thItered_c1.nii"
MOVINGC2=$STR"Aligned63xScale7thItered_c2.nii"
MOVINGC3=$STR"Aligned63xScale7thItered_c3.nii"

#---exe---#
##$Vaa3D -x ireg -f NiftiImageConverter -i $LAOUTPUT

SAMPLERATIO=4
MOVINGDS=$STR"Aligned63xScale7thItered_c3_ds.nii"

#---exe---#
$SMPL 3 $FIXED $FIXEDDS $SAMPLERATIO $SAMPLERATIO $SAMPLERATIO
$SMPL 3 $MOVINGC3 $MOVINGDS $SAMPLERATIO $SAMPLERATIO $SAMPLERATIO 

#MAXITERATIONS=30x90x20
MAXITERATIONS=50x10
SIMMETRIC=$STR"_cc63x"

#---exe---#
$ANTS 3 -m  CC[ $FIXEDDS, $MOVINGDS, 1, 8]  -t SyN[0.25]  -r Gauss[3#,0] -o $SIMMETRIC --use-Histogram-Matching  -i $MAXITERATIONS --number-of-affine-iterations  100x100x100


DEFORMEDC1=$STR"_warpedc0.nii"
DEFORMEDC2=$STR"_warpedc1.nii"
DEFORMEDC3=$STR"_warpedc2.nii"
DEFORMEDC4=$STR"_warpedc3.nii"

AFFINEMATRIX=$SIMMETRIC"Affine.txt"
FWDDISPFIELD=$SIMMETRIC"Warp.nii.gz"
BWDDISPFIELD=$SIMMETRIC"InverseWarp.nii.gz"


#---exe---#
$WARP 3 $MOVINGC0 $DEFORMEDC1 -R $FIXED $FWDDISPFIELD $AFFINEMATRIX $BWDDISPFIELD --use-BSpline
$WARP 3 $MOVINGC1 $DEFORMEDC2 -R $FIXED $FWDDISPFIELD $AFFINEMATRIX $BWDDISPFIELD --use-BSpline
$WARP 3 $MOVINGC2 $DEFORMEDC3 -R $FIXED $FWDDISPFIELD $AFFINEMATRIX $BWDDISPFIELD --use-BSpline
$WARP 3 $MOVINGC3 $DEFORMEDC4 -R $FIXED $FWDDISPFIELD $AFFINEMATRIX $BWDDISPFIELD --use-BSpline

LA_OUTPUT=$STR"AlignedFinal.v3draw"

#---exe---#
$Vaa3D -x ireg -f NiftiImageConverter -i $DEFORMEDC1 $DEFORMEDC2 $DEFORMEDC3 $DEFORMEDC4 -o $LA_OUTPUT -p "#b 1 #v 1"

##################
# clean temp files
##################

#---exe---#
##rm $FIXED $MOVING

# We're done with the frame buffer
kill -9 $MYPID


