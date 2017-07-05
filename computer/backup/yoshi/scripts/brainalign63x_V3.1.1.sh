#!/bin/bash
#
# fly brain alignment pipeline 3.1.1. Oct 17, 2012. Yang Yu. 
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
# Target brain's resolution (0.19x0.19x0.38 um)
#
# API 1.0 2012/10/15
# 1) configuration_file
# 2) templates_dir
# 3) toolkits_dir
# 4) work_dir 
# 5) input_file
# 6) reference_channel
# 7) voxel_size_x
# 8) voxel_size_y
# 9) voxel_size_z
#
################################################################################

##################
# Basic Funcs
##################

readItemFromConf()
{
local FILE="$1"
local ITEM="$2"
VAL=`grep "<$ITEM>.*<.$ITEM>" $FILE | sed -e "s/^.*<$ITEM/<$ITEM/" | cut -f2 -d">"| cut -f1 -d"<"`
echo ${VAL}
}

message()
{
echo ""
echo " ~ DEBUG: ${1} ~ "
echo ""
}

is_file_exits()
{
local f="$1"
[[ -f "$f" ]] && return 0 || return 1
}

##################
# Inputs
##################

NUMPARAMS=$#
if [ $NUMPARAMS -lt 4 ]
then
echo " "
echo " USAGE ::  "
echo " sh brainalign63xLexAGAL4_V1.08.sh configuration_file work_dir input_file reference_channel voxel_size_x voxel_size_y voxel_size_z"
echo " "
exit
fi

# inputs
CONFIGFILE=$1
WORKINGDIR=$2
SUB=$3
SUBREF=$4

# tools
Vaa3D=`readItemFromConf $CONFIGFILE "Vaa3D"`
JBA=`readItemFromConf $CONFIGFILE "JBA"`
ANTS=`readItemFromConf $CONFIGFILE "ANTS"`
WARP=`readItemFromConf $CONFIGFILE "WARP"`
SMPL=`readItemFromConf $CONFIGFILE "SMPL"`

# templates
TAR=`readItemFromConf $CONFIGFILE "tgtFBSXAS"`
TARREF=`readItemFromConf $CONFIGFILE "REFNO"`
ATLAS=`readItemFromConf $CONFIGFILE "atlasFBTX"`
RES_X=`readItemFromConf $CONFIGFILE "VSZX_63X_AS"`
RES_Y=`readItemFromConf $CONFIGFILE "VSZY_63X_AS"`
RES_Z=`readItemFromConf $CONFIGFILE "VSZZ_63X_AS"`

# debug inputs
message "Inputs..."
echo "CONFIGFILE: $CONFIGFILE"
echo "WORKINGDIR: $WORKINGDIR"
echo "SUB: $SUB"
echo "SUBREF: $SUBREF"
message "Vars..."
echo "Vaa3D: $Vaa3D"
echo "JBA: $JBA"
echo "ANTS: $ANTS"
echo "WARP: $WARP"
echo "SMPL: $SMPL"
echo "TAR: $TAR"
echo "TARREF: $TARREF"
echo "ATLAS: $ATLAS"
echo "RES_X: $RES_X"
echo "RES_Y: $RES_Y"
echo "RES_Z: $RES_Z"
echo ""


##################
# flip along z
##################

SUBFLIP=${WORKINGDIR}/"zFliped.v3draw"

#---exe---#
#-#$Vaa3D -x ireg -f zflip -i $SUB -o $SUBFLIP
SUB=$SUBFLIP


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

SAMPLERATIO=2

# temporary target
TEMPTARGET=${WORKINGDIR}/temptarget.raw
if ( is_file_exits "$TEMPTARGET" )
then
echo "Temp TARGET exists"
else
#---exe---#
cp ${TAR} ${TEMPTARGET}
fi

TAR=$TEMPTARGET

if ( is_file_exits "$TAR" )
then
echo " Alignment target stays in the work dir "
else
exit 1
fi

