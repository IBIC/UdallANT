#!/bin/bash

cd /mnt/praxic/udallpilot/subjects

for i in RC4* ; do

	cd ${i}

	for j in 1 2 ; do

		cd session${j}

		ln -s /mnt/praxic/udallpilot/bin/subject-01-extract.sh 01-extract.sh
		ln -s /mnt/praxic/udallpilot/bin/subject-02-makeafniscript.sh \
				02-afniscript.sh

		ln -s /mnt/praxic/udallpilot/lib/Makefile .

		cd ..

	done

	cd ..

done