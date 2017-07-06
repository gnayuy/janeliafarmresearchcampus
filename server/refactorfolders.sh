dir=$1

while read line
do

folder=${line%*/*}

echo $folder

subdir=$dir/$folder
mkdir $subdir

filename=${line#*/*}
filename=${filename%*.v3draw}

#echo $filename



for i in $dir/*;
do


if [[ $i =~ $filename ]]
then

echo $i;

mv $i $subdir

fi



done


echo ""







done < files.txt