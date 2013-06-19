#!/bin/bash

# Usage: PREPAREFILES_RNAseq_group.sh <reference>

ref=$1

# index reference transcriptome
echo BWA: indexing reference transcriptome...
  bwa index $ref
	
	#Make annotation file from the reference transcriptome
echo Creating annotation file from the reference transcriptome
	python make_bed_from_fasta.py $ref > $ref.bed
