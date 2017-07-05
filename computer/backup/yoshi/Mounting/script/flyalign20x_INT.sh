#!/bin/bash
#
# fly alignment pipeline, version 1.0, 2013/2/15
#

PORT=1031
while (test -f "/tmp/.X${PORT}-lock") || (netstat -atwn | grep "^.*:${PORT}.*:\*\s*LISTEN\s*$")
do PORT=$(( ${PORT} + 1 ))
done
/usr/bin/Xvfb :${PORT} -screen 0 1x1x24 -fp /usr/share/X11/fonts/misc &
MYPID=$!
export DISPLAY="localhost:${PORT}.0"

################################################################################
#
# The pipeline is developed for aligning 20x fly (brain + VNC).
# Target brain's resolution (0.62x0.62x0.62 um)
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

is_file_exist()
{
local f="$1"
[[ -f "$f" ]] && return 0 || return 1
}

##################
# Inputs
##################

NUMPARAMS=$#
if [ $NUMPARAMS -lt 11 ]
then
echo " "
echo " USAGE ::  "
echo " sh brainalignPairPolarity_INT.sh configuration_file templates_dir toolkits_dir work_dir input_brain input_vnc reference_channel voxel_size_x voxel_size_y voxel_size_z mounting_protocol"
echo " "
exit
fi

# inputs
CONFIGFILE=$1
TMPLDIR=$2
TOOLDIR=$3
WORKDIR=$4
SUBBRAIN=$5
SUBVNC=$6
SUBREF=$7
RESX=$8
RESY=$9
RESZ=${10}
MP=${11}

# tools
Vaa3D=`readItemFromConf $CONFIGFILE "Vaa3D"`
JBA=`readItemFromConf $CONFIGFILE "JBA"`
ANTS=`readItemFromConf $CONFIGFILE "ANTS"`
WARP=`readItemFromConf $CONFIGFILE "WARP"`

Vaa3D=${TOOLDIR}"/"${Vaa3D}
ANTS=${TOOLDIR}"/"${ANTS}
WARP=${TOOLDIR}"/"${WARP}

# templates
ATLAS=`readItemFromConf $CONFIGFILE "atlasFBTX"`
TAR=`readItemFromConf $CONFIGFILE "tgtFBRCTX"`
TARREF=`readItemFromConf $CONFIGFILE "REFNO"`
RESTX_X=`readItemFromConf $CONFIGFILE "VSZX_20X_IS"`
RESTX_Y=`readItemFromConf $CONFIGFILE "VSZY_20X_IS"`
RESTX_Z=`readItemFromConf $CONFIGFILE "VSZZ_20X_IS"`

TAR=${TMPLDIR}"/"${TAR}
ATLAS=${TMPLDIR}"/"${ATLAS}
INITAFFINE=${TMPLDIR}"/"${INITAFFINE}

# debug inputs
message "Inputs..."
echo "CONFIGFILE: $CONFIGFILE"
echo "WORKDIR: $WORKDIR"
echo "SUBBRAIN: $SUBBRAIN"
echo "SUBVNC: $SUBVNC"
echo "SUBREF: $SUBREF"
echo "MountingProtocol: $MP"
message "Vars..."
echo "Vaa3D: $Vaa3D"
echo "ANTS: $ANTS"
echo "WARP: $WARP"
echo "TAR: $TAR"
echo "TARREF: $TARREF"
echo "ATLAS: $ATLAS"
echo ""

OUTPUT=${WORKDIR}"/tmp"
FINALOUTPUT=${WORKDIR}"/FinalOutputs"

if [ ! -d $OUTPUT ]; then 
mkdir $OUTPUT
fi

if [ ! -d $FINALOUTPUT ]; then 
mkdir $FINALOUTPUT
fi

##################
# Preprocessing
##################

### temporary target
TEMPTARGET=${OUTPUT}"/temptargettx.v3draw"
if ( is_file_exist "$TEMPTARGET" )
then
echo "Temp TARGET exists"
else
#---exe---#
message " Creating a symbolic link to 20x target "
ln -s ${TAR} ${TEMPTARGET}
fi

TAR=$TEMPTARGET

### convert to 8bit v3draw file
SUBBRAW=${OUTPUT}/"subbrain.v3draw"
SUBVRAW=${OUTPUT}/"subvnc.v3draw"

if ( is_file_exist "$SUBBRAW" )
then
echo " SUBBRAW exists"
else
#---exe---#
message " Converting to v3draw file "
$Vaa3D -cmd image-loader -convert8 $SUBBRAIN $SUBBRAW
fi

