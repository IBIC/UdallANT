#!/bin/bash

################################################################################
# Convert DICOMS and PAR/RECs to NIFTI
################################################################################

# Extract DICOMS and PAR/RECs for conversion if the directory doesn't exist
if [ ! -d dicoms ]  ; then tar -xvjf dicoms.tar.bz2  ; fi
if [ ! -d parrecs ] ; then tar -xvjf parrecs.tar.bz2 ; fi

# Convert dicoms in nifti/ folder
# '-i y' skips "small images", '-z y' gzips the result.
echo "Converting all DICOMs"
rm -rf nifti
mkdir -p nifti
dcm2niix_afni 	\
	-i y -z y	\
	-f "%d" 	\
	-o nifti/	\
	dicoms

# Now convert all of the PAR/RECs (have to be explicit with which ANT)
rm -rf nifti_parrecs
mkdir -p nifti_parrecs
for i in A B C D E F ; do

	echo "Converting ${i} PAR/REC"
	dcm2niix_afni 			\
		-i y -z y			\
		-f ANT_${i}			\
		-o nifti_parrecs/	\
		parrecs/*_WIP_ANT_${i}_SENSE_*.PAR

done

for i in A B C D E F ; do

	# Try DICOMs (this command doesn't error if nifti/ANT_${i} is missing)
	rsync --ignore-missing-args nifti/ANT_${i}.nii.gz .

	# This tries to copy from PAR/RECs, but doesn't overwrite if the DICOMs copy
	# was successful
	cp --no-clobber nifti_parrecs/ANT_${i}.nii.gz .

done

# Do the same copy trick with the T1
rsync --ignore-missing-args nifti/MPRAGE_S2.nii.gz 			T1.nii.gz

rsync --ignore-missing-args --ignore-existing \
				 			nifti_parrecs/MPRAGE_S2.nii.gz	T1.nii.gz
