
# sh found.sh /nobackup/scicompsoft/yuTest/markCembrowski/wholeBrain1404978drd2Rabies/workdir/blue/warped /nobackup/scicompsoft/yuTest/markCembrowski/wholeBrain1404978drd2Rabies/workdir/blue


INDIR=$1
OUTDIR=$2


while read LINE
do

n=($LINE);

sh /nobackup/scicompsoft/yuTest/markCembrowski/remainingMouseBrains/pipeline/cpfiles.sh ${n[0]} ${n[1]} $INDIR  $OUTDIR


done < "matches.txt"
