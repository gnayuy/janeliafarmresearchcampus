#!/bin/bash

TMPLDIR=/groups/scicomp/jacsData/yuTest/templates/target
TOOLDIR=/groups/scicomp/jacsData/yuTest/YoshiMB/toolkits
CONFIGFILE=/groups/scicomp/jacsData/yuTest/systemvars.apconf
WORKDIR=/groups/scicomp/jacsData/yuTest/YoshiMB/sources/Mounting/workdir

# 20x subject

FOLDER=/groups/scicomp/jacsData/yuTest/YoshiMB/sources/Mounting/Error/20x

SUBREF=1

data=1;

for i in $FOLDER/*
do 


flybrain=$i;

WD=$WORKDIR/data$((data++))
if [ ! -d $WD ]; then 
mkdir $WD
fi

qsub -b y -cwd -V -pe batch 4 -l mem96=true /groups/scicomp/jacsData/yuTest/YoshiMB/sources/Mounting/script/flyalign20x_INT_BrainOnly.sh $CONFIGFILE $TMPLDIR $TOOLDIR $WD $flybrain $SUBREF 0.46 0.46 1.0 "DPXEthanol"


done
 

