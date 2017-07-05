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
ANTS="/groups/scicomp/jacsData/yuTest/YoshiMB/scripts/rigidReg.sh"
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

SAMPLERATIO=2

STRT=`echo $TAR | awk -F\. '{print $1}'`
STRS=`echo $SUB | awk -F\. '{print $1}'`

FIXED=$STRT"_c"$TARREF".nii"
MOVING=$STRS"_c"$SUBREF".nii"

MOVINGC1=$STRS"_c0.nii"
MOVINGC2=$STRS"_c1.nii"
MOVINGC3=$STRS"_c2.nii"
MOVINGC4=$STRS"_c3.nii"

SUBREF=$STR"_ref.v3draw"

SUBREFT[1]=$STR"_ref_tile0.v3draw"
SUBREFT[2]=$STR"_ref_tile1.v3draw"
SUBREFT[3]=$STR"_ref_tile2.v3draw"
SUBREFT[4]=$STR"_ref_tile3.v3draw"
SUBREFT[5]=$STR"_ref_tile4.v3draw"
SUBREFT[6]=$STR"_ref_tile5.v3draw"
SUBREFT[7]=$STR"_ref_tile6.v3draw"
SUBREFT[8]=$STR"_ref_tile7.v3draw"
SUBREFT[9]=$STR"_ref_tile8.v3draw"
SUBREFT[10]=$STR"_ref_tile9.v3draw"
SUBREFT[11]=$STR"_ref_tile10.v3draw"
SUBREFT[12]=$STR"_ref_tile11.v3draw"
SUBREFT[13]=$STR"_ref_tile12.v3draw"
SUBREFT[14]=$STR"_ref_tile13.v3draw"
SUBREFT[15]=$STR"_ref_tile14.v3draw"
SUBREFT[16]=$STR"_ref_tile15.v3draw"
SUBREFT[17]=$STR"_ref_tile16.v3draw"
SUBREFT[18]=$STR"_ref_tile17.v3draw"
SUBREFT[19]=$STR"_ref_tile18.v3draw"
SUBREFT[20]=$STR"_ref_tile19.v3draw"
SUBREFT[21]=$STR"_ref_tile20.v3draw"
SUBREFT[22]=$STR"_ref_tile21.v3draw"
SUBREFT[23]=$STR"_ref_tile22.v3draw"
SUBREFT[24]=$STR"_ref_tile23.v3draw"
SUBREFT[25]=$STR"_ref_tile24.v3draw"
SUBREFT[26]=$STR"_ref_tile25.v3draw"
SUBREFT[27]=$STR"_ref_tile26.v3draw"

SUBREFTNIFTY[1]=$STR"_ref_tile0_c0.nii"
SUBREFTNIFTY[2]=$STR"_ref_tile1_c0.nii"
SUBREFTNIFTY[3]=$STR"_ref_tile2_c0.nii"
SUBREFTNIFTY[4]=$STR"_ref_tile3_c0.nii"
SUBREFTNIFTY[5]=$STR"_ref_tile4_c0.nii"
SUBREFTNIFTY[6]=$STR"_ref_tile5_c0.nii"
SUBREFTNIFTY[7]=$STR"_ref_tile6_c0.nii"
SUBREFTNIFTY[8]=$STR"_ref_tile7_c0.nii"
SUBREFTNIFTY[9]=$STR"_ref_tile8_c0.nii"
SUBREFTNIFTY[10]=$STR"_ref_tile9_c0.nii"
SUBREFTNIFTY[11]=$STR"_ref_tile10_c0.nii"
SUBREFTNIFTY[12]=$STR"_ref_tile11_c0.nii"
SUBREFTNIFTY[13]=$S=TR"_ref_tile12_c0.nii"
SUBREFTNIFTY[14]=$STR"_ref_tile13_c0.nii"
SUBREFTNIFTY[15]=$STR"_ref_tile14_c0.nii"
SUBREFTNIFTY[16]=$STR"_ref_tile15_c0.nii"
SUBREFTNIFTY[17]=$STR"_ref_tile16_c0.nii"
SUBREFTNIFTY[18]=$STR"_ref_tile17_c0.nii"
SUBREFTNIFTY[19]=$STR"_ref_tile18_c0.nii"
SUBREFTNIFTY[20]=$STR"_ref_tile19_c0.nii"
SUBREFTNIFTY[21]=$STR"_ref_tile20_c0.nii"
SUBREFTNIFTY[22]=$STR"_ref_tile21_c0.nii"
SUBREFTNIFTY[23]=$STR"_ref_tile22_c0.nii"
SUBREFTNIFTY[24]=$STR"_ref_tile23_c0.nii"
SUBREFTNIFTY[25]=$STR"_ref_tile24_c0.nii"
SUBREFTNIFTY[26]=$STR"_ref_tile25_c0.nii"
SUBREFTNIFTY[27]=$STR"_ref_tile26_c0.nii"

