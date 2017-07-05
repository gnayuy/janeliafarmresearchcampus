
# blue
#sh genWarpIntSec.sh matches.txt "sh warpintsectionimage.sh /nobackup/scicompsoft/yuTest/markCembrowski/wholeBrainKlk8Inj040214/workdir/dapi /groups/jacs/jacsShare/yuTest/Share4Mark/AMBA/resliced/LinearTransforms"

# red
#sh genWarpIntSec.sh matches.txt "sh warpintsectionimage.sh /nobackup/scicompsoft/yuTest/markCembrowski/wholeBrainKlk8Inj040214/workdir/red /groups/jacs/jacsShare/yuTest/Share4Mark/AMBA/resliced/LinearTransforms"



PRE=$1
WARPDIR=$2

sh /nobackup/scicompsoft/yuTest/markCembrowski/remainingMouseBrains/pipeline/genWarpIntSec.sh matches.txt "sh /nobackup/scicompsoft/yuTest/markCembrowski/remainingMouseBrains/pipeline/warpintsectionimage.sh $PRE $WARPDIR"
