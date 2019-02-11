#!/bin/bash

function usage {
	echo "afniscript.sh <file>"
}

if [[ ${#} == 0 ]] ; then
	usage
	exit 1
else
	filen=${1}
fi

# Get the directory and basename
dirn=$(dirname  ${filen})
basn=$(basename ${filen} .nii.gz)

idnum=$(echo ${dirn} | grep -o 'RC....')

echo "Working on ID ${idnum} ${basn} in ${dirn}"

# Won't overwrite extant scripts; if you change something in afni_proc.py and
# want to regenerate, you will have to remove old scripts manually

afni_proc.py															\
	-subj_id	${idnum}												\
	-dsets		${filen}												\
	-out_dir	${dirn}/${idnum}.${basn}.results						\
	-script		${dirn}/proc.${idnum}.${basn}							\
	-copy_anat	${dirn}/T1.nii.gz										\
	-blocks		despike tshift align tlrc volreg blur mask regress		\
	-align_opts_aea														\
				-cost	lpc+ZZ											\
	-tlrc_base			MNI152_T1_2009c+tlrc							\
	-tlrc_NL_warp														\
	-volreg_warp_dxyz	2												\
	-volreg_align_e2a													\
	-volreg_tlrc_warp													\
	-volreg_align_to	MIN_OUTLIER										\
	-regress_anaticor													\
	-regress_bandpass	0.0	0.2											\
	-regress_est_blur_epits												\
	-regress_est_blur_errts

# I don't think we want to censor anything right now:
#  -regress_censor_motion 0.35         \
#  -regress_censor_outliers 0.1           \
#  -regress_apply_mot_types demean deriv        \
