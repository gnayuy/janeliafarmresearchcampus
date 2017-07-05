time for i in braincandidates/byte/ds/*; do j=rc/stitch${i#*stitch*};  ./vaa3d -x ireg -f resizeImage -o ${j%*.v3draw}_rc.v3draw -p "#s $i #t recenteredimage.v3draw"; done
