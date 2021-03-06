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
# The outputs will be aligned results in 40x scale (0.3x0.3x0.38) and
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
### global alignment using ANTS Rigid Registration
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

SUBGA=$STR"_ga.v3draw"

STRT=`echo $FIXED | awk -F\. '{print $1}'`
FIXEDDS=$STRT"_ds.nii"
STRS=`echo $MOVING | awk -F\. '{print $1}'`
MOVINGDS=$STRS"_ds.nii"

RGDOUT=$STR"Global"
RGDMAT=$RGDOUT"Affine.txt"

#---exe---#
$Vaa3D -x ireg -f NiftiImageConverter -i $TAR
$Vaa3D -x ireg -f NiftiImageConverter -i $SUB

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
# local align
##################

#
### 2nd iteration for local alignment
#

LAOUTPUTC0C0=$STR"_la_c0_2nd.v3draw"
LAOUTPUTC1C1=$STR"_la_c1_2nd.v3draw"
LAOUTPUTC2C2=$STR"_la_c2_2nd.v3draw"
LAOUTPUTC3C3=$STR"_la_c3_2nd.v3draw"

CSVT=$LAOUTPUTC3C3"_target.csv"
CSVS=$LAOUTPUTC3C3"_subject.csv"

#---exe---#
$JBA -t $TAR -s $LAOUTPUTC3 -w 10 -o $LAOUTPUTC3C3 -L $TARLANDMARKS -B 2048 -H 2

#---exe---#
$JBA -t $TAR -s $LAOUTPUTC0 -w 10 -o $LAOUTPUTC0C0 -L $CSVT -l $CSVS -B 2048 -H 2
$JBA -t $TAR -s $LAOUTPUTC1 -w 10 -o $LAOUTPUTC1C1 -L $CSVT -l $CSVS -B 2048 -H 2
$JBA -t $TAR -s $LAOUTPUTC2 -w 10 -o $LAOUTPUTC2C2 -L $CSVT -l $CSVS -B 2048 -H 2

LAOUTPUT=$STR"Aligned40xScale2ndItered.v3draw"

#---exe---#
$Vaa3D -x ireg -f mergeColorChannels -i $LAOUTPUTC0C0 $LAOUTPUTC1C1 $LAOUTPUTC2C2 $LAOUTPUTC3C3 -o $LAOUTPUT

LARS=$STR"cnvt20xscale2ndItered.v3draw"
LAOUTPUTRS=$STR"Aligned20xScale2ndItered.v3draw"

#---exe---#
$Vaa3D -x ireg -f isampler -i $LAOUTPUT -o $LARS -p "#x 0.48387 #y 0.48387 #z 0.6129"

#---exe---#
$Vaa3D -x ireg -f prepare20xData -o $LAOUTPUTRS -p "#s $LARS #t $ATLAS"


##################
# local align
##################

#
### 3rd iteration for local alignment
#

LAOUTPUTC0=$LAOUTPUTC0C0
LAOUTPUTC1=$LAOUTPUTC1C1
LAOUTPUTC2=$LAOUTPUTC2C2
LAOUTPUTC3=$LAOUTPUTC3C3

LAOUTPUTC0C0=$STR"_la_c0_3rd.v3draw"
LAOUTPUTC1C1=$STR"_la_c1_3rd.v3draw"
LAOUTPUTC2C2=$STR"_la_c2_3rd.v3draw"
LAOUTPUTC3C3=$STR"_la_c3_3rd.v3draw"

CSVT=$LAOUTPUTC3C3"_target.csv"
CSVS=$LAOUTPUTC3C3"_subject.csv"

#---exe---#
$JBA -t $TAR -s $LAOUTPUTC3 -w 10 -o $LAOUTPUTC3C3 -L $TARLANDMARKS -B 2048 -H 2

#---exe---#
$JBA -t $TAR -s $LAOUTPUTC0 -w 10 -o $LAOUTPUTC0C0 -L $CSVT -l $CSVS -B 2048 -H 2
$JBA -t $TAR -s $LAOUTPUTC1 -w 10 -o $LAOUTPUTC1C1 -L $CSVT -l $CSVS -B 2048 -H 2
$JBA -t $TAR -s $LAOUTPUTC2 -w 10 -o $LAOUTPUTC2C2 -L $CSVT -l $CSVS -B 2048 -H 2

LAOUTPUT=$STR"Aligned40xScale3rdItered.v3draw"

#---exe---#
$Vaa3D -x ireg -f mergeColorChannels -i $LAOUTPUTC0C0 $LAOUTPUTC1C1 $LAOUTPUTC2C2 $LAOUTPUTC3C3 -o $LAOUTPUT

