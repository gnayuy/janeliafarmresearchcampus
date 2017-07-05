# preprocess


for i in /groups/scicomp/jacsData/yuTest/markReconstruction/slices/s*.tif; do ./vaa3d -cmd image-loader -convert $i ${i%*.tif}.v3draw; done

for i in /groups/scicomp/jacsData/yuTest/markReconstruction/slices/s*.v3draw; do ./vaa3d -x ireg -f yflip -i $i -o ${i%*.v3draw}_yflip.v3draw; done

for i in /groups/scicomp/jacsData/yuTest/markReconstruction/slices/s*_yflip.v3draw; do ./vaa3d -x ireg -f iwarp2 -o ${i%*.v3draw}_rec.v3draw -p "#s ${i} #a /groups/scicomp/jacsData/yuTest/templates/target/initAffine.txt #dx 9216 #dy 6400 #dz 1"; done

for i in /groups/scicomp/jacsData/yuTest/markReconstruction/slices/s*_yflip_rec.v3draw; do ./vaa3d -x ireg -f splitColorChannels -i $i; done

for i in /groups/scicomp/jacsData/yuTest/markReconstruction/slices/s*_yflip_rec_c1.v3draw; do ./vaa3d -x ireg -f NiftiImageConverter -i $i; done


FIX=71
MOV=72

time ../ANTS/ANTS 2 -m MI[/groups/scicomp/jacsData/yuTest/markReconstruction/green/s${FIX}_yflip_rec_c1_warped.nii,/groups/scicomp/jacsData/yuTest/markReconstruction/green/s${MOV}_yflip_rec_c1_c0.nii, 1, 32 ] -o /groups/scicomp/jacsData/yuTest/markReconstruction/green/test/mi${FIX}${MOV} -i 0 --number-of-affine-iterations 10000x10000x10000x10000 --rigid-affine true

time ../ANTS/WarpImageMultiTransform 2 /groups/scicomp/jacsData/yuTest/markReconstruction/green/s${MOV}_yflip_rec_c1_c0.nii /groups/scicomp/jacsData/yuTest/markReconstruction/green/s${MOV}_yflip_rec_c1_warped.nii -R /groups/scicomp/jacsData/yuTest/markReconstruction/green/s71_yflip_rec_c1_c0.nii /groups/scicomp/jacsData/yuTest/markReconstruction/green/test/mi${FIX}${MOV}Affine.txt




SUB=/groups/scicomp/jacsData/yuTest/markReconstruction/green/s${MOV}_yflip_rec_c1_c0.nii
SUBWARP=/groups/scicomp/jacsData/yuTest/markReconstruction/green/s${MOV}_yflip_rec_c1_warped.nii
TAR=/groups/scicomp/jacsData/yuTest/markReconstruction/green/s71_yflip_rec_c1_c0.nii

time ../ANTS/WarpImageMultiTransform 2 $SUB $SUBWARP -R $TAR /groups/scicomp/jacsData/yuTest/markReconstruction/green/test/mi${FIX}${MOV}Affine.txt



