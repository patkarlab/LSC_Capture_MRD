# Capture MRD for LSC project

This repository describes the workflow for analysing MRD samples sequenced using capture based assay.  
It requires three input files read1, read2 and read3 in compressed fastq format (.fastq.gz) per sample. read1 is assumed to contain a 8 bp UMI. read2 and read3 being the forward and reverse reads.  

## Usage
The following parameters need to be modified in the `params` section of the `nextflow.config` : 
- *genome* = Complete path to the human genome fasta file(hg19_all.fasta). Please ensure that the BWA index files (hg19_all.fasta.fai, hg19_all.fasta.amb, hg19_all.fasta.ann, hg19_all.fasta.bwt, hg19_all.fasta.pac, hg19_all.fasta.sa) are also present in the same genome folder. The assests folder currently contains placeholder genome and index files.

- *annovar_db* = Complete path to the humandb database folder for ANNOVAR (refer https://annovar.openbioinformatics.org/en/latest/user-guide/startup/ )

- *bedfile* = This file needs to be updated based on the probes used for the assay

- *outdir* = Location to write the output folder

## Running the pipeline
1. Transfer the sample input files `*.fastq.gz` inside the `sequences/` folder.

2. Modify the `samplesheet.csv`. The sample_ids, without the file extension, should be mentioned in samplesheet in the following format - <br>
sample1  
sample2  
sample3  
Please check for empty lines in the samplesheet before running the pipeline.

3. To execute the pipeline, use the following command
```bash
nextflow -C mrd_capture.config run mrd_capture.nf -entry MRD_PROBE -bg -profile docker -resume
```

## Output
Samplewise output folders are written to `Final_output/` folder.