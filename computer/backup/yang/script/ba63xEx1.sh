#!/bin/bash

TEMPLATE=/groups/scicomp/jacsData/yuTest/flybrainAlign/template/wfb_atx_template_ori.tif

TARGET=/groups/scicomp/jacsData/yuTest/flybrainAlign/template/New/wfb_asx_template_rec2.raw
TARGET_REFNO=1
SUBJET_REFNO=4

TARGET_LANDMARKS=/groups/scicomp/jacsData/yuTest/flybrainAlign/template/New/wfb_asx_template_rec2.marker

OUTPUT=/home/yuy/work/BrainAlignerTest/flybrain63x

i=/home/yuy/work/BrainAlignerTest/source/flybrainSX.v3draw

#STR=`echo $i | awk -F\. '{print $1}'`
#CNT=$(echo $STR | tr -cd '[[:digit:]]')

#JBA
#qsub -b y -cwd -V -pe batch 4 -l mem96=true 

qsub -b y -cwd -V -pe batch 8 -l mem96=true /home/yuy/work/BrainAlignerTest/script/brainalign63x.sh $TARGET $TARGET_REFNO $TARGET_LANDMARKS $i $SUBJET_REFNO $OUTPUT $TEMPLATE
