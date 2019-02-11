#!/bin/bash

# Extract PAR/RECs for conversion if the directory doesn't exist
if [ ! -d parrecs ] ; then 

	tar -xvjf parrecs.tar.bz2

fi

# Convert the PAR/RECs to NIFTI for: ANT_?, DTI, MPRAGE, RS

# ANT
for x in A B C D E F ; do

	if [ ! -e ANT_${x}.nii.gz ] ; then

		dcm2niix_afni 					\
			-i Y -p Y 					\
			-f ANT_${x} 				\
			-z Y 						\
			-o . 						\
			$(find parrecs/ -name "*_ANT_${x}_*.PAR")

	fi

done 

# T1
if [ ! -e T1.nii.gz ] ; then

	dcm2niix_afni 					\
		-i Y -p Y 					\
		-f T1		 				\
		-z Y 						\
		-o . 						\
		$(find parrecs/ -name "*MPRAGE*.PAR")

fi

# Resting state
if [ ! -e rest.nii.gz ] ; then

	dcm2niix_afni 					\
		-i Y -p Y 					\
		-f rest		 				\
		-z Y 						\
		-o . 						\
		$(find parrecs/ -name "*Rest*.PAR")

fi
