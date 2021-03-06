#!/bin/bash
#
# rigid registration pipeline 1.0
# Yang Yu
# 08/21/2012 
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
# Global alignment using ANTS toolkit
#
#######################################################################

#ANTS
ANTS="/groups/scicomp/jacsData/yuTest/YoshiMB/toolkits/ANTS/ANTS"
WARP="/groups/scicomp/jacsData/yuTest/YoshiMB/toolkits/ANTS/WarpImageMultiTransform"
SMPL="/groups/scicomp/jacsData/yuTest/YoshiMB/toolkits/ANTS/ResampleImageBySpacing"


##################
# Inputs
##################

NUMPARAMS=$#
if [ $NUMPARAMS -lt 3 ]
then
echo " "
echo " USAGE ::  "
echo " sh rigidReg.sh target subject output"
echo " "
exit
fi

# target
TAR=$1

# subject
SUB=$2

# output
OUTPUT=$3


STR=`echo $OUTPUT | awk -F\. '{print $1}'`

##################
# Reg
##################

MAXITERATIONS=10000x10000x10000x10000x10000
GRADDSCNTOPTS=0.5x0.95x1.e-4x1.e-4

#---exe---#
$ANTS 3 -m  MI[ $TAR, $SUB, 1, 32] -o $OUTPUT -i 0 --use-Histogram-Matching  --number-of-affine-iterations $MAXITERATIONS --rigid-affine true --affine-gradient-descent-option $GRADDSCNTOPTS


# We're done with the frame buffer
kill -9 $MYPID


