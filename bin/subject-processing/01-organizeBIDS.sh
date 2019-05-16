#!/bin/bash

# From the top-level, where the processed files are in:
#	subjects/RC4[12]??/session[12]
# and the to-be-created BIDSs directory is BIDS/

project=/mnt/praxic/udallpilot
cd ${project}
subjects=$(find subjects/ -mindepth 1 -maxdepth 1 -name "RC4*" -type d \
			-exec basename {} \;)

# This command updates destination files and doesn't error if the source files
# don't exist.
# COPY='rsync --progress --ignore-missing-args --update -raz'

# Error message if input file doesn't exist; but silently only copy if `to` is
# newr than `from`.
function COPY {

	from=${1}
	to=${2}

	if [ -e ${from} ] ; then

		if [ ${from} -nt ${to} ] ; then

			cp ${from} ${to}
			echo "${from} -> ${to}"

		fi

	else
		echo "${from} missing"
	fi

}

function task_tsv {

	# Argument to function
	directory=${1}

	stims="CenterCue SpatialCue NoCue Incongruent Congruent"
	errs="Cue Target"

	# Stimulus files (same suffix)
	for stim in ${stims} ; do

		filen=${directory}/${stim}Correct.txt

		if [ -e ${filen} ] ; then
			cat ${filen} | awk -v type="${stim}" -F"\t" \
								'{print $1"\t"$2"\t"type}'
		else
			echo ${filen} is missing
		fi

	done

	# Error file (same suffix, but different from above)
	for err in ${errs} ; do

		filen=${directory}/${err}Error.txt

		if [ -e ${filen} ] ; then
			cat ${filen} | awk -v type="${err}Err" -F"\t" \
								'{print $1"\t"$2"\t"type}'
		fi

	done

}

function alpha2num {

	alpha=${1}
	case ${alpha} in
		"A") num=1 ;;
		"B") num=2 ;;
		"C") num=3 ;;
		"D") num=4 ;;
		"E") num=5 ;;
		"F") num=6 ;;
		*) exit 1 ;;
	esac

	echo ${num}

}

#
# Setup
#

mkdir -p BIDS

echo "WARNING: This script doesn't take keyboard interrupts very well!"
echo "Setting up ..."

for s in ${subjects} ; do

	mkdir -p BIDS/sub-${s}/ses-{1,2}/anat

done

echo "Writing data description json file"

# Will need to be updated with DatasetDOI, open neuro accession number, etc.
# Linking just to DOI (or other webpage) is commonly done for these
cat > BIDS/dataset_description.json <<-EOF
{
  "Name": "Udall Pilot (ANT)",
  "BIDSVersion": "1.0.1",
  "License": "CC0",
  "Authors": ["Trevor K. M. Day", "Tara M. Madyastha", "Peter Boord",
  				"Mary K. Askren", "Thomas J. Montine",
  				"Thomas J. Grabowski"],
  "HowToAcknowledge": "Please cite the data paper: ---",
  "Funding": ["NIH RC4 NS073008", "NIH P50 NS062684",
  				"Ruth L. Kirschstein National Research Service Award T32AG0000258"],
  "ReferencesAndLinks": ["doi.org/10.1016/j.nicl.2016.11.004",
  						 "doi.org/10.1089/brain.2014.0248"],
  "DatasetDOI": ""
}
EOF

cat > BIDS/README <<-EOF
	This project contains 46 subjects at two sessions each. At each sessions,
	subjects acquired 6 repetitions of the ANT task (1-6). Scans are the same
	by number across subjects, although they were presented in varying orders.
	Task timing and anatomical scans by session are also included.

	The derivatives/ directory contains AFNI-preprocessed scans as well as
	anatomical scans skullstripped before defacing. The derivatives have been
	slice-timing corrected already, so 0s are provided for that field.

	At the top level is complete demographic information, the AFNI script for
	preprocessing.

	Exceptions
	----------
	One subject (RC4206) had an acquisition error during their second session
	structural scan. Correspondingly, their structural scan from their first
	session has been copied for their second session to create a valid
	BIDS directory.

EOF

