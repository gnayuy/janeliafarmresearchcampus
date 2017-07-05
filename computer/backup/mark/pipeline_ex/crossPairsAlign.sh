

# sh crossPairsAlign.sh /nobackup/scicompsoft/yuTest/markCembrowski/wholeBrain1404978drd2Rabies/workdir/sub/blue/dsrc /groups/jacs/jacsShare/yuTest/Share4Mark/AMBA/resliced/targetseq/atlasSec /nobackup/scicompsoft/yuTest/markCembrowski/wholeBrain1404978drd2Rabies/workdir/crossrigid 54

MOVPRE=$1
FIXPRE=$2
OUTDIR=$3
N=$4

for((i=0; i<528; i++))
do

p=$i

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


for((j=0; j<$N; j++))
do

n=$j

ORDER="f"$j"t"$i

if((n<10))
then
n="000"$n;
elif((n<100))
then
n="00"$n;
elif((n<1000))
then
n="0"$n;
fi


MOV=${MOVPRE}${n}".nii"
FIX=${FIXPRE}${p}".tif"


echo "/nobackup/scicompsoft/yuTest/jacs/toolkits/ANTS/ANTS 2 -m MI[ $FIX, $MOV, 1, 32] -o ${OUTDIR}/sec${i}/${ORDER} -i 0 --number-of-affine-iterations 10000x10000x10000 --rigid-affine true" >> ${OUTDIR}"/sec"${i}"/"$ORDER".sh"

done


done
