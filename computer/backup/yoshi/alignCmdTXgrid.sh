

WD=/groups/scicomp/jacsData/yuTest/YoshiMB/sources/standardbrainDPX/workdir/
count=1;
for SUBTX in /groups/scicomp/jacsData/yuTest/YoshiMB/sources/standardbrainDPX/TX/*.lsm;
do

WORKDIR=${WD}"tmp"$((count++))

if [ ! -d $WORKDIR ]; then 
mkdir $WORKDIR
fi

echo $((count-1)) $SUBTX
#qsub -b y -cwd -V -l excl=true /groups/scicomp/jacsData/yuTest/YoshiMB/sources/standardbrainDPX/alignCmd.sh $WORKDIR $SUBTX

done;



