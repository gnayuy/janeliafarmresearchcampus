#!/bin/bash

PORT=1031
while (test -f "/tmp/.X${PORT}-lock") || (netstat -atwn | grep "^.*:${PORT}.*:\*\s*LISTEN\s*$")
do PORT=$(( ${PORT} + 1 ))
done
/usr/bin/Xvfb :${PORT} -screen 0 1x1x24 -sp /usr/lib64/xserver/SecurityPolicy -fp /usr/share/X11/fonts/misc &
MYPID=$!
export DISPLAY="localhost:${PORT}.0"


NUMPARAMS=$#
if [ $NUMPARAMS -lt 2 ]
then
echo " "
echo " USAGE ::  "
echo " sh enhance.sh input output"
echo " "
exit
fi

Vaa3D=/groups/scicomp/jacsData/yuTest/YoshiMB/toolkits/Vaa3D/vaa3d

INPUT=$1
OUTPUT=$2

$Vaa3D -x ireg -f iContrastEnhancer -i $INPUT -o $OUTPUT -p "#m 5"

# We're done with the frame buffer
kill -9 $MYPID

