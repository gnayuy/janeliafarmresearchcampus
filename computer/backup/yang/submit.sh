
SSEC=$1
ESEC=$2

DIR=$3

for((j=$SSEC; j<$ESEC; j++)); do sh render.sh $PWD/$DIR/section$j $PWD/$DIR/section$j 1.0; done

