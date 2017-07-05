#!/bin/bash

# warpVienna.sh developed by Yang Yu (yuy@janelia.hhmi.org)
#
### warp male fly brain that is aligned to the Vienna template to JFRC2014 
#

echo "Running on "`hostname`
echo "Finding a port for Xvfb, starting at 5282..."
PORT=5282 COUNTER=0 RETRIES=10
function cleanXvfb {
    kill $MYPID
    rm -f /tmp/.X${PORT}-lock
    rm -f /tmp/.X11-unix/X${PORT}
    echo "Cleaned up Xvfb"
}
trap cleanXvfb EXIT
while [ "$COUNTER" -lt "$RETRIES" ]; do
    while (test -f "/tmp/.X${PORT}-lock") || (test -f "/tmp/.X11-unix/X${PORT}") || (netstat -atwn | grep "^.*:${PORT}.*:\*\s*LISTEN\s*$")
        do PORT=$(( ${PORT} + 1 ))
    done
    echo "Found the first free port: $PORT"
    /usr/bin/Xvfb :${PORT} -screen 0 1x1x24 -fp /usr/share/X11/fonts/misc > Xvfb.${PORT}.log 2>&1 &
    echo "Started Xvfb on port $PORT"
    MYPID=$!
    export DISPLAY="localhost:${PORT}.0"
    sleep 3
    if kill -0 $MYPID >/dev/null 2>&1; then
        echo "Xvfb is running as $MYPID"
        break
    else
        echo "Xvfb died immediately, trying again..."
        cleanXvfb
        PORT=$(( ${PORT} + 1 ))
    fi
    COUNTER="$(( $COUNTER + 1 ))"
done

export LD_LIBRARY_PATH=/groups/jacs/jacsDev/server/jacs-staging/executables/Qt-4.7.4-redhat/lib:/groups/jacs/jacsDev/server/jacs-staging/executables/vaa3d-redhat/lib:$LD_LIBRARY_PATH

is_file_exist()
{
    local f="$1"
    [[ -f "$f" ]] && return 0 || return 1
}

### tools
LOCI=/nobackup/scicompsoft/yuTest/dicksonlab/warpVienna2JFRC2014/loci_tools.jar
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

FILEBASE=${IN%*/*}
FILEBASE=${IN#*${FILEBASE}/*}

# 0. convert .am to .tif

INTIF=${TMPDIR}"/"${FILEBASE%*.*}".tif"

if ( is_file_exist "$INTIF" )
then
echo " INTIF: $INTIF exists"
else
#---exe---#
java -cp $LOCI loci.formats.tools.ImageConverter $IN $INTIF
fi

# 1. convert tif to v3draw

INRAWFLIP=${TMPDIR}"/"${FILEBASE%*.*}"_yflip.v3draw"
INRAW=${TMPDIR}"/"${FILEBASE%*.*}".v3draw"

if ( is_file_exist "$INRAWFLIP" )
then
echo " INRAWFLIP: $INRAWFLIP exists"
else
#---exe---#
$Vaa3D -cmd image-loader -convert $INTIF $INRAWFLIP
fi

if ( is_file_exist "$INRAW" )
then
echo " INRAW: $INRAW exists"
else
#---exe---#
$Vaa3D -x ireg -f yflip -i $INRAWFLIP -o $INRAW
fi


# 2. resize image

INRS=${INRAW%*.v3draw}"_rs.v3draw"

if ( is_file_exist "$INRS" )
then
echo " INRS: $INRS exists"
else
#---exe---#
$Vaa3D -x ireg -f resizeImage -o $INRS -p "#s $INRAW #t $TARRS #k 1 #i 1"
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

if ( is_file_exist "$INRSNII" )
then
echo " INRSNII: $INRSNII exists"
else
#---exe---#
$Vaa3D -x ireg -f NiftiImageConverter -i $INRS
fi


if ( is_file_exist ${INRSNII%*.nii}"_warped.nii" )
then
echo " INRSNII: ${INRSNII%*.nii}\"_warped.nii\" exists"
else
#---exe---#
$WARP 3 $INRSNII ${INRSNII%*.nii}"_warped.nii" -R $TARRSNII $WFVJ $AFFVJ --use-NN
fi

if ( is_file_exist ${INRSNII%*.nii}"_warped2.nii" )
then
echo " INRSNII: ${INRSNII%*.nii}\"_warped2.nii\" exists"
else
#---exe---#
$WARP 3 ${INRSNII%*.nii}"_warped.nii" ${INRSNII%*.nii}"_warped2.nii" -R $TARRSNII $WFJJ $AFFJJ --use-NN
fi


# 5. convert to tif

INRSWARP=${INRSNII%*.nii}"_warped.v3draw"

if ( is_file_exist "$INRSWARP" )
then
echo " INRSWARP: $INRSWARP exists"
else
#---exe---#
$Vaa3D -x ireg -f NiftiImageConverter -i ${INRSNII%*.nii}"_warped2.nii" -o $INRSWARP -p "#b 1 #v 1 #r 0"
fi


# 6. resize image

if ( is_file_exist "$OUT" )
then
echo " OUT: $OUT exists"
else
#---exe---#
$Vaa3D -x ireg -f prepare20xData -o $OUT -p "#s $INRSWARP #t $TAR #k 1"
fi

# 7. clean temporary files

rm -rf $TMPDIR

