while read line
do

str=($line)

T=${str[0]}
S=${str[2]}

echo "cp -r $S $T"

cp -r $S $T

done < fileList.txt
