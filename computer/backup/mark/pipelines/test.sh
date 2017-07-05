./ireg -f resizeImage -i /home/yuy/work/data/markCembrowski/wholeBrain/sections/1327784_11_WholeSlide_section_1 -o ./test -p "-r 4"


n=0;for i in /groups/scicomp/jacsData/yuTest/markReconstruction/MouseBrain1335038/resizera/*; do n=$((n+1)); fn=${i#*resizera/*}; echo $fn ${i%*resizera*}/temp/section${n}.tif; done

n=0;for i in /groups/scicomp/jacsData/yuTest/markReconstruction/MouseBrain1335038/resizera/*; do n=$((n+1)); fn=${i#*resizera/*}; ln -s $i ${i%*resizera*}/temp/section${n}.tif; done


