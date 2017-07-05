# warpVienna.sh developed by Yang Yu (yuy@janelia.hhmi.org)
#
### warp male fly brain that is aligned to the Vienna template to JFRC2014 
#

is_file_exist()
{
    local f="$1"
    [[ -f "$f" ]] && return 0 || return 1
}

### tools
WARP=/groups/jacs/jacsDev/servers/jacs-staging/executables/scripts/single_neuron/Toolkits/ANTS/WarpImageMultiTransform
Vaa3D=/groups/jacs/jacsDev/servers/jacs-staging/executables/scripts/single_neuron/Toolkits/Vaa3D/vaa3d

### target image JFRC2014
TAR=/groups/jacs/jacsDev/servers/jacs-staging/executables/scripts/single_neuron/BrainAligner/AlignTemplates/configured_templates/wfb_btx_template_dpx.v3draw
TARRS=/groups/jacs/jacsDev/servers/jacs-staging/executables/scripts/single_neuron/BrainAligner/AlignTemplates/configured_templates/wfb_btx_template_dpx_rec.v3draw
TARRSNII=/nobackup/scicompsoft/yuTest/dicksonlab/fru_atlas/alignment/target.nii

### warping fields
AFFJJ=/nobackup/scicompsoft/yuTest/dicksonlab/fru_atlas/alignment/Vienna/warpingfieldJefferis2JFRC/Affine.txt
WFJJ=/nobackup/scicompsoft/yuTest/dicksonlab/fru_atlas/alignment/Vienna/warpingfieldJefferis2JFRC/Warp.nii.gz

AFFVJ=/nobackup/scicompsoft/yuTest/dicksonlab/fru_atlas/alignment/Vienna/warpingfieldVienna2Jefferis/Affine.txt
WFVJ=/nobackup/scicompsoft/yuTest/dicksonlab/fru_atlas/alignment/Vienna/warpingfieldVienna2Jefferis/Warp.nii.gz

### input and output
IN=$1
OUT=$2

TMPDIR=$3

### processes

# 1. convert tif to v3draw

INRAW=${TMPDIR}"/"${IN%*.*}".v3draw"

if ( is_file_exist "$INRAW" )
then
echo " INRAW: $INRAW exists"
else
#---exe---#
vaa3d -x ireg -f yflip -i $IN -o $INRAW
fi

# 2. resize image

INRS=${INRAW%*.v3draw}"_rs.v3draw"

if ( is_file_exist "$INRS" )
then
echo " INRS: $INRS exists"
else
#---exe---#
$Vaa3D -x ireg -f resizeImage -o $INRS -p "#s $INRAW #t $TARRS"
fi

# 3. convert to nii

INRSNII=${INRS%*.v3draw}"_c0.nii"

if ( is_file_exist "$INRSNII" )
then
echo " INRSNII: $INRSNII exists"
else
#---exe---#
$Vaa3D -x ireg -f NiftiImageConverter -i $INRS
fi

# 4. warp

if ( is_file_exist ${INRSNII%*.nii}"_warped.nii" )
then
echo " INRSNII: ${INRSNII%*.nii}\"_warped.nii\" exists"
else
#---exe---#
$WARP 3 $INRSNII ${INRSNII%*.nii}"_warped.nii" -R $TARRSNII $WFVJ $AFFVJ --use-BSpline
fi

if ( is_file_exist ${INRSNII%*.nii}"_warped2.nii" )
then
echo " INRSNII: ${INRSNII%*.nii}\"_warped2.nii\" exists"
else
#---exe---#
$WARP 3 ${INRSNII%*.nii}"_warped.nii" ${INRSNII%*.nii}"_warped2.nii" -R $TARRSNII $WFJJ $AFFJJ --use-BSpline
fi


# 5. convert to tif

INRSWARP=${INRSNII%*.nii}"_warped.v3draw"

if ( is_file_exist "$INRSWARP" )
then
echo " INRSWARP: $INRSWARP exists"
else
#---exe---#
$Vaa3D -x ireg -f NiftiImageConverter -i ${INRSNII%*.nii}"_warped2.nii" -o $INRSWARP -p "#b 1 #v 1"
fi


# 6. resize image

if ( is_file_exist "$OUT" )
then
echo " OUT: $OUT exists"
else
#---exe---#
$Vaa3D -x ireg -f prepare20xData -o $OUT -p "#s $INRSWARP #t $TAR"
fi


