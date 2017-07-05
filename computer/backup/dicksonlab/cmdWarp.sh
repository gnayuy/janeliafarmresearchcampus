# cmdWarp.sh developed by Yang Yu (yuy@janelia.hhmi.org)
#
### warp Vienna aligned image to JFRC2014 
#

# sh /nobackup/scicompsoft/yuTest/dicksonlab/warpVienna2JFRC2014/cmdWarp.sh /nobackup/scicompsoft/yuTest/dicksonlab/LexAp65 /nobackup/scicompsoft/yuTest/dicksonlab/LexAp65_JFRC2014

is_file_exist()
{
    local f="$1"
    [[ -f "$f" ]] && return 0 || return 1
}

### input and output
IN=$1
OUT=$2

### processes

for i in $IN/*.am
do

j=${i%*/*}
k=${i#*${j}/*}

l=${k%*.am}

tmpdir=$OUT/$l

mkdir $tmpdir

output=$OUT/$k".tif"

#echo "time sh warpVienna.sh $i $output $tmpdir"
#time sh /nobackup/scicompsoft/yuTest/dicksonlab/warpVienna2JFRC2014/warpVienna.sh $i $output $tmpdir

if ( is_file_exist "$output" )
then
echo " output: $output exists"
else
#---exe---#
qsub -A dicksonb -b y -cwd -V -pe batch 16 /nobackup/scicompsoft/yuTest/dicksonlab/warpVienna2JFRC2014/warpVienna.sh $i $output $tmpdir
fi

done