SUBREFTDS[1]=$STR"_ref_tile0_c0_ds.nii"
SUBREFTDS[2]=$STR"_ref_tile1_c0_ds.nii"
SUBREFTDS[3]=$STR"_ref_tile2_c0_ds.nii"
SUBREFTDS[4]=$STR"_ref_tile3_c0_ds.nii"
SUBREFTDS[5]=$STR"_ref_tile4_c0_ds.nii"
SUBREFTDS[6]=$STR"_ref_tile5_c0_ds.nii"
SUBREFTDS[7]=$STR"_ref_tile6_c0_ds.nii"
SUBREFTDS[8]=$STR"_ref_tile7_c0_ds.nii"
SUBREFTDS[9]=$STR"_ref_tile8_c0_ds.nii"
SUBREFTDS[10]=$STR"_ref_tile9_c0_ds.nii"
SUBREFTDS[11]=$STR"_ref_tile10_c0_ds.nii"
SUBREFTDS[12]=$STR"_ref_tile11_c0_ds.nii"
SUBREFTDS[13]=$STR"_ref_tile12_c0_ds.nii"
SUBREFTDS[14]=$STR"_ref_tile13_c0_ds.nii"
SUBREFTDS[15]=$STR"_ref_tile14_c0_ds.nii"
SUBREFTDS[16]=$STR"_ref_tile15_c0_ds.nii"
SUBREFTDS[17]=$STR"_ref_tile16_c0_ds.nii"
SUBREFTDS[18]=$STR"_ref_tile17_c0_ds.nii"
SUBREFTDS[19]=$STR"_ref_tile18_c0_ds.nii"
SUBREFTDS[20]=$STR"_ref_tile19_c0_ds.nii"
SUBREFTDS[21]=$STR"_ref_tile20_c0_ds.nii"
SUBREFTDS[22]=$STR"_ref_tile21_c0_ds.nii"
SUBREFTDS[23]=$STR"_ref_tile22_c0_ds.nii"
SUBREFTDS[24]=$STR"_ref_tile23_c0_ds.nii"
SUBREFTDS[25]=$STR"_ref_tile24_c0_ds.nii"
SUBREFTDS[26]=$STR"_ref_tile25_c0_ds.nii"
SUBREFTDS[27]=$STR"_ref_tile26_c0_ds.nii"

SUBGAC1=$STRS"_rrc0.nii"
SUBGAC2=$STRS"_rrc1.nii"
SUBGAC3=$STRS"_rrc2.nii"
SUBGAC4=$STRS"_rrc3.nii"

SUBGA=$STR"_ga.v3draw"

STRT=`echo $FIXED | awk -F\. '{print $1}'`
FIXEDDS=$STRT"_ds2.nii"
STRS=`echo $MOVING | awk -F\. '{print $1}'`
MOVINGDS=$STRS"_ds.nii"

RGDOUT=$STR"Global"
RGDMAT=$RGDOUT"Affine.txt"


#---exe---#
##$Vaa3D -x ireg -f NiftiImageConverter -i $TAR
##$Vaa3D -x ireg -f NiftiImageConverter -i $SUB

#---exe---#
##$SMPL 3 $FIXED $FIXEDDS $SAMPLERATIO $SAMPLERATIO $SAMPLERATIO

#---exe---#
##$Vaa3D -x ireg -f NiftiImageConverter -i $MOVINGC4 -o $SUBREF -p "#b 1 #v 1"
##$Vaa3D -x ireg -f iTiling -i $SUBREF -o $SUBREF

for ((i=1; i<=12; i++))
do

#---exe---#
$Vaa3D -x ireg -f NiftiImageConverter -i ${SUBREFT[i]}

RGOUTITER=$STR"Global"$i

#---exe---#
$SMPL 3 ${SUBREFTNIFTY[i]} ${SUBREFTDS[i]} $SAMPLERATIO $SAMPLERATIO $SAMPLERATIO

#---exe---#
qsub -b y -cwd -V -pe batch 8 -l mem96=true $ANTS $FIXEDDS, ${SUBREFTDS[i]} $RGOUTITER

done


#---exe---#
##$WARP 3 $MOVINGC1 $SUBGAC1 -R $FIXED $RGDMAT
##$WARP 3 $MOVINGC2 $SUBGAC2 -R $FIXED $RGDMAT
##$WARP 3 $MOVINGC3 $SUBGAC3 -R $FIXED $RGDMAT
##$WARP 3 $MOVINGC4 $SUBGAC4 -R $FIXED $RGDMAT

#---exe---#
##$Vaa3D -x ireg -f NiftiImageConverter -i $SUBGAC1 $SUBGAC2 $SUBGAC3 $SUBGAC4 -o $SUBGA -p "#b 1 #v 1"


##################
# clean temp files
##################

#---exe---#
##rm $FIXED $MOVING

# We're done with the frame buffer
kill -9 $MYPID


