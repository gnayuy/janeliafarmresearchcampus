cntdebug=0; 

for i in flypilot863stack/section*/filelist.txt
do

cnt=1;
cntdebug=$((cntdebug+1));
# echo $cntdebug

while read line 
do 

cnt=$((cnt+1)); 

if [[ $line =~ "*" ]]
then 
echo "$i $line";
fi

done < $i # while line

if((cnt<10))
then
echo "wrong $i";
fi

done # for i

