





while read line; 
do 

#echo $line; 

str=($line);

num=`echo ${str[1]} | bc`

if(( $num<129 ))
then 
echo "$line"
fi

done < missingdebug.txt
