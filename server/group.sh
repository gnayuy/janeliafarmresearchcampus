

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

echo $i;

done
