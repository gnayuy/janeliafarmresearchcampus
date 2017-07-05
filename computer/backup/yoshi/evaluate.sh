
PATH=${1}

TAR=/groups/scicomp/jacsData/yuTest/YoshiMB/statistics/flybrainTemplate.v3draw
MASK=/groups/scicomp/jacsData/yuTest/YoshiMB/statistics/mbTemplate_mask.tif


for i in $PATH/*ref.tif;
do

output=${i%*ref.tif}ncc.txt

./vaa3d -x ireg -f esimilarity -o $output -p "#s $i #t $TAR #m $MASK"

done

