#!/bin/bash

TEMPLATE=/groups/scicomp/jacsData/yuTest/YoshiMB/templates/wfb_atx_template_ori.tif

TARGETTX=/groups/scicomp/jacsData/yuTest/YoshiMB/templates/wfb_atx_template_rec.tif
TARGETTXREFNO=1
TARGETSX=/groups/scicomp/jacsData/yuTest/YoshiMB/templates/wfb_atxh_template_rec.v3draw
TARGETSXREFNO=1

OUTPUT=/groups/scicomp/jacsData/yuTest/YoshiMB/sources/splitPolarity/result/ex2

SUBGECTTX=/groups/scicomp/jacsData/yuTest/YoshiMB/sources/splitPolarity/TX/fbsptx1.v3draw
SUBJECTTXREFNO=4
RESTXX=0.52
RESTXY=0.52
RESTXZ=1.0

#SUBGECTSX=/groups/scicomp/jacsData/yuTest/YoshiMB/sources/splitPolarity/PSX/fbspsx1.v3draw
SUBGECTSX=/groups/scicomp/jacsData/yuTest/Tanya/data/Test1/ex1.v3draw
SUBJECTSXREFNO=4
RESSXX=0.19
RESSXY=0.19
RESSXZ=0.38



#STR=`echo $i | awk -F\. '{print $1}'`
#CNT=$(echo $STR | tr -cd '[[:digit:]]')

#qsub -b y -cwd -V -pe batch 8 -l mem96=true /groups/scicomp/jacsData/yuTest/YoshiMB/scripts/polaritybrainalign.sh $TARGETTX $TARGETTXREFNO $TARGETSX $TARGETSXREFNO $SUBGECTTX $SUBJECTTXREFNO $SUBGECTSX $SUBJECTSXREFNO $OUTPUT $RESTXX $RESTXY $RESTXZ $RESSXX $RESSXY $RESSXZ

CONFIGFILE=/groups/scicomp/jacsData/yuTest/YoshiMB/sources/refactoralignmentpipeline/systemvars.apconf
#WORKDIR=/groups/scicomp/jacsData/yuTest/YoshiMB/results
WORKDIR=/groups/scicomp/jacsData/yuTest/Tanya/results

qsub -b y -cwd -V -pe batch 8 -l mem96=true /groups/scicomp/jacsData/yuTest/YoshiMB/scripts/brainalign63x_V3.1.1.sh $CONFIGFILE $WORKDIR $SUBGECTSX $SUBJECTSXREFNO
