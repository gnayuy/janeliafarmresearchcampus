set -o errexit
PORT=1014
while (test -f "/tmp/.X${PORT}-lock") || (netstat -atwn | grep "^.*:${PORT}.*:\*\s*LISTEN\s*$")
do PORT=$(( ${PORT} + 1 ))
done
/usr/bin/Xvfb :${PORT} -screen 0 1x1x24 -fp /usr/share/X11/fonts/misc &
MYPID=$!
export DISPLAY="localhost:${PORT}.0"

#export LD_LIBRARY_PATH=/groups/scicomp/jacsData/install/Qt-4.7.4-redhat/lib:/groups/scicomp/jacsData/servers/rokicki-ws/executables/install/vaa3d-redhat/lib:$LD_LIBRARY_PATH
#/groups/scicomp/jacsData/servers/rokicki-ws/executables/install/vaa3d-redhat/vaa3d -x imageStitch.so -f v3dstitch -i "/groups/scicomp/jacsData/devstore/system/Sample/598/123/1722854064313598123/group" -p "#c 4 #si 0";

#export LD_LIBRARY_PATH=/groups/scicomp/jacsData/install/Qt-4.7.4-redhat/lib:/groups/scicomp/jacsData/servers/rokicki-ws/executables/install/vaa3d-redhat/lib:$LD_LIBRARY_PATH
#/groups/scicomp/jacsData/servers/rokicki-ws/executables/install/vaa3d-redhat/vaa3d -x ifusion.so -f iblender -i "/groups/scicomp/jacsData/devstore/system/Sample/598/123/1722854064313598123/group" -o "stitched-1722845959441875115.v3draw" -p "#s 1"

Vaa3D="/groups/scicomp/jacsData/yuTest/toolkits/Vaa3D/vaa3d"
#Tiles=/groups/scicomp/jacsData/yuTest/stitchPipeline/data/ex1

Tiles=$1

#$Vaa3D -x imageStitch -f v3dstitch -i $Tiles -p "#c 1 #si 0";
$Vaa3D -x ifusion -f iblender -i $Tiles -o $Tiles"/stitched.v3draw" -p "#s 1"


kill $MYPID
