#!/bin/bash
#
# fly alignment pipeline, version 1.0, 2013/2/15
#

################################################################################
#
# The pipeline is developed for aligning 20x fly (brain + VNC).
# Target brain's resolution (0.62x0.62x0.62 um)
#
################################################################################

##################
# Basic Funcs
##################

DIR=$(cd "$(dirname "$0")"; pwd)
. $DIR/common.sh

##################
# Inputs
##################

parseParameters "$@"
CONFIGFILE=$CONFIG_FILE
TMPLDIR=$TEMPLATE_DIR
TOOLDIR=$TOOL_DIR
WORKDIR=$WORK_DIR
SUBBRAIN=$INPUT1_FILE
SUBREF=$INPUT1_REF
MP=$MOUNTING_PROTOCOL
RESX=$INPUT1_RESX
RESY=$INPUT1_RESY
RESZ=$INPUT1_RESZ

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
echo "SUBREF: $SUBREF"
echo "MountingProtocol: $MP"
message "Vars..."
echo "Vaa3D: $Vaa3D"
echo "ANTS: $ANTS"
echo "WARP: $WARP"
echo "TAR: $TAR"
echo "TARREF: $TARREF"
echo "ATLAS: $ATLAS"
echo "RESX: $RESX"
echo "RESY: $RESY"
echo "RESZ: $RESZ"
echo ""

OUTPUT=${WORKDIR}"/Output"
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

if ( is_file_exist "$SUBBRAW" )
then
echo " SUBBRAW: $SUBBRAW exists"
else
#---exe---#
message " Converting to v3draw file "
$Vaa3D -cmd image-loader -convert8 $SUBBRAIN $SUBBRAW
fi

### shrinkage ratio
# VECTASHIELD/DPXEthanol = 0.82
# VECTASHIELD/DPXPBS = 0.86
DPXSHRINKRATIO=1.0

if [[ $MP =~ "DPX Ethanol Mounting" ]]
then
    DPXSHRINKRATIO=0.82
elif [[ $MP =~ "DPX PBS Mounting" ]]
then
    DPXSHRINKRATIO=0.86
elif [[ $MP =~ "" ]]
then
    echo "Mounting protocol not specified, proceeding with DPXSHRINKRATIO=$DPXSHRINKRATIO"
else
    # other mounting protocol
    echo "Unknown mounting protocol: $MP"
fi
 
echo "echo $DPXSHRINKRATIO*$RESTX_X | bc -l"
RESTX_X=`echo $DPXSHRINKRATIO*$RESTX_X | bc -l`
echo "echo $DPXSHRINKRATIO*$RESTX_Y | bc -l"
RESTX_Y=`echo $DPXSHRINKRATIO*$RESTX_Y | bc -l`
echo "echo $DPXSHRINKRATIO*$RESTX_Z | bc -l"
RESTX_Z=`echo $DPXSHRINKRATIO*$RESTX_Z | bc -l`

### isotropic interpolation
SRX=`echo $RESX/$RESTX_X | bc -l`
SRY=`echo $RESY/$RESTX_Y | bc -l`
SRZ=`echo $RESZ/$RESTX_Z | bc -l`

### isotropic
SUBTXIS=${OUTPUT}"/subtxIS.v3draw"

if ( is_file_exist "$SUBTXIS" )
then
echo " SUBTXIS: $SUBTXIS exists"
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
SUBFC=$STRS"_c0_deformed.nii"

SUBBRAINDeformed=${OUTPUT}"/AlignedFlyBrain.v3draw"

SIMMETRIC=${OUTPUT}"/txmi"
AFFINEMATRIX=${OUTPUT}"/txmiAffine.txt"

SUBISNIIDS=${OUTPUT}"/subtxIS_c"${SUBREF}"_ds.nii"
TARTXNIIDS=${OUTPUT}"/temptargettx_c0_ds.nii"

if ( is_file_exist "$FIXED" )
then
echo " FIXED: $FIXED exists"
else
#---exe---#
message " Converting 20x target into Nifti image "
$Vaa3D -x ireg -f NiftiImageConverter -i $TAR
fi

if ( is_file_exist "$MOVING" )
then
echo " MOVING: $MOVING exists"
else
#---exe---#
message " Converting 20x subject into Nifti image "
$Vaa3D -x ireg -f NiftiImageConverter -i $SUBTXIS
fi

if ( is_file_exist "$TARTXNIIDS" )
then
echo " TARTXNIIDS: $TARTXNIIDS exists"
else
#---exe---#
message " Downsampling 20x target "
$Vaa3D -x ireg -f resamplebyspacing -i $FIXED -o $TARTXNIIDS -p "#x $DSRATIO #y $DSRATIO #z $DSRATIO" 
fi

if ( is_file_exist "$SUBISNIIDS" )
then
echo " SUBISNIIDS: $SUBISNIIDS exists"
else
#---exe---#
message " Downsampling 20x subject "
$Vaa3D -x ireg -f resamplebyspacing -i $MOVING -o $SUBISNIIDS -p "#x $DSRATIO #y $DSRATIO #z $DSRATIO" 
fi

if ( is_file_exist "$AFFINEMATRIX" )
then
echo " AFFINEMATRIX: $AFFINEMATRIX exists"
else
#---exe---#
message " Global aligning 20x fly brain to 20x target brain "
$ANTS 3 -m MI[ $TARTXNIIDS, $SUBISNIIDS, 1, 32] -o $SIMMETRIC -i 0 --number-of-affine-iterations $MAXITERATIONS --rigid-affine true --affine-gradient-descent-option $GRADDSCNTOPTS
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
echo " AFFINEMATRIXLOCAL: $AFFINEMATRIXLOCAL exists"
else
#---exe---#
message " Local aligning 20x fly brain to 20x target brain "
$ANTS 3 -m  CC[ $TARTXNIIDS, $SUBISNIIDS, 0.75, 4] -m MI[ $TARTXNIIDS, $SUBISNIIDS, 0.25, 32] -t SyN[0.25]  -r Gauss[3,0] -o $SIMMETRIC -i $MAXITERSCC --initial-affine $AFFINEMATRIX
fi


### warp

# brain

if ( is_file_exist "$SUBFC" )
then
echo " SUBFC: $SUBFC exists"
else
#---exe---#
message " Warping 20x subject "
$WARP 3 $MOVINGFC $SUBFC -R $FIXED $FWDDISPFIELD $AFFINEMATRIXLOCAL --use-BSpline
fi

if ( is_file_exist "$SUBBRAINDeformed" )
then
echo " SUBBRAINDeformed: $SUBBRAINDeformed exists"
else
#---exe---#
message " Combining the 2 aligned images into one stack "
$Vaa3D -x ireg -f NiftiImageConverter -i $SUBFC $SUBSC -o $SUBBRAINDeformed -p "#b 1 #v 1"
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



