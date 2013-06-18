
#!/bin/bash

#stop pipeline if arguments are not set
set -u

ref=$1 # reference genome/ trancriptome
read1=$2 # left end read
read2=$3 # right end pair
out=$4  #output file
log=log.txt

#dmel-all-transcript-r5.51.fasta  $1
#OREf_SAMm_vg1_CTTGTA_L005_R1_001.fastq  $2
#OREf_SAMm_vg1_CTTGTA_L005_R2_001.fastq  $3
#vg_1  $4

#Make sure everything is installed
#FastQc
#cd /usr/local/share
#curl -O http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.10.1.zip
#unzip fastqc_v0.10.1.zip
#chmod +x FastQC/fastqc

#fastx
#cd /root
#curl -O http://hannonlab.cshl.edu/fastx_toolkit/libgtextutils-0.6.1.tar.bz2
#tar xjf libgtextutils-0.6.1.tar.bz2
#cd libgtextutils-0.6.1/
#./configure && make && make install

#cd /root
#curl -O http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit-0.0.13.2.tar.bz2
#tar xjf fastx_toolkit-0.0.13.2.tar.bz2
#cd fastx_toolkit-0.0.13.2/
#./configure && make && make install

#samtools
#cd /root
#curl -O -L http://sourceforge.net/projects/samtools/files/samtools/0.1.19/samtools-0.1.19.tar.bz2
#tar xvfj samtools-0.1.19.tar.bz2
#cd samtools-0.1.19
#make
#cp samtools /usr/local/bin
#cd misc/
#cp *.pl maq2sam-long maq2sam-short md5fa md5sum-lite wgsim /usr/local/bin/
#cd /mnt

#fastQC - quality control
#mkdir /root/Dropbox/fastqc_vg1
#/usr/local/share/FastQC/fastqc OREf_SAMm_vg1_CTTGTA_L005_R1* OREf_SAMm_vg1_CTTGTA_L005_R2* --outdir=/root/Dropbox/fastqc_vg1

#wget -O bwa-0.7.5.tar.bz2 http://sourceforge.net/projects/bio-bwa/files/bwa-0.7.5a.tar.bz2/download
#tar xvfj bwa-0.7.5.tar.bz2
#cd bwa-0.7.5
#make
#cp bwa /usr/local/bin


#bwa install
#cd /mnt
#curl -O -L http://sourceforge.net/projects/bio-bwa/files/bwa-0.7.4.tar.bz2
#tar xvfj bwa-0.7.4.tar.bz2
#cd bwa-0.7.4
#make
#cp bwa /usr/local/bin

mkdir -p /mnt/pipeline
cd /mnt/pipeline

#bwa install
mkdir -p bwa_transcriptome
cd bwa_transcriptome

#downloading drosophila transcriptome
#  curl -O -L ftp://ftp.flybase.net/releases/current/dmel_r5.51/fasta/dmel-all-transcript-r5.51.fasta.gz
#  gunzip dmel-all-transcript-r5.51.fasta.gz

#bwa indexing
echo BWA: indexing reference genome...
  bwa index $ref

#bwa alignment 
echo BWA: aligning left paired end reads...
echo BWA: aligning left paired end reads... >> $log
  bwa aln $ref $read1 > $out.1.sai
echo BWA: aligning right paired end reads...
echo BWA: aligning right paired end reads... >> $log
  bwa aln $ref $read2 > $out.2.sai
echo BWA: Creating SAM files for paired end reads...
echo BWA: Creating SAM files for paired end reads... >>$log
  bwa sampe $ref $out.1.sai $out.2.sai $read1 $read2 > $out.sam

unmapped=$out.unmapped.sam
mapped=$out.mapped.sam

#filter out unmapped reads
echo samtools: Filtering mapped and unmapped reads...
echo samtools: Filtering mapped and unmapped reads... >> $log
  samtools view -f -S 4 $out.sam > $unmapped
  samtools view -F -S 4 $out.sam > $mapped


#count number of reads of sam files
echo samtools: Filtering mapped and unmapped reads...
echo samtools: Filtering mapped and unmapped reads... >>$log
  unmappedcounts=`samtools view -c -S $unmapped`
  echo The number of unmapped reads is $unmappedcounts >> $log
  
  mappedcounts=`samtools view -c -S $mapped`
  echo The number of mapped reads is $mapped.count.txt >> $log

  #Calculte percentage of mapped reads and 
  
  echo "scale=3; ($mappedcounts/($unmappedcounts+$mappedcounts))*100" | bc > $mapped.percentage.txt

#create bam, sort and index it
echo samtools: Creating BAM files...
echo samtools: Creating BAM files... >>$log
  samtools import $ref.fai $mapped $out.unsorted.bam
echo samtools: Sorting BAM files...
echo samtools: Sorting BAM files... >> $log
  samtools sort $out.unsorted.bam $out
 echo samtools: Indexing BAM files...
 echo samtools: Indexing BAM files... >> $log
  samtools index $out.bam
  
#BLAST PIPELINE to try to align unmapped reads to other genomes on BLAST database

#Create FASTA file from BAM file
samtools view $out.bam | awk '{OFS="\t"; print ">"$1"\n"$10}' - > $out.fasta
  
