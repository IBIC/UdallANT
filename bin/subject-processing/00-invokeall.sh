#!/bin/bash

# Get the subject ID
subject=${1}

# From a subject directory with convert NIFTIs in their respective ANT-?
# directories:

# Skullstrip and deface for upload
bet T1.nii.gz T1_brain.nii.gz
pydeface T1.nii.gz

for i in A B C D E F ; do

	## fMRI processing

	# This generates the tcsh script
	./afniscript.sh ${subject} ANT_${i}/ANT_${i}.nii.gz

	# Do the processing
	./proc.${subject}.ANT_${i}

	# Convert AFNI result to NIFTI for BIDS
	3dAFNItoNIFTI \
		-prefix ${subject}-ANT_${i}-final.nii.gz \
		${subject}.ANT_${i}.results/errts.${subject}.anaticor+tlrc

	## Behavioral procesing

	task_file=${func_dir}/${dest_pfx}${index}_events.tsv


done