# Bacterial Genome Assembly and Outbreak Analysis Workflow

## Overview

This Nextflow DSL2 workflow performs comprehensive bacterial genome assembly and outbreak analysis. It integrates various bioinformatics tools to process raw sequencing data, assemble genomes, assess quality, annotate genomes, and perform comparative genomics analyses.

## Workflow Steps

1. **Quality Control**
   - FastQC: Performs quality control checks on raw sequence data
   - MultiQC: Aggregates results from FastQC and other tools
   - Fastp: Performs quality control, adapter trimming, and filtering of raw reads
   - Filtlong: Filters and trims long reads

2. **Genome Assembly**
   - Unicycler: Hybrid assembler for bacterial genomes
   - Dragonflye: Long-read assembler for bacterial genomes
   - Shovill: Short-read assembler for bacterial genomes

3. **Assembly Quality Assessment**
   - QUAST: Evaluates genome assemblies
   - CheckM2: Assesses the quality and completeness of genome assemblies

4. **Genome Annotation**
   - Prokka: Rapid prokaryotic genome annotation

5. **Comparative Genomics**
   - Panaroo: Performs pan-genome analysis
   - Snippy: Rapid variant calling for bacterial genomes
   - Snippy-core: Finds core SNPs from multiple Snippy outputs
   - Gubbins: Detects recombination in bacterial genomes
   - SNP-sites: Extracts SNPs from a multi-FASTA alignment file
   - SNP-dists: Calculates a pairwise SNP distance matrix
   - IQ-TREE: Constructs phylogenetic trees

## Usage

```bash
nextflow run main.nf -profile <config_profile> --input <input_data> --reference <reference_genome>