#!/bin/bash

#RNAseq Pipeline NGS2013

#Usage: PIPELINE_RNAseq_group.sh <reference> <paired_end1.fq> <paired_end2.fq> <output_file_prefix>

#stop pipeline if arguments are not set
set -u

ref=$1 # reference genome/transcriptome
read1=$2 # left end read
read2=$3 # right end pair
out=$4  #output file

#This assumes that transcriptome is indexed

#bwa alignment 
echo BWA: aligning left paired end reads...
  bwa aln $ref $read1 > $out.1.sai
echo BWA: aligning right paired end reads...
	bwa aln $ref $read2 > $out.2.sai
echo BWA: Creating SAM files for paired end reads...
	bwa sampe $ref $out.1.sai $out.2.sai $read1 $read2 > $out.sam

#create bam, sort and index it

#standard way to create bam from sam:
# samtools view -Sb $out.sam > $out.bam

echo samtools: Indexing reference...
	samtools faidx $ref
echo samtools: Creating BAM files...
	samtools import $ref.fai $out.sam $out.unsorted.bam
echo samtools: Sorting BAM files...
	samtools sort $out.unsorted.bam $out
echo samtools: Indexing BAM files...
	samtools index $out.bam

unmapped=$out.unmapped.bam
mapped=$out.mapped.bam
  
#filter out unmapped reads
echo samtools: Filtering mapped and unmapped reads...
	samtools view -f 4 -b $out.bam > $unmapped
	samtools view -F 4 -b $out.bam > $mapped


#count number of reads of bam files
echo samtools: Counting mapped and unmapped reads...
	unmappedcounts=`samtools view -c $unmapped`
		echo The number of unmapped reads is $unmappedcounts
  
	mappedcounts=`samtools view -c $mapped`
		echo The number of mapped reads is $mappedcounts

  #Calculte percentage of mapped reads
  
	mappedpercentage=`echo "scale=3; ($mappedcounts/($unmappedcounts+$mappedcounts))*100" | bc`
		echo The alignment mapped $mappedpercentage% of the reads

#Create FASTA file from unmapped BAM file
	samtools view $unmapped | awk '{OFS="\t"; print ">"$1"\n"$10}' > $out.unmapped.fasta





