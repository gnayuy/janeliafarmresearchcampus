for i in json0.1/*.json
do

#sed -i "s/\"scale\"\:\ 0.01/\"scale\"\:\ 0.1/g" $i

while read line
do

if [[ $line =~ "scale" ]]
then

echo $line

fi

done < $i

done
