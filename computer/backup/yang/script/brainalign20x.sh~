#!/bin/bash
#
# 20x fly brain alignment pipeline 1.0, April 6, 2012 
#

PORT=1031
while (test -f "/tmp/.X${PORT}-lock") || (netstat -atwn | grep "^.*:${PORT}.*:\*\s*LISTEN\s*$")
do PORT=$(( ${PORT} + 1 ))
done
/usr/bin/Xvfb :${PORT} -screen 0 1x1x24 -sp /usr/lib64/xserver/SecurityPolicy -fp /usr/share/X11/fonts/misc &
MYPID=$!
export DISPLAY="localhost:${PORT}.0"

##################
# TOOLKITS
##################

VNCSEG="/groups/scicomp/jacsData/yuTest/flybrainAlign/toolkits/Vaa3D/jba_seg_vnc"
Vaa3D="/groups/scicomp/jacsData/yuTest/flybrainAlign/toolkits/Vaa3D/vaa3d"

#ANTS
#BRAINALIGNER="/groups/scicomp/jacsData/yuTest/flybrainAlign/brainalign2c.sh"
#JBA
BRAINALIGNER="/home/yuy/work/BrainAlignerTest/script/jbaAligner20x.sh"

##################
# Inputs
##################

NUMPARAMS=$#
if [ $NUMPARAMS -lt 7 ]
then
echo " "
echo " USAGE ::  "
echo " sh brainalign20x.sh target target_ref_no target_marker subject subject_ref_no output target_ori"
echo " "
exit
fi

# landmarks
TARGET_LANDMARKS=$3

# target
INPUT1=$1
INPUT_REFNO1=$2

# subject
INPUT2=$4
INPUT_REFNO2=$5

# output
OUTPUT=$6

# origianl target
ATLAS=$7

STR=`echo $OUTPUT | awk -F\. '{print $1}'`

##################
# convert to v3draw
##################

SUBRAW=$STR"input.v3draw"

#---exe---#
$Vaa3D -cmd image-loader -convert "$INPUT2" "$SUBRAW"

REF_NO1=$((INPUT_REFNO1-1));
REF_NO2=$((INPUT_REFNO2-1));

##################
# isotropic sampling
##################

# assuming 0.62um in x, y; 1.0um in z
SUBIS=$STR"Isotropic.v3draw"

#---exe---#
$Vaa3D -x ireg -f isampler -i $SUBRAW -o $SUBIS -p "#x 0.8387 #y 0.8387 #z 1.6129"

##################
# resizing
##################

SUBPP=$STR"Preprocessed.v3draw"

#---exe---#
$Vaa3D -x ireg -f prepare20xData -o $SUBPP -p "#s $SUBIS #t $INPUT1"

##################
# brain alignment
##################

#---exe---#
$BRAINALIGNER $INPUT1 $REF_NO1 $TARGET_LANDMARKS $SUBPP $REF_NO2 $OUTPUT


##################
# clean temp files
##################

#---exe---#
##rm $SUBPP $SUBIS $SUBV3DRAW $LA_OUTPUT

# We're done with the frame buffer
kill -9 $MYPID


