
# sh warpingMB.sh /nobackup/scicompsoft/yuTest/markCembrowski/wholeBrain1404978drd2Rabies/workdir/sub/blue/dsrc /groups/jacs/jacsShare/yuTest/Share4Mark/AMBA/resliced/targetseq/atlasSec /nobackup/scicompsoft/yuTest/markCembrowski/wholeBrain1404978drd2Rabies/workdir/crossrigid /nobackup/scicompsoft/yuTest/markCembrowski/wholeBrain1404978drd2Rabies/workdir/blue/warped 54

MOVPRE=$1
FIXPRE=$2
AFFDIR=$3
OUTDIR=$4
N=$5

for((i=0; i<528; i++))
do

n=$i

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

for((j=0; j<$N; j++))
do

p=$j

ORDER="f"$j"t"$i

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


#
MOV=${MOVPRE}${p}".nii"
FIX=${FIXPRE}${n}".tif"


#echo "/nobackup/scicompsoft/yuTest/jacs/toolkits/ANTS/WarpImageMultiTransform 2 $MOV ${OUTDIR}/sec${i}/${ORDER}.nii -R $FIX ${AFFDIR}/sec${i}/${ORDER}Affine.txt --use-BSpline " >> ${OUTDIR}"/sec"${i}"/"$ORDER".sh"

/nobackup/scicompsoft/yuTest/jacs/toolkits/ANTS/WarpImageMultiTransform 2 $MOV ${OUTDIR}/sec${i}/${ORDER}.nii -R $FIX ${AFFDIR}/sec${i}/${ORDER}Affine.txt --use-BSpline

done # j

done # i
