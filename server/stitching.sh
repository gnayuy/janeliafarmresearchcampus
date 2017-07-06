
# stitching script 12/06/2016
# sh stitching.sh

V3D=/groups/jacs/jacsHosts/servers/jacs-data2/executables/vaa3d-redhat/vaa3d

INPUTDIR=$1
OUTPUT=$2
REFCH=$3


time $V3D -x imageStitch -f v3dstitch -i $INPUTDIR -p "#c $REFCH #si 0";

time $V3D -x ifusion -f iblender -i $INPUTDIR -o $OUTPUT

