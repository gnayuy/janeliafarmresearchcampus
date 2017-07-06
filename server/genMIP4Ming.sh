# generate 2D MIP png from 3D v3draw
# developed by Yang Yu (yuy@janelia.hhmi.org)

#
## usage: sh genMIP.sh <stack> <mip>
#
# run on the cluster
#
# sh run_configured_aligner.sh genMIP.sh 4 -d '"debug"' -o workdir 
# -c systemvars.apconf -k Toolkits -i <stack>



Vaa3D=./vaa3d
MAGICK=/usr
NETPBM=/usr

STACK=$1
WORKDIR=$2

MIP=${STACK%*.v3draw}.png


echo ""
echo "Vaa3D: $Vaa3D"
echo "MAGICK: $MAGICK"
echo "STACK: $STACK"
echo "MIP: $MIP"
echo ""

TEMPOUT1=${WORKDIR}/mip.tif
TEMPOUT2=${WORKDIR}/mipContrastEnhanced.tif

# get MIP from 3D stack
$Vaa3D -x ireg -f zmip -i $STACK -o $TEMPOUT1

# enhance contrast
$Vaa3D -x ireg -f iContrastEnhancer -i $TEMPOUT1 -o $TEMPOUT2

# convert tiff to png
#$MAGICK/bin/convert -flip $TEMPOUT1 $MIP




# rm temporary files and copy the result to the right place
# 

