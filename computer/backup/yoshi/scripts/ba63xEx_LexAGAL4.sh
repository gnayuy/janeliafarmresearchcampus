#!/bin/bash

OUTPUT=/groups/scicomp/jacsData/yuTest/YoshiMB/results/FFBSX/flybrain63x
SUBJET_REFNO=3

for SUBJECT in /groups/scicomp/jacsData/yuTest/YoshiMB/sources/FFBSX/5/stitched.v3draw
do

STR=`echo $SUBJECT | awk -F\. '{print $1}'`
CNT=$(echo $STR | tr -cd '[[:digit:]]')

qsub -b y -cwd -V -pe batch 8 -l mem96=true /groups/scicomp/jacsData/yuTest/YoshiMB/scripts/brainalign63xLexAGAL4_V1.06.sh $SUBJECT $SUBJET_REFNO $OUTPUT$CNT

done
