# UdallANT

This project archives the scripts necessary to replicate the analyses as
uploaded to OpenNeuro project "ANT: Healthy aging and Parkinson's disease," ver.
2.0.3.

Link: https://openneuro.org/datasets/ds001907/versions/2.0.3

DOI:  10.18112/openneuro.ds001907.v2.0.3

The processing is very simple:

`bin/subject-processing/00-invokeall.sh` (a) converts scanner format to Nifti;
	(b) skullstrips and defaces anatomical images; and (c) runs afni_proc.py
	to preprocess data.

`bin/subject-processsing/01-organizeBIDS.sh` converts from our in-house
	organization to the Brain Imaging Data Structure format for upload to
	OpenNeuro.

`bin/demo-final.R` shows how demographic information was converted from
	supplied spreadsheets (not included) to CSV for sharing.

See Data Note:
	[pending]

These scripts have also been archived on Zenodo:
	[pending]

See papers using this data:

Boord, P., Madhyastha, T. M., Askren, M. K., & Grabowski, T. J. (2017).
	Executive attention networks show altered relationship with default mode
	network in PD. NeuroImage: Clinical, 13, 1–8.
	https://doi.org/10.1016/j.nicl.2016.11.004

Madhyastha, T. M., Askren, M. K., Boord, P., & Grabowski, T. J. (2015).
	Dynamic Connectivity at Rest Predicts Attention Task Performance. Brain
	Connectivity, 5(1), 45–59. https://doi.org/10.1089/brain.2014.0248
