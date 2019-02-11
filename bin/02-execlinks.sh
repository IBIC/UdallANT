#!/bin/bash

subjects=/mnt/praxic/udallpilot/subjects
cd ${subjects}

for i in $(find -name "00-proc.sh") ; do

	cd ${subjects}/$(dirname $i)
	./00-proc.sh

done