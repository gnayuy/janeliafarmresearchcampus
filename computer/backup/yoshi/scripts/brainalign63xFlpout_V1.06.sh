#!/bin/bash
#
# fly brain alignment pipeline 1.04, Aug 9, 2012 
# fly brain alignment pipeline 1.06, Oct 9, 2012 
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
# Target brain's resolution (0.38x0.38x0.38 um and 0.19x0.19x0.38 um)
#
################################################################################

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
# TARGETS
##################

TARIS=/groups/scicomp/jacsData/yuTest/YoshiMB/templates/wfb_asx_template_rec.raw
TARISLANDMARKS=/groups/scicomp/jacsData/yuTest/YoshiMB/templates/wfb_asx_template_rec_cb.marker

TARH=/groups/scicomp/jacsData/yuTest/YoshiMB/templates/wfb_asxh_template_rec.raw
TARHLANDMARKS=/groups/scicomp/jacsData/yuTest/YoshiMB/templates/wfb_asxh_template_rec_cb.marker

ATLAS=/groups/scicomp/jacsData/yuTest/YoshiMB/templates/wfb_atx_template_ori.tif
TARREF=1

RES_X=0.38
RES_Y=0.38
RES_Z=0.38

##################
# Inputs
##################

NUMPARAMS=$#
if [ $NUMPARAMS -lt 6 ]
then
echo " "
echo " USAGE ::  "
echo " sh brainalign63x.sh subject subject_ref_no output res_x res_y res_z"
echo " "
exit
fi

# subject
SUB=$1
SUBREF=$2

# output
OUTPUT=$3

# subject's resolution
RESX=$4
RESY=$5
RESZ=$6

STR=`echo $OUTPUT | awk -F\. '{print $1}'`

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

TAR=""
TARLANDMARKS=""
LEN=1


if [ $(bc <<< "$ASRXC < 0.01") -eq 1 ] && [ $(bc <<< "$ASRYC < 0.01") -eq 1 ] && [ $(bc <<< "$ASRZC < 0.01") -eq 1 ]; then

TAR=$TARIS
TARLANDMARKS=$TARISLANDMARKS
LEN=1672

else

TAR=$TARH
TARLANDMARKS=$TARHLANDMARKS
LEN=3344

fi


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

#CSVT=$OUTPUT"_target.csv"
#CSVS=$OUTPUT"_subject.csv"

CSVT=$LAOUTPUTC3"_target.csv"
CSVS=$LAOUTPUTC3"_subject.csv"

#---exe---#
$JBA -t $TAR -s $GAOUTPUTC3 -w 10 -o $LAOUTPUTC3 -L $TARLANDMARKS -B $LEN -H 2

#---exe---#
$JBA -t $TAR -s $GAOUTPUTC0 -w 10 -o $LAOUTPUTC0 -L $CSVT -l $CSVS -B $LEN -H 2
$JBA -t $TAR -s $GAOUTPUTC1 -w 10 -o $LAOUTPUTC1 -L $CSVT -l $CSVS -B $LEN -H 2
$JBA -t $TAR -s $GAOUTPUTC2 -w 10 -o $LAOUTPUTC2 -L $CSVT -l $CSVS -B $LEN -H 2

LAOUTPUT=$STR"Aligned63xScale.v3draw"

#---exe---#
$Vaa3D -x ireg -f mergeColorChannels -i $LAOUTPUTC0 $LAOUTPUTC1 $LAOUTPUTC2 $LAOUTPUTC3 -o $LAOUTPUT

##################
# 20x scale result
##################

LARS=$STR"cnvt20xscale.v3draw"
LAOUTPUTRS=$STR"Aligned20xScale.v3draw"

if [ $(bc <<< "$ASRXC < 0.01") -eq 1 ] && [ $(bc <<< "$ASRYC < 0.01") -eq 1 ] && [ $(bc <<< "$ASRZC < 0.01") -eq 1 ]; then

#---exe---#
$Vaa3D -x ireg -f isampler -i $LAOUTPUT -o $LARS -p "#x 0.6129 #y 0.6129 #z 0.6129"

else

#---exe---#
$Vaa3D -x ireg -f isampler -i $LAOUTPUT -o $LARS -p "#x 0.3065 #y 0.3065 #z 0.6129"

fi

#---exe---#
$Vaa3D -x ireg -f prepare20xData -o $LAOUTPUTRS -p "#s $LARS #t $ATLAS"



##################
# clean temp files
##################

#---exe---#
##rm $FIXED $MOVING

# We're done with the frame buffer
kill -9 $MYPID


