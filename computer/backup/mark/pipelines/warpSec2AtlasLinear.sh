

### input

NM=$1
NF=$2

MOVPRE=$3
SUFFIX=$4
AFFPRE=$5
OUTPRE=$6

DIM=$7

### pipeline

for((i=0; i<$NM; i++))
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

mov=$MOVPRE$n$SUFFIX

for((j=0; j<$NF; j++))
do

p=$j

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


out=$OUTPRE$i"/f"$i"t"$j"_l.nii"

aff=$AFFPRE$i"/f"$i"t"$j"Affine.txt"

# step 1
#./WarpImageMultiTransform $DIM ${mov} ${out} -R ${mov} ${aff} --use-BSpline

# step 2
#./filter -f imageReadWrite -i ${out} -o ${out%*.nii}_byte.tif

# step 3
./vaa3d -x ireg -f esimilarity -p "#s ${out%*.nii}_byte.tif #t /groups/jacs/jacsShare/yuTest/Share4Mark/AMBA/resliced/targetseq/atlasSec${p}.tif" -o ${out%*.nii}_byte.txt


done

done

