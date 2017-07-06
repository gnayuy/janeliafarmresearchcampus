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

# resize
time ./nail -f imageResize -i $F -o ${FBase}rs.nii -sx 1280 -sy 1024 -sz 512
time ./nail -f imageResize -i $M -o ${MBase}rs.nii -sx 1280 -sy 1024 -sz 512

./vaa3d -x ireg -f NiftiImageConverter -i ${FBase}rs.nii -o ${FBase}rs.v3draw -p "#b 1"
./vaa3d -x ireg -f NiftiImageConverter -i ${MBase}rs.nii -o ${MBase}rs.v3draw -p "#b 1"

./vaa3d -x ireg -f genVOIs -p "#s ${MBase}rs.v3draw #t ${FBase}rs.v3draw"

./vaa3d -x ireg -f NiftiImageConverter -i ${FBase}rs_rs.v3draw
./vaa3d -x ireg -f NiftiImageConverter -i ${MBase}rs_rs.v3draw

time ./nail -f imageResize -i ${FBase}rs_rs_c0.nii -o ${FBase}ds.nii.gz -sr 0.5
time ./nail -f imageResize -i ${MBase}rs_rs_c0.nii -o ${MBase}ds.nii.gz -sr 0.5

# gamma filtering 2.2

time ./nail -f gammaFilter -i ${FBase}ds.nii.gz -o ${FBase}dsgf.nii.gz -gamma 2.2
time ./nail -f gammaFilter -i ${MBase}ds.nii.gz -o ${MBase}dsgf.nii.gz -gamma 2.2

### coarse registration (global alignment)

# rotation estimation

echo "estimating rotation ..."

time flirt -in ${MBase}dsgf.nii.gz -ref ${FBase}dsgf.nii.gz -omat ./linear.txt -cost mutualinfo -searchrx -15 15 -searchry -15 15 -searchrz -15 15 -dof 12 -datatype char -v
time applywarp --ref=${FBase}dsgf.nii.gz --in=${MBase}dsgf.nii.gz --out=${MBase}dsgfga.nii.gz --premat=./linear.txt

# affine

echo "affine registratoin ..."

time $CMTKDIR/registration --initxlate --dofs 6,9 --auto-multi-levels 4 -o ./affineds.xform ${FBase}dsgf.nii.gz ${MBase}dsgfga.nii.gz

### refine registration (local alignment)

# FFD

#$CMTKALIGNER -v -b $CMTKDIR -a -w -r 0102030405 -X 26 -C 8 -G 80 -R 4 -A '--accuracy 0.8' -W '--accuracy 2' -T 16 -s ${FBase}dsgf_rs_c0.nii images

echo "FFD registration ..."

time $CMTKDIR/warp -o ffd40.xform --grid-spacing 40 --exploration 20 --coarsest 4 --accuracy 2 --refine 4 --energy-weight 1e-1 -v --initial affineds.xform ${FBase}dsgf.nii.gz ${MBase}dsgfga.nii.gz

echo "transform ..."

time $CMTKDIR/reformatx -o ${MBase}dsgfla.nii.gz --floating ${MBase}dsgfga.nii.gz ${FBase}dsgf.nii.gz ffd40.xform