LARS=$STR"cnvt20xscale3rdItered.v3draw"
LAOUTPUTRS=$STR"Aligned20xScale3rdItered.v3draw"

#---exe---#
$Vaa3D -x ireg -f isampler -i $LAOUTPUT -o $LARS -p "#x 0.48387 #y 0.48387 #z 0.6129"

#---exe---#
$Vaa3D -x ireg -f prepare20xData -o $LAOUTPUTRS -p "#s $LARS #t $ATLAS"


##################
# local align
##################

#
### 4th iteration for local alignment
#

LAOUTPUTC0=$LAOUTPUTC0C0
LAOUTPUTC1=$LAOUTPUTC1C1
LAOUTPUTC2=$LAOUTPUTC2C2
LAOUTPUTC3=$LAOUTPUTC3C3

LAOUTPUTC0C0=$STR"_la_c0_4th.v3draw"
LAOUTPUTC1C1=$STR"_la_c1_4th.v3draw"
LAOUTPUTC2C2=$STR"_la_c2_4th.v3draw"
LAOUTPUTC3C3=$STR"_la_c3_4th.v3draw"

CSVT=$LAOUTPUTC3C3"_target.csv"
CSVS=$LAOUTPUTC3C3"_subject.csv"

#---exe---#
$JBA -t $TAR -s $LAOUTPUTC3 -w 10 -o $LAOUTPUTC3C3 -L $TARLANDMARKS -B 2048 -H 2

#---exe---#
$JBA -t $TAR -s $LAOUTPUTC0 -w 10 -o $LAOUTPUTC0C0 -L $CSVT -l $CSVS -B 2048 -H 2
$JBA -t $TAR -s $LAOUTPUTC1 -w 10 -o $LAOUTPUTC1C1 -L $CSVT -l $CSVS -B 2048 -H 2
$JBA -t $TAR -s $LAOUTPUTC2 -w 10 -o $LAOUTPUTC2C2 -L $CSVT -l $CSVS -B 2048 -H 2

LAOUTPUT=$STR"Aligned40xScale4thItered.v3draw"

#---exe---#
$Vaa3D -x ireg -f mergeColorChannels -i $LAOUTPUTC0C0 $LAOUTPUTC1C1 $LAOUTPUTC2C2 $LAOUTPUTC3C3 -o $LAOUTPUT

LARS=$STR"cnvt20xscale4thItered.v3draw"
LAOUTPUTRS=$STR"Aligned20xScale4thItered.v3draw"

#---exe---#
$Vaa3D -x ireg -f isampler -i $LAOUTPUT -o $LARS -p "#x 0.48387 #y 0.48387 #z 0.6129"

#---exe---#
$Vaa3D -x ireg -f prepare20xData -o $LAOUTPUTRS -p "#s $LARS #t $ATLAS"

##################
# local align
##################

#
### 5th iteration for local alignment
#

LAOUTPUTC0=$LAOUTPUTC0C0
LAOUTPUTC1=$LAOUTPUTC1C1
LAOUTPUTC2=$LAOUTPUTC2C2
LAOUTPUTC3=$LAOUTPUTC3C3

LAOUTPUTC0C0=$STR"_la_c0_5th.v3draw"
LAOUTPUTC1C1=$STR"_la_c1_5th.v3draw"
LAOUTPUTC2C2=$STR"_la_c2_5th.v3draw"
LAOUTPUTC3C3=$STR"_la_c3_5th.v3draw"

CSVT=$LAOUTPUTC3C3"_target.csv"
CSVS=$LAOUTPUTC3C3"_subject.csv"

#---exe---#
$JBA -t $TAR -s $LAOUTPUTC3 -w 10 -o $LAOUTPUTC3C3 -L $TARLANDMARKS -B 2048 -H 2

#---exe---#
$JBA -t $TAR -s $LAOUTPUTC0 -w 10 -o $LAOUTPUTC0C0 -L $CSVT -l $CSVS -B 2048 -H 2
$JBA -t $TAR -s $LAOUTPUTC1 -w 10 -o $LAOUTPUTC1C1 -L $CSVT -l $CSVS -B 2048 -H 2
$JBA -t $TAR -s $LAOUTPUTC2 -w 10 -o $LAOUTPUTC2C2 -L $CSVT -l $CSVS -B 2048 -H 2

LAOUTPUT=$STR"Aligned40xScale5thItered.v3draw"

