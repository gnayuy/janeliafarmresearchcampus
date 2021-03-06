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

WD=$WORKDIR/data$((data++))/FinalOutputs
if [ ! -d $WD ]; then 
mkdir $WD
fi

str=${flybrain#*case3/*}
str=${str%*.lsm}
path=${WD%*sources/*}
ln -s $WD  ${path}"Feb2013/"$str

fi


done
 