TEMPSUBJECT=${WORKINGDIR}/tempsubject.raw
if ( is_file_exits "$TEMPSUBJECT" )
then
echo "Temp SUBJECT exists"
else
#---exe---#
cp ${SUB} ${TEMPSUBJECT}
fi

SUB=$TEMPSUBJECT

if ( is_file_exits "$SUB" )
then
echo " Alignment subject stays in the work dir "
else
exit 1
fi

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

SUBDeformed=$WORKINGDIR"/Aligned63Scaled.v3draw"

STRT=`echo $FIXED | awk -F\. '{print $1}'`
FIXEDDS=$STRT"_ds.nii"
STRS=`echo $MOVING | awk -F\. '{print $1}'`
MOVINGDS=$STRS"_ds.nii"

#---exe---#
message " Converting raw/tif image to Nifti image"
#-#$Vaa3D -x ireg -f NiftiImageConverter -i $SUB

if ( is_file_exits "$FIXED" )
then
echo "$FIXED exists"
else
#---exe---#
#-#$Vaa3D -x ireg -f NiftiImageConverter -i $TAR
fi

#---exe---#
message " Downsampling "
#-#$SMPL 3 $MOVING $MOVINGDS $SAMPLERATIO $SAMPLERATIO $SAMPLERATIO 

if ( is_file_exits "$FIXEDDS" )
then
echo "$FIXEDDS exists"
else
#---exe---#
#-#$SMPL 3 $FIXED $FIXEDDS $SAMPLERATIO $SAMPLERATIO $SAMPLERATIO
fi

SIMMETRIC=$WORKINGDIR"/cc"
AFFINEMATRIX=$WORKINGDIR"/ccAffine.txt"
FWDDISPFIELD=$WORKINGDIR"/ccWarp.nii.gz"
BWDDISPFIELD=$WORKINGDIR"/ccInverseWarp.nii.gz"

MAXITERSCC=30x90x20

#---exe---#
message " Global alignment "
#-#$ANTS 3 -m  MI[ $FIXEDDS, $MOVINGDS, 1, 32] -o $SIMMETRIC -i 0 --use-Histogram-Matching  --number-of-affine-iterations $MAXITERATIONS --rigid-affine false

#
### local alignment using ANTS SyN
#

#---exe---#
message " Local alignment "
#-#$ANTS 3 -m  CC[ $FIXEDDS, $MOVINGDS, 0.75, 4] -m MI[ $FIXEDDS, $MOVINGDS, 0.25, 32] -t SyN[0.25]  -r Gauss[3,0] -o $SIMMETRIC -i $MAXITERSCC --initial-affine $AFFINEMATRIX


#---exe---#
message " Warping to obtain the alignment result "
#-#$WARP 3 $MOVINGC1 $SUBGAC1 -R $FIXED $FWDDISPFIELD $AFFINEMATRIX --use-BSpline
#-#$WARP 3 $MOVINGC2 $SUBGAC2 -R $FIXED $FWDDISPFIELD $AFFINEMATRIX --use-BSpline
#-#$WARP 3 $MOVINGC3 $SUBGAC3 -R $FIXED $FWDDISPFIELD $AFFINEMATRIX --use-BSpline
#-#$WARP 3 $MOVINGC4 $SUBGAC4 -R $FIXED $FWDDISPFIELD $AFFINEMATRIX --use-BSpline

#---exe---#
message "$Vaa3D -x ireg -f NiftiImageConverter -i $SUBGAC1 $SUBGAC2 $SUBGAC3 $SUBGAC4 -o $SUBDeformed -p \"#b 1 #v 1\" "
$Vaa3D -x ireg -f NiftiImageConverter -i $SUBGAC1 $SUBGAC2 $SUBGAC3 $SUBGAC4 -o $SUBDeformed -p "#b 1 #v 1"


##################
# clean temp files
##################

#---exe---#
##rm $FIXED $MOVING

# We're done with the frame buffer
kill -9 $MYPID


