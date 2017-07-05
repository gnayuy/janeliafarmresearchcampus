# sh warpBestMatch.sh ../workdir/sub/red/dsrc _c0.tif ../workdir/crossrigid ./matches.txt ../workdir/red


SUBPRE=$1
SUBSUF=$2
WARPPRE=$3
MATCHES=$4
OUTPRE=$5

DIM=2

i=0
while read line
do

n=($line);
seclist[$i]=${n[1]};
i=$((i+1))

done < $MATCHES

n=$i;

for((i=0; i<$n; i++))
do

sub=$i
tar=${seclist[$i]}


ORDER="f"${sub}"t"${tar}

AFF=$WARPPRE/sec${tar}/$ORDER"Affine.txt"

p=$sub;

if((p<10))
then
p="000"$p;
elif((p<100))
then
p="00"$p;
elif((p<1000))
then
p="0"$p;
fi

q=$tar
if((q<10))
then
q="000"$q;
elif((q<100))
then
q="00"$q;
elif((q<1000))
then
q="0"$q;
fi

SUB=$SUBPRE$p$SUBSUF
OUT=$OUTPRE"/found/sec"$q".nii"

/nobackup/scicompsoft/yuTest/jacs/toolkits/ANTS/WarpImageMultiTransform $DIM $SUB $OUT -R $SUB $AFF --use-BSpline

done
