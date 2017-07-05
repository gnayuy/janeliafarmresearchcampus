# convertam2tif.sh developed by Yang Yu (yuy@janelia.hhmi.org)
#
### convert .am to .tif 
#

#for i in ../LexAp65/*.am; do j=${i%*/*}; j=${i#*${j}/*}; k=../LexAp65_JFRC2014/$j; k=${k%*.*}.tif; sh convertam2tif.sh $i $k;done

is_file_exist()
{
    local f="$1"
    [[ -f "$f" ]] && return 0 || return 1
}

### tools
LOCI=/nobackup/scicompsoft/yuTest/dicksonlab/warpVienna2JFRC2014/loci_tools.jar

### input and output
IN=$1
OUT=$2

### processes

# 1. convert .am to .tif

if ( is_file_exist "$OUT" )
then
echo " OUT: $OUT exists"
else
#---exe---#
java -cp $LOCI loci.formats.tools.ImageConverter $IN $OUT
fi