if ( is_file_exist "$SUBVRAW" )
then
echo " SUBVRAW exists"
else
#---exe---#
message " Converting to v3draw file "
$Vaa3D -cmd image-loader -convert8 $SUBVNC $SUBVRAW
fi

### shrinkage ratio
# VECTASHIELD/DPXEthanol = 0.82
# VECTASHIELD/DPXPBS = 0.86
DPXSHRINKRATIO=1.0

if [[ $MP =~ "DPXEthanol" ]]
then
DPXSHRINKRATIO=0.82
elif [[ $MP =~ "DPXPBS" ]]
then
DPXSHRINKRATIO=0.86
else 
# other mounting protocol
echo ""
fi
 
RESTX_X=`echo $DPXSHRINKRATIO*$RESTX_X | bc -l`
RESTX_Y=`echo $DPXSHRINKRATIO*$RESTX_Y | bc -l`
RESTX_Z=`echo $DPXSHRINKRATIO*$RESTX_Z | bc -l`

DPXRI=1.55

### isotropic interpolation
SRX=`echo $RESX/$RESTX_X | bc -l`
SRY=`echo $RESY/$RESTX_Y | bc -l`
SRZ=`echo $RESZ/$RESTX_Z | bc -l`
SRZ=`echo $SRZ*$DPXRI | bc -l`

### isotropic
SUBTXIS=${OUTPUT}"/subtxIS.v3draw"

if ( is_file_exist "$SUBTXIS" )
then
echo " SUBTXIS exists"
else
#---exe---#
message " Isotropic sampling 20x subject "
$Vaa3D -x ireg -f isampler -i $SUBBRAW -o $SUBTXIS -p "#x $SRX #y $SRY #z $SRZ"
fi


##################
# Alignment
##################

#
### global alignment
#

message " Global alignment "

MAXITERATIONS=10000x10000x10000
GRADDSCNTOPTS=0.5x0.95x1.e-4x1.e-4
DSRATIO=0.5

TARREF=$((TARREF-1));
SUBREF=$((SUBREF-1));

### global align $SUBTXIS to $TARTX

STRT=`echo $TAR | awk -F\. '{print $1}'`
STRS=`echo $SUBTXIS | awk -F\. '{print $1}'`

FIXED=$STRT"_c"$TARREF".nii"
MOVING=$STRS"_c"$SUBREF".nii"

MOVINGFC=$STRS"_c0.nii"
MOVINGSC=$STRS"_c1.nii"

SUBFC=$STRS"_c0_deformed.nii"
SUBSC=$STRS"_c1_deformed.nii"

SUBBRAINDeformed=${OUTPUT}"/AlignedFlyBrain.v3draw"

SIMMETRIC=${OUTPUT}"/txmi"
AFFINEMATRIX=${OUTPUT}"/txmiAffine.txt"

SUBISNIIDS=${OUTPUT}"/subtxIS_c0_ds.nii"
TARTXNIIDS=${OUTPUT}"/temptargettx_c0_ds.nii"

if ( is_file_exist "$FIXED" )
then
echo " FIXED exists"
else
#---exe---#
message " Converting 20x target into Nifti image "
$Vaa3D -x ireg -f NiftiImageConverter -i $TAR
fi

if ( is_file_exist "$MOVING" )
then
echo " MOVING exists"
else
#---exe---#
message " Converting 20x subject into Nifti image "
$Vaa3D -x ireg -f NiftiImageConverter -i $SUBTXIS
fi

if ( is_file_exist "$TARTXNIIDS" )
then
echo " TARTXNIIDS exists"
else
#---exe---#
message " Downsampling 20x target "
$Vaa3D -x ireg -f resamplebyspacing -i $FIXED -o $TARTXNIIDS -p "#x $DSRATIO #y $DSRATIO #z $DSRATIO" 
fi

if ( is_file_exist "$SUBISNIIDS" )
then
echo " SUBISNIIDS exists"
else
#---exe---#
message " Downsampling 20x subject "
$Vaa3D -x ireg -f resamplebyspacing -i $MOVING -o $SUBISNIIDS -p "#x $DSRATIO #y $DSRATIO #z $DSRATIO" 
fi

