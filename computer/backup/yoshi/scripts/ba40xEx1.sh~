#!/bin/bash

TEMPLATE=/groups/scicomp/jacsData/yuTest/YoshiMB/templates/wfb_atx_template_ori.tif

TARGET=/groups/scicomp/jacsData/yuTest/YoshiMB/templates/wfb_afx_template_rec.raw
TARGET_REFNO=1
SUBJET_REFNO=4

TARGET_LANDMARKS=/groups/scicomp/jacsData/yuTest/YoshiMB/templates/wfb_afx_template_rec_cb.marker

OUTPUT=/groups/scicomp/jacsData/yuTest/YoshiMB/results/flybrain40x

SUBGET=/groups/scicomp/jacsData/yuTest/YoshiMB/sources/flybrainFX.v3draw

#STR=`echo $i | awk -F\. '{print $1}'`
#CNT=$(echo $STR | tr -cd '[[:digit:]]')

qsub -b y -cwd -V -pe batch 8 -l mem96=true /groups/scicomp/jacsData/yuTest/YoshiMB/scripts/brainalign40x.sh $TARGET $TARGET_REFNO $TARGET_LANDMARKS $SUBGET $SUBJET_REFNO $OUTPUT $TEMPLATE
