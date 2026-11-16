## Overview

This pipeline uses WASP to reduce allelic mapping bias. The pipeline outputs WASP-filtered BAM files that can be used for caQTL mapping.

Note that this pipeline requires the user to provide the following details about the initial alignment used for the BAM files:
- Name of the alignment executible (such as bowtie2 or bwa).
- Directory on your system where this alignment executible is stored.
- The prefix of the genome index files used by your aligner.
- The directory containing the genome index files on your system.
- The alignment parameters you used.

## Installation

### Clone the pipeline 
 Clone the pipeline using the below command:

 ```bash

 git clone git@github.com:KCurrinLab/T2D_harmonized_caQTL.git

```

### Build the apptainer image

This step needs to be performed inside the cloned github repository in order for nextflow to find the apptainer image. It should take 5-10 minutes.:

```bash
cd T2D_harmonized_caQTL/WASP/
apptainer build dependencies.sif dependencies.def
```

### Make a variable pointing to the pipeline folder

```bash

run_WASP="<path_where_github_repo_was_cloned>/T2D_harmonized_caQTL/WASP/"

```

### Important: Add your alignment command

Edit the script block  in the file "T2D_harmonized_caQTL/WASP/modules/mapReads.nf" to use the alignment command initially used to align your BAM files. Instructions are provided in the file comments.

## Run the pipeline

The examples below use slurm for job submission. Replace with the job scheduler on your system if needed:

```bash

sbatch -o run_pipeline.out \
--mem 4g --time 48:00:00 \
--wrap="nextflow -C ${run_WASP}/nextflow.config \
run ${run_WASP}/run_WASP.nf \
--input_file <input_sample_table> \
--out_dir <out_directory> \
--experiment_name <experiment_name> \
--VCF_dir <VCF_dir> \
--VCF_glob <VCF_glob> \
--aligner_name <aligner_name> \
--aligner_dir <aligner_dir> \
--genome_index_dir <genome_index_dir> \
--genome_index_prefix <genome_index_prefix>""

```

#### Required parameters:

- --input_file: A tab-separated file with two columns: sample_name and bam_file. The file should have a header with the names "sample_name" and "bam_file". The bam_file column should contain the full bam file path.
- --out_dir: The path of the output folder where files will be written.
- --experiment_name: The name of your experiment, such as the tissue or cell type name.
- --VCF_dir: The folder containing the VCF files on your system.
- --VCF_glob: A file glob pattern describing the VCF file names. For example, "chr*_filtered.vcf.gz". The glob pattern should be surrounded by quotes when it is passed as a commandline parameter to the pipeline. VCF files should be separated by chromosome.
- --aligner_name: The name of the aligner executible (bowtie2 or bwa).
- --aligner_dir: The folder containing the alignment executible on your system.
- --genome_index_dir: The folder containing the genome index files for your aligner.
- --genome_index_prefix: The prefix of the alignment genome index files.
