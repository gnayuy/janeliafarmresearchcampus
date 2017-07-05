#!/bin/bash
#
# image alignment pipeline 1.0, March 28, 2012 
# modified to Yushi's data, July 26, 2012
#

PORT=1031
while (test -f "/tmp/.X${PORT}-lock") || (netstat -atwn | grep "^.*:${PORT}.*:\*\s*LISTEN\s*$")
do PORT=$(( ${PORT} + 1 ))
done
/usr/bin/Xvfb :${PORT} -screen 0 1x1x24 -sp /usr/lib64/xserver/SecurityPolicy -fp /usr/share/X11/fonts/misc &
MYPID=$!
export DISPLAY="localhost:${PORT}.0"

####
# TOOLKITS
####

Vaa3D="/groups/scicomp/jacsData/yuTest/flybrainAlign/toolkits/Vaa3D/vaa3d"
BRAINALIGNER="/groups/scicomp/jacsData/yuTest/flybrainAlign/toolkits/Vaa3D/brainaligner"

# output files folder
OUTPUTFOLDER="/groups/scicomp/jacsData/yuTest/flybrainAlign/results"

# compartment boundaries
COMPBND=/groups/scicomp/jacsData/yuTest/flybrainAlign/template/wfb_atx_template_rec2_boundaries.tif

# mask
MASK=/groups/scicomp/jacsData/yuTest/flybrainAlign/template/locbro_mask.tif

##################
# inputs
##################

NUMPARAMS=$#
if [ $NUMPARAMS -lt 6 ]
then
echo " "
echo " USAGE ::  "
echo " sh jbaBrainAligner.sh target target_ref_no target_marker subject subject_ref_no output"
echo " "
exit
fi

# target
TARGET=$1
TARGET_REFNO=$2
TARGET_MARKER=$3

# subject
SUBJECT=$4
SUBJECT_REFNO=$5

# output
OUTPUT=$6

#
STR=`echo $OUTPUT | awk -F\. '{print $1}'`

##################
# global alignment
##################

GAOUTPUT=$STR"Global.v3draw"

#---exe---#
$BRAINALIGNER -t $TARGET -C $TARGET_REFNO -s $SUBJECT -c $SUBJECT_REFNO -w 0 -o $GAOUTPUT -B 1672 -H 2

##################
# local alignment
##################

GAOUTPUT_C0=$STR"Global_c0.v3draw"
GAOUTPUT_C1=$STR"Global_c1.v3draw"
GAOUTPUT_C2=$STR"Global_c2.v3draw"
GAOUTPUT_C3=$STR"Global_c3.v3draw"

#---exe---#
$Vaa3D -x ireg -f splitColorChannels -i $GAOUTPUT

LAOUTPUT_C0=$STR"Local_c0.v3draw"
LAOUTPUT_C1=$STR"Local_c1.v3draw"
LAOUTPUT_C2=$STR"Local_c2.v3draw"
LAOUTPUT_C3=$STR"Local_c3.v3draw"

#CSVT=$OUTPUT"_target.csv"
#CSVS=$OUTPUT"_subject.csv"

CSVT=$LAOUTPUT_C1"_target.csv"
CSVS=$LAOUTPUT_C1"_subject.csv"

#---exe---#
$BRAINALIGNER -t $TARGET -s $GAOUTPUT_C3 -w 10 -o $LAOUTPUT_C3 -L $TARGET_MARKER -B 1672 -H 2

#---exe---#
$BRAINALIGNER -t $TARGET -s $GAOUTPUT_C0 -w 10 -o $LAOUTPUT_C0 -L $CSVT -l $CSVS -B 1672 -H 2
$BRAINALIGNER -t $TARGET -s $GAOUTPUT_C1 -w 10 -o $LAOUTPUT_C1 -L $CSVT -l $CSVS -B 1672 -H 2
$BRAINALIGNER -t $TARGET -s $GAOUTPUT_C2 -w 10 -o $LAOUTPUT_C2 -L $CSVT -l $CSVS -B 1672 -H 2

LA_OUTPUT=$OUTPUT"Warped.v3draw"

#---exe---#
$Vaa3D -x ireg -f mergeColorChannels -i $LAOUTPUT_C0 $LAOUTPUT_C1 $LAOUTPUT_C2 $LAOUTPUT_C3 -o $LA_OUTPUT

##################
# evaluate Qi
##################

QIOUTPUT=$STR"_QiScores.csv"

#---exe---#
##$Vaa3D -x ireg -f QiScoreStas -o $QIOUTPUT -p "#l $CSVT #t $TARGET_MARKER #m $MASK" 

##################
# clean temp files
##################
#---exe---# 
##rm $GAOUTPUT $GAOUTPUT_C0 $GAOUTPUT_C1 $LAOUTPUT_C0 $LAOUTPUT_C1 $CSVT $CSVS

# We're done with the frame buffer
kill -9 $MYPID




