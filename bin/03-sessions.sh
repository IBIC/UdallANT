#!/bin/bash

cd /mnt/praxic/udallpilot/subjects

mkdir -p session{1,2}

for i in RC4* ; do

	ln -s /mnt/praxic/udallpilot/subjects/${i}/session1 session1/${i}
	ln -s /mnt/praxic/udallpilot/subjects/${i}/session2 session2/${i}

done