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

# gamma filtering (enhance the background)

time ./nail -f gammaFilter -i ${FBase}ds.nii.gz -o ${FBase}dsbg.nii.gz -gamma 2.2
time ./nail -f gammaFilter -i ${MBase}ds.nii.gz -o ${MBase}dsbg.nii.gz -gamma 2.2

### coarse registration (global alignment)

Fix=${FBase}dsbg.nii.gz
Mov=${MBase}dsbg.nii.gz

# rotation estimation

echo "estimating rotation ..."

time flirt -in ${Mov} -ref ${Fix} -omat ./linear.txt -cost mutualinfo -searchrx -15 15 -searchry -15 15 -searchrz -15 15 -dof 12 -datatype char -v
time applywarp --ref=${Fix} --in=${Mov} --out=${MBase}dsbgga.nii.gz --premat=./linear.txt

#time ./nail -f convert2byte -i ${MBase}dsbgga.nii.gz -o ${MBase}dsbgga8.nii.gz

# affine

echo "affine registratoin ..."

#time ./ANTS 3 -m  MI[ $Fix, ${MBase}dsbgga8.nii.gz, 1, 32] -o ./mi -i 0 --number-of-affine-iterations 10000x10000x10000

### refine registration (local alignment)

# diffeomorphism

echo "SyN registration ..."

time ./ANTS 3 -m CC[ $Fix, ${MBase}dsbgga.nii.gz, 1, 8] -t SyN[0.25] -r Gauss[3, 0.25] -i 100x70x50x0x0 -o ./cc -a ./initAffine.txt --continue-affine false

echo "transform ..."

time ./WarpImageMultiTransform 3 ${MBase}dsbgga8.nii.gz ${MBase}dsbgla.nii.gz -R $Fix ccWarp.nii.gz ccAffine.txt --use-BSpline



