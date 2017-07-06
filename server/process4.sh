# test larval image registration
# created by Yang Yu (yuy@janelia.hhmi.org) 04/04/2017

# To automatically generate a training dataset, we roughly align
# 500 samples to the labeled template

# test downscale with isotropic ratio 0.5

# preprocessing

CMTKDIR=/nrs/scicompsoft/yuy/Toolkits/CMTK/bin
CMTKALIGNER=${CMTKDIR}/munger

F=$1
M=$2

FBase=${F%*.nii*}
MBase=${M%*.nii*}

# downsampling

time ./nail -f imageResize -i $F -o ${FBase}ds.nii.gz -sr 0.5
time ./nail -f imageResize -i $M -o ${MBase}ds.nii.gz -sr 0.5

# gamma filtering 2.2

time ./nail -f gammaFilter -i ${FBase}ds.nii.gz -o ${FBase}dsgf2.nii.gz -gamma 2.2
time ./nail -f gammaFilter -i ${MBase}ds.nii.gz -o ${MBase}dsgf2.nii.gz -gamma 2.2

time ./nail -f gammaFilter -i ${FBase}ds.nii.gz -o ${FBase}dsgf.nii.gz -gamma 0.5
time ./nail -f gammaFilter -i ${MBase}ds.nii.gz -o ${MBase}dsgf.nii.gz -gamma 0.5

time ./nail -f imageDivide -i ${FBase}dsgf2.nii.gz -ref ${FBase}dsgf.nii.gz -o ${FBase}dsbg.nii.gz
time ./nail -f imageDivide -i ${MBase}dsgf2.nii.gz -ref ${MBase}dsgf.nii.gz -o ${MBase}dsbg.nii.gz

### coarse registration (global alignment)

Fix=${FBase}dsbg.nii.gz
Mov=${MBase}dsbg.nii.gz

# rotation estimation

echo "estimating rotation ..."

time flirt -in ${Mov} -ref ${Fix} -omat ./linear.txt -cost mutualinfo -searchrx -15 15 -searchry -15 15 -searchrz -15 15 -dof 12 -datatype char -v
time applywarp --ref=${Fix} --in=${Mov} --out=${MBase}dsbgga.nii.gz --premat=./linear.txt


# affine

echo "affine registratoin ..."

time $CMTKDIR/registration --initxlate --dofs 6,9 --auto-multi-levels 4 -o ./affineds.xform ${Fix} ${MBase}dsbgga.nii.gz

### refine registration (local alignment)

# FFD

#$CMTKALIGNER -v -b $CMTKDIR -a -w -r 0102030405 -X 26 -C 8 -G 80 -R 4 -A '--accuracy 0.8' -W '--accuracy 2' -T 16 -s ${FBase}dsgf_rs_c0.nii images

echo "FFD registration ..."

time $CMTKDIR/warp -o ffd40.xform --grid-spacing 40 --exploration 26 --coarsest 3 --accuracy 0.8 --refine 3 --energy-weight 1e-1 -v --initial affineds.xform ${Fix} ${MBase}dsbgga.nii.gz

echo "transform ..."

time $CMTKDIR/reformatx -o ${MBase}dsbgla.nii.gz --floating ${MBase}dsbgga.nii.gz ${Fix} ffd40.xform


