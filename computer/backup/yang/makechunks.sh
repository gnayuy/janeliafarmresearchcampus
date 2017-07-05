#!/bin/bash

# developed by Yang Yu (yuy@janelia.hhmi.org), 10/16/2014

# usage: sh makechunks.sh layer_500.json 4 8 flypilot863_layer500

LAYERJSON=$1
W=$2
H=$3
OUTPUT=$4

while read line
do

if [[ $line =~ "width" ]]
then

str=($line)
width=${str[1]%,}
width=${width#0}

elif [[ $line =~ "height" ]]
then

str=($line)
height=${str[1]%,}
height=${height#0}

elif [[ $line =~ "\"x\":" ]]
then

str=($line)
ox=${str[1]%,}
printf -v x '%.6f' "$ox"
#x=${x/[eE]+*/*10^}

elif [[ $line =~ "\"y\":" ]]
then

str=($line)
oy=${str[1]%,}
printf -v y '%.6f' "$oy"
#y=${y/[eE]+*/*10^}

fi

done < $LAYERJSON

x=$(echo $x | bc)
y=$(echo $y | bc)

echo "$width $height $x $y"
#printf -v y '%e' $y
#echo $y

DW=$((width/W))
DH=$((height/H))

for((iw=0; iw<$W; iw++))
do

if((iw==$W-1))
then
NW=$(( width-DW*(W-1) ))
else
NW=$DW
fi

nx=`expr $x+$iw*$DW | bc -l`
printf -v snx '%e' $nx

for((ih=0; ih<$H; ih++))
do

out=$OUTPUT"_x"$iw"_y"$ih".json"

if((ih==$H-1))
then
NH=$(( height-DH*(H-1) ))
else
NH=$DH
fi

ny=`expr $y+$ih*$DH | bc -l`
printf -v sny '%e' $ny

#echo $NW $iw $snx $NH $ih $sny $out 


#
cp $LAYERJSON $out
sed -i "s/\"width\"\:\ $width/\"width\"\:\ $NW/g" $out
sed -i "s/\"height\"\:\ $height/\"height\"\:\ $NH/g" $out
sed -i "s/\"x\"\:\ $ox/\"x\"\:\ $snx/g" $out
sed -i "s/\"y\"\:\ $oy/\"y\"\:\ $sny/g" $out
sed -i "s/\"scale\"\:\ 0.01/\"scale\"\:\ 1.0/g" $out

done #ih

done #iw



