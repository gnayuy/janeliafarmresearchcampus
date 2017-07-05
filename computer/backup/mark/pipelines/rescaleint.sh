pre=/groups/scicomp/jacsData/yuTest/markReconstruction/workdir/mb1335038/temp/align/section

for((i=1; i<102; i++))
do

sub=${pre}${i}"_aligned.v3draw"
ref=${pre}${i}".tif"

out=${pre}${i}"_aligned.tif"


./ifilter -f rescaleIntensity -i $sub -o $out -p "-f $ref"


done
