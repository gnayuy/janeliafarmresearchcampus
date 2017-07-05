#!/bin/bash

TMPLDIR=/groups/scicomp/jacsData/yuTest/templates/target
TOOLDIR=/groups/scicomp/jacsData/yuTest/YoshiMB/toolkits
CONFIGFILE=/groups/scicomp/jacsData/yuTest/systemvars.apconf
WORKDIR=/groups/scicomp/jacsData/yuTest/YoshiMB/sources/Mounting/workdir

# 20x subject

FOLDER=/groups/scicomp/jacsData/yuTest/YoshiMB/sources/Mounting/DPXPBS/case3

count=-1;
SUBREF=1

data=301;

for i in $FOLDER/*
do 

count=$((count+1));
if [ `echo "$count % 2" | bc` -eq 0 ]
then

flybrain=$i;

else
flyvnc=$i;

WD=$WORKDIR/data$((data++))
if [ ! -d $WD ]; then 
mkdir $WD
fi

qsub -b y -cwd -V -pe batch 4 -l mem96=true /groups/scicomp/jacsData/yuTest/YoshiMB/sources/Mounting/script/flyalign20x_INT.sh $CONFIGFILE $TMPLDIR $TOOLDIR $WD $flybrain $flyvnc $SUBREF 0.52 0.52 1.0 "DPXPBS"

fi


done
 

