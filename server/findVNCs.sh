for i in 201*/*/*;
do


if [[ $i =~ "CEN" ]]
then

continue

fi

j=${i%*/*}; 
k=${j#*/*}.v3draw; 

ls $j/$k; 

done
