for i in /home/yuy/work/data/markCembrowski/wholeBrain/sections/1327784_*_WholeSlide_section_*_ref.tif; do in=${i%*_ref.tif}; j=${i%*sections*}recenter/; k=${i#*sections/*}; out=$j${k%*_ref.tif};  ./ireg -f resizeImage -i $in -o $out -p "-r 4"; done

