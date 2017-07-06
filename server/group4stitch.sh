

for i in */*
do


# for merge
#mkdir ${i%*_*};
#mv ${i%*_*}* ${i%*_*}

# for VNC stitching
if [[ $i =~ "CEN" ]]
then

continue

fi

#k=${i%*_T*_*}_;
#j=${i#$k};
#l=_${j#*_*};

#m=${j%$l}

#f=$k$m;

#mkdir $f
#mv $f* $f

for j in $i/*
do

if [[ $j =~ "CEN" ]]
then

continue

fi


echo $j;


#cd $j
#mv *.v3draw ..


mv $j/*.v3draw $j/../

#rm $j/../*.v3draw


done


done