#---exe---#
$Vaa3D -x ireg -f mergeColorChannels -i $LAOUTPUTC0C0 $LAOUTPUTC1C1 $LAOUTPUTC2C2 $LAOUTPUTC3C3 -o $LAOUTPUT

LARS=$STR"cnvt20xscale5thItered.v3draw"
LAOUTPUTRS=$STR"Aligned20xScale5thItered.v3draw"

#---exe---#
$Vaa3D -x ireg -f isampler -i $LAOUTPUT -o $LARS -p "#x 0.48387 #y 0.48387 #z 0.6129"

#---exe---#
$Vaa3D -x ireg -f prepare20xData -o $LAOUTPUTRS -p "#s $LARS #t $ATLAS"

##################
# local align
##################

#
### 6th iteration for local alignment
#

LAOUTPUTC0=$LAOUTPUTC0C0
LAOUTPUTC1=$LAOUTPUTC1C1
LAOUTPUTC2=$LAOUTPUTC2C2
LAOUTPUTC3=$LAOUTPUTC3C3

LAOUTPUTC0C0=$STR"_la_c0_6th.v3draw"
LAOUTPUTC1C1=$STR"_la_c1_6th.v3draw"
LAOUTPUTC2C2=$STR"_la_c2_6th.v3draw"
LAOUTPUTC3C3=$STR"_la_c3_6th.v3draw"

CSVT=$LAOUTPUTC3C3"_target.csv"
CSVS=$LAOUTPUTC3C3"_subject.csv"

#---exe---#
$JBA -t $TAR -s $LAOUTPUTC3 -w 10 -o $LAOUTPUTC3C3 -L $TARLANDMARKS -B 2048 -H 2

#---exe---#
$JBA -t $TAR -s $LAOUTPUTC0 -w 10 -o $LAOUTPUTC0C0 -L $CSVT -l $CSVS -B 2048 -H 2
$JBA -t $TAR -s $LAOUTPUTC1 -w 10 -o $LAOUTPUTC1C1 -L $CSVT -l $CSVS -B 2048 -H 2
$JBA -t $TAR -s $LAOUTPUTC2 -w 10 -o $LAOUTPUTC2C2 -L $CSVT -l $CSVS -B 2048 -H 2

LAOUTPUT=$STR"Aligned40xScale6thItered.v3draw"

#---exe---#
$Vaa3D -x ireg -f mergeColorChannels -i $LAOUTPUTC0C0 $LAOUTPUTC1C1 $LAOUTPUTC2C2 $LAOUTPUTC3C3 -o $LAOUTPUT

LARS=$STR"cnvt20xscale6thItered.v3draw"
LAOUTPUTRS=$STR"Aligned20xScale6thItered.v3draw"

#---exe---#
$Vaa3D -x ireg -f isampler -i $LAOUTPUT -o $LARS -p "#x 0.48387 #y 0.48387 #z 0.6129"

#---exe---#
$Vaa3D -x ireg -f prepare20xData -o $LAOUTPUTRS -p "#s $LARS #t $ATLAS"

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
$JBA -t $TAR -s $LAOUTPUTC3 -w 10 -o $LAOUTPUTC3C3 -L $TARLANDMARKS -B 2048 -H 2

#---exe---#
$JBA -t $TAR -s $LAOUTPUTC0 -w 10 -o $LAOUTPUTC0C0 -L $CSVT -l $CSVS -B 2048 -H 2
$JBA -t $TAR -s $LAOUTPUTC1 -w 10 -o $LAOUTPUTC1C1 -L $CSVT -l $CSVS -B 2048 -H 2
$JBA -t $TAR -s $LAOUTPUTC2 -w 10 -o $LAOUTPUTC2C2 -L $CSVT -l $CSVS -B 2048 -H 2

LAOUTPUT=$STR"Aligned40xScale7thItered.v3draw"

#---exe---#
$Vaa3D -x ireg -f mergeColorChannels -i $LAOUTPUTC0C0 $LAOUTPUTC1C1 $LAOUTPUTC2C2 $LAOUTPUTC3C3 -o $LAOUTPUT

LARS=$STR"cnvt20xscale7thItered.v3draw"
LAOUTPUTRS=$STR"Aligned20xScale7thItered.v3draw"

#---exe---#
$Vaa3D -x ireg -f isampler -i $LAOUTPUT -o $LARS -p "#x 0.48387 #y 0.48387 #z 0.6129"

#---exe---#
$Vaa3D -x ireg -f prepare20xData -o $LAOUTPUTRS -p "#s $LARS #t $ATLAS"


##################
# clean temp files
##################

#---exe---#
##rm $FIXED $MOVING

# We're done with the frame buffer
kill -9 $MYPID


