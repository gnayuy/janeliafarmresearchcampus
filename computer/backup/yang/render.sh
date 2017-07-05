
# example:
# sh render.sh /nobackup/scicompsoft/yuTest/flyTEM/flypilot863/rendered_json /nobackup/scicompsoft/yuTest/flyTEM/flypilot863/scale0.01

JSONDIR=$1
OUTDIR=$2
SCALE=$3

RENDER=/nobackup/scicompsoft/yuTest/flyTEM/render/bin/qsub-render.sh

#for i in $JSONDIR/*.json; do echo $i >> $OUTDIR/filelist.txt; done

sh $RENDER $OUTDIR $OUTDIR/filelist.txt --scale $SCALE

