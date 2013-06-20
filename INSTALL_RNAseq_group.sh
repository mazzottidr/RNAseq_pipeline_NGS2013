#!/bin/bash

#This script install all required software to run the RNAseq Pipeline

#Usage: bash INSTALL_RNAseq_group.sh

#FastQc
echo Installing FastQC...
  cd /usr/local/share
	curl -O http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.10.1.zip
	unzip fastqc_v0.10.1.zip
	chmod +x FastQC/fastqc


#fastx
echo Installing fatsx...
	cd /root
	curl -O http://hannonlab.cshl.edu/fastx_toolkit/libgtextutils-0.6.1.tar.bz2
	tar xjf libgtextutils-0.6.1.tar.bz2
	cd libgtextutils-0.6.1/
	./configure && make && make install
	cd /root
	curl -O http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit-0.0.13.2.tar.bz2
	tar xjf fastx_toolkit-0.0.13.2.tar.bz2
	cd fastx_toolkit-0.0.13.2/
	./configure && make && make install

#samtools
echo Installing samtools...
	cd /root
	curl -O -L http://sourceforge.net/projects/samtools/files/samtools/0.1.19/samtools-0.1.19.tar.bz2
	tar xvfj samtools-0.1.19.tar.bz2
	cd samtools-0.1.19
	make
	cp samtools /usr/local/bin
	cd misc/
	cp *.pl maq2sam-long maq2sam-short md5fa md5sum-lite wgsim /usr/local/bin/
	cd /mnt

#bwa (newest alpha version)
echo Installing bwa-0.7.5a...
	wget -O bwa-0.7.5.tar.bz2 http://sourceforge.net/projects/bio-bwa/files/bwa-0.7.5a.tar.bz2/download
	tar xvfj bwa-0.7.5.tar.bz2
	cd bwa-0.7.5a
	make
	cp bwa /usr/local/bin


#bwa (current version)
#cd /mnt
#curl -O -L http://sourceforge.net/projects/bio-bwa/files/bwa-0.7.4.tar.bz2
#tar xvfj bwa-0.7.4.tar.bz2
#cd bwa-0.7.4
#make
#cp bwa /usr/local/bin

#Download and extract BLAST nt databases (June 2013)
#echo Downloading BLAST nt databases (June 2013)...
	#mkdir -p /mnt/pipeline/bwa_transcriptome/blastdb
	#cd /mnt/pipeline/bwa_transcriptome/blastdb
	#curl -O ftp://ftp.ncbi.nih.gov/blast/db/nt.0[0-9].tar.gz
	#curl -O ftp://ftp.ncbi.nih.gov/blast/db/nt.1[0-4].tar.gz
	#for f in *.tar.gz; do
#		echo Extracting $f...
#		tar xvfz $f
#	done


#bedtools
echo Installing bedtools...
	cd /mnt
	wget https://bedtools.googlecode.com/files/BEDTools.v2.17.0.tar.gz
	tar zxvf BEDTools.v2.17.0.tar.gz
	cd bedtools-2.17.0/
	make
	cp bin/bedtools /usr/local/bin/

#Biopythons
	echo Installing Biopython
	curl -O http://biopython.org/DIST/biopython-1.61.tar.gz
	cd biopython-1.61/
	python setup.py install

echo Done installing sofware!