echo "afniscript.sh"    >  BIDS/.bidsignore
echo "demographics.csv" >> BIDS/.bidsignore

echo "Writing task description json files"

# The slice timing is the onset for each slice (asc.) starting at 0. There are
# 43 slices (dim3) over 2.4 sec for this acquisition. Start at 0, so decrement
# from loop max. Here we round to two places after the decimal:
stime=$(R --slave -e \
			'cat(paste0(round(2.4 * (0:42) / 43, 2), collapse = ", "))')

cat > BIDS/task-ANT_bold.json <<-EOF
	{
		"TaskName": "ANT",
		"SliceTiming": [${stime}]
	}
EOF

ten0s="0,0,0,0,0,0,0,0,0,0"
cat > BIDS/derivatives/task-ANT_bold.json <<-EOF
	{
		"TaskName": "ANT",
		"SliceTiming": [${ten0s},${ten0s},${ten0s},${ten0s},0,0,0]
	}
EOF

echo "Copying anatomical NIFTI/json files ..."

for s in ${subjects} ; do

	for i in 1 2 ; do

		anatname=sub-${s}_ses-${i}_T1w

		COPY \
			subjects/${s}/session${i}/T1_defaced.nii.gz \
			BIDS/sub-${s}/ses-${i}/anat/${anatname}.nii.gz

		COPY \
			subjects/${s}/session${i}/T1.json \
			BIDS/sub-${s}/ses-${i}/anat/${anatname}.json

		# Copy the skull-strip to derivatives/ as a backup for the defaced T1
		deriv_dir=BIDS/derivatives/sub-${s}/ses-${i}/anat
		mkdir -p ${deriv_dir}
		COPY \
			subjects/${s}/session${i}/T1_brain.nii.gz \
			${deriv_dir}/${anatname}brain.nii.gz

	done

done

# Newline after null-terminated status
echo

echo "Copying ANT A-F raw fMRI NIFTI/json files and creating corresponding" \
		"task files ..."

for s in ${subjects} ; do

	for i in 1 2 ; do

		# echo -n "${i} "

		func_dir=BIDS/sub-${s}/ses-${i}/func/
		mkdir -p ${func_dir}

		for j in A B C D E F ; do

			#
			# Raw
			#

			# A-F to 1-6
			index=$(alpha2num ${j})

			# Prefixes for raw/processed
			raw_source_pfx=subjects/${s}/session${i}/ANT_${j}
			prc_source=subjects/${s}/session${i}/${s}-ANT_${j}-final.nii.gz

			# What to name them in the BIDS structure
			dest_pfx=sub-${s}_ses-${i}_task-ANT_run-

			# Copy the data files and jsons
			COPY \
				${raw_source_pfx}/ANT_${j}.nii.gz \
				${func_dir}/${dest_pfx}${index}_bold.nii.gz

			COPY \
				${raw_source_pfx}/ANT_${j}.json \
				${func_dir}/${dest_pfx}${index}_bold.json

			# Construct task tab-sep file
			task_file=${func_dir}/${dest_pfx}${index}_events.tsv
			if [ ! -e ${task_file} ] ; then

				tempfile=$(mktemp /tmp/tasktsv.XXXXX)

				task_tsv ${project}/${raw_source_pfx} > ${tempfile}

				echo -e "onset\tduration\ttrial_type" > ${task_file} # clear
				sort -g ${tempfile} >> ${task_file}

			fi

			#
			# Derivatives
			#

			# deriv_dir=BIDS/derivatives/sub-${s}/ses-${i}/func
			# mkdir -p ${deriv_dir}
			# COPY \
			# 	${prc_source} \
			# 	${deriv_dir}/${dest_pfx}${index}_bold.nii.gz

		done

	done

done

echo

#
# Validation
#

echo "Validating ..."

# Validate using npm BIDS validator
# Project: https://github.com/bids-standard/bids-validator

# Path to local install
BV=${project}/node_modules/bids-validator/bin/bids-validator

if [ ! -e ${BV} ] ; then
	echo "Can't find BIDS validator at ${BV}"
	exit 1
fi

${BV} --verbose BIDS