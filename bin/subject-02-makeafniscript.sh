#!/bin/bash

# Identify the ID using the directory name
idnum=$(pwd | grep -o "RC....")

# This command won't overwrite extant scripts; if you change something in
# afni_proc.py and want to regenerate, you will have to remove old scripts
# manually.

for i in A B C D E F ; do

	echo "Creating script for ANT_${i}"

	afni_proc.py															\
		-subj_id	${idnum}												\
		-dsets		ANT_${i}.nii.gz											\
		-out_dir	${idnum}.ANT_${i}.results								\
		-script		proc.${idnum}.ANT_${i}									\
		-copy_anat	T1.nii.gz												\
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

done

# To run any script, just execute ./proc.${idnum}.ANT_?