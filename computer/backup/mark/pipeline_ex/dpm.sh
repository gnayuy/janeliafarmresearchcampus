is_file_exist()
{
    local f="$1"
    [[ -f "$f" ]] && return 0 || return 1
}

IREG=/home/yuy/work/research/tools/neucv/gnubuild/ireg

# sh dpm.sh /groups/jacs/jacsShare/yuTest/Share4Mark/AMBA/resliced/targetseq/atlasSec /nobackup/scicompsoft/yuTest/markCembrowski/wholeBrain1404978drd2Rabies/workdir/blue/warped 54

PRE=$1
OUTDIR=$2
N=$3

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


#MOV=${PRE}${n}".tif"
FIX=${PRE}${p}".tif"



if ( is_file_exist "${OUTDIR}/sec${i}/ncc${ORDER}.txt" )
then
echo "${OUTDIR}/sec${i}/ncc${ORDER}.txt exists"
else
#---exe---#
$IREG -f imageCompare -i ${OUTDIR}/sec${i}/${ORDER}.nii -o ${OUTDIR}/sec${i}/ncc${ORDER}.txt -p "-r ${FIX} -s 2"
fi



done


done

