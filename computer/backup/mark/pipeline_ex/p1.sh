
# Create symbolic links and convert tiled tiff to strip tiff and then resize images into the same dimensions
# Yang Yu (yuy@janelia.hhmi.org) 7/8/2014
#


IFILTER=/home/yuy/work/research/tools/neucv/gnubuild/ifilter

ORIDIR=$1
LINKDIR=$2
OUTDIR=$3

# create links

for FILE in ${ORIDIR}/*.tif;
do

T=${FILE#*_*}
T=${T#*_*}
section=${T%*.tif}

if((section<10))
then
section="0"$section;
fi

T=${FILE%*_*}
slice=${T#*_*}

if((slice<10))
then
slice="0"$slice;
fi

ln -s $FILE ${LINKDIR}"/tile"${slice}"_"${section}".tif"

done



# convert and resize images into the same dimensions

N=0;

for FILE in ${LINKDIR}/*.tif;
do

N=$((N+1));

n=$N;

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

# using blue color channel as the reference channel
$IFILTER -f resizeImage -i $FILE -o ${OUTDIR}"/sec"${n}.tif -p "-r 2"

$IFILTER -f scale -i ${OUTDIR}"/sec"${n}.tif -o ${OUTDIR}"/sec"${n}"_ds.tif" -p "-x 0.05 -y 0.05"

echo $FILE $N

done