if ( is_file_exist "$AFFINEMATRIX" )
then
echo " AFFINEMATRIX exists"
else
#---exe---#
message " Global aligning 20x fly brain to 20x target brain "
$ANTS 3 -m MI[ $TARTXNIIDS, $SUBISNIIDS, 1, 32] -o $SIMMETRIC -i 0 --number-of-affine-iterations $MAXITERATIONS --rigid-affine true --affine-gradient-descent-option $GRADDSCNTOPTS
fi


### extract rotation matrix from the affine matrix

ROTMATRIX=${OUTPUT}"/txmiRotation.txt"

if ( is_file_exist "$ROTMATRIX" )
then
echo " ROTMATRIX exists"
else
#---exe---#
message " Extracting roations from the rigid transformations "
$Vaa3D -x ireg -f extractRotMat -i $AFFINEMATRIX -o $ROTMATRIX
fi

#
### local alignment
#

message " Local alignment "

SIMMETRIC=${OUTPUT}"/ccmi"
AFFINEMATRIXLOCAL=${OUTPUT}"/ccmiAffine.txt"
FWDDISPFIELD=${OUTPUT}"/ccmiWarp.nii.gz"
BWDDISPFIELD=${OUTPUT}"/ccmiInverseWarp.nii.gz"

MAXITERSCC=30x90x20

if ( is_file_exist "$AFFINEMATRIXLOCAL" )
then
echo " AFFINEMATRIXLOCAL exists"
else
#---exe---#
message " Local aligning 20x fly brain to 20x target brain "
$ANTS 3 -m  CC[ $TARTXNIIDS, $SUBISNIIDS, 0.75, 4] -m MI[ $TARTXNIIDS, $SUBISNIIDS, 0.25, 32] -t SyN[0.25]  -r Gauss[3,0] -o $SIMMETRIC -i $MAXITERSCC --initial-affine $AFFINEMATRIX
fi


### warp

if ( is_file_exist "$SUBSC" )
then
echo " SUBSC exists"
else
#---exe---#
message " Warping 20x subject "
$WARP 3 $MOVINGFC $SUBFC -R $FIXED $FWDDISPFIELD $AFFINEMATRIXLOCAL --use-BSpline
$WARP 3 $MOVINGSC $SUBSC -R $FIXED $FWDDISPFIELD $AFFINEMATRIXLOCAL --use-BSpline
fi

if ( is_file_exist "$SUBBRAINDeformed" )
then
echo " SUBBRAINDeformed exists"
else
#---exe---#
message " Combining the 2 aligned images into one stack "
$Vaa3D -x ireg -f NiftiImageConverter -i $SUBFC $SUBSC -o $SUBBRAINDeformed -p "#b 1 #v 1"
fi

SUBVNCRotated=${FINALOUTPUT}"/AlignedFlyVNC.v3draw"

if ( is_file_exist "$SUBVNCRotated" )
then
echo " SUBVNCRotated exists"
else
#---exe---#
message " Warping VNC images "
$Vaa3D -x ireg -f iwarp -o $SUBVNCRotated -p "#s $SUBVRAW #t $SUBVRAW #a $ROTMATRIX"
fi

##################
# 20x unified
##################

VECTARI=0.6944

SUBALIGNED=${OUTPUT}"/FlyBrainAligned20xScaled.v3draw"

if ( is_file_exist "$SUBALIGNED" )
then
echo " SUBALIGNED exists"
else
#---exe---#
message " Obtain final aligned result "
$Vaa3D -x ireg -f isampler -i $SUBBRAINDeformed -o $SUBALIGNED -p "#x 1.0 #y 1.0 #z $VECTARI"
fi

SUBALIGNEDUNIFIED=${FINALOUTPUT}"/FlyBrainAligned20xScaled.v3draw"

if ( is_file_exist "$SUBALIGNEDUNIFIED" )
then
echo " SUBALIGNEDUNIFIED exists"
else
#---exe---#
message " Rescale to unified space "
$Vaa3D -x ireg -f prepare20xData -o $SUBALIGNEDUNIFIED -p "#s $SUBALIGNED #t $ATLAS"
fi


##################
# evalutation
##################

AQ=${FINALOUTPUT}"/AlignmentQuality.txt"

SUBREF=$((SUBREF+1))

if ( is_file_exist "$AQ" )
then
echo " AQ exists"
else
#---exe---#
message " Evaluating "
$Vaa3D -x ireg -f evalAlignQuality -o $AQ -p "#s $SUBALIGNEDUNIFIED #cs $SUBREF #t $ATLAS"
fi


##################
# clean temp files
##################

#---exe---#
##rm -rf $OUTPUT

# We're done with the frame buffer
kill -9 $MYPID

