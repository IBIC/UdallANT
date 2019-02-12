#!/bin/bash

cd /mnt/praxic/udallpilot/subjects

for i in RC4* ; do

	cd ${i}

	for j in 1 2 ; do

		cd session${j} 

		ln -s /mnt/praxic/udallpilot/bin/00-extract.sh .
		ln -s /mnt/praxic/udallpilot/lib/Makefile .

		cd ..

	done

	cd ..

done