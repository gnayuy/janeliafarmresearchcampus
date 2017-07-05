#!/bin/bash

# developed by Yang Yu (yuy@janelia.hhmi.org), 10/20/2014

#

STARTSECTION=$1
ENDSECTION=$2
W=$3
H=$4
JSONDIR=$5

for((i=$STARTSECTION; i<=$ENDSECTION; i++))
do

out=section$i

mkdir $out

sh makechunks.sh $JSONDIR/"layer_"$i".json" $W $H $out/flypilot863_section$i

done 

