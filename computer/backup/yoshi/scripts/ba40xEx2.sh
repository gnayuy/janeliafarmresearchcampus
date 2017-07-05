#!/bin/bash

TEMPLATE=/groups/scicomp/jacsData/yuTest/YoshiMB/templates/wfb_atx_template_ori.tif

TARGET=/groups/scicomp/jacsData/yuTest/YoshiMB/templates/wfb_afx_template_rec.raw
TARGET_REFNO=1
SUBJET_REFNO=3

TARGET_LANDMARKS=/groups/scicomp/jacsData/yuTest/YoshiMB/templates/wfb_afx_template_rec_cb.marker

OUTPUT=/home/yuy/work/BrainAlignerTest/testsamples/flybrain40x

for SUBGET in /home/yuy/work/BrainAlignerTest/testsamples/*/*.v3draw
do

STR=`echo $SUBGET | awk -F\. '{print $1}'`
CNT=$(echo $STR | tr -cd '[[:digit:]]')

qsub -b y -cwd -V -pe batch 8 -l mem96=true /groups/scicomp/jacsData/yuTest/YoshiMB/scripts/brainalign40xLeeLab.sh $TARGET $TARGET_REFNO $TARGET_LANDMARKS $SUBGET $SUBJET_REFNO $OUTPUT$CNT $TEMPLATE

done
