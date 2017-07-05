#!/bin/bash

#/groups/scicomp/jacsData/yuTest/stitchPipeline/data/628/
#SOURCEFOLDERS="/groups/scicomp/jacsData/yuTest/YoshiMB/sources/NFBSX/*"
#SOURCEFOLDERS="/home/yuy/work/stitching_result/yuchun/Test/*"
#SOURCEFOLDERS="/groups/scicomp/jacsData/yuTest/YoshiMB/sources/LeeLab/SX/*"
#SOURCEFOLDERS="/home/yuy/work/BrainAlignerTest/testsamples/*"
#SOURCEFOLDERS="/groups/scicomp/jacsData/yuTest/YoshiMB/sources/FFBSX/*"
#SOURCEFOLDERS=/groups/scicomp/jacsData/yuTest/YoshiMB/sources/splitPolarity/WSX
#SOURCEFOLDERS=/home/yuy/work/BrainAlignerTest/bug/merged
#SOURCEFOLDERS=/groups/scicomp/jacsData/yuTest/YoshiMB/sources/splitGALPolarity/SX/*/stitch
#SOURCEFOLDERS=/groups/scicomp/jacsData/yuTest/YoshiMB/sources/standardbrainDPX/candidates/ex6/tmp
SOURCEFOLDERS=/groups/scicomp/jacsData/yuTest/YoshiMB/sources/standardbrainDPX/tmp/*

for Tiles in $SOURCEFOLDERS
do

#qsub -b y -cwd -V -pe batch 8 -l mem96=true 
#qsub -b y -cwd -V -l excl=true 

#echo $Tiles

qsub -b y -cwd -V -pe batch 8 -l mem96=true /groups/scicomp/jacsData/yuTest/YoshiMB/sources/standardbrainDPX/runOnGrid.sh $Tiles

done



