## Overview

This pipeline generates a BED file of harmonized regulatory element coordinates across a set of samples or across a set of tissues or cell types. The steps of the pipeline are:
- Filter the input BAM files
- Convert BAM files to BED files prior to peak calling
- Call peaks using MACS3
- (optionally) Identify peaks that are present in a minimum number of samples.
- Harmonize regulatory element coordinates.

## Installation

### Clone the pipeline 
 Clone the pipeline using the below command:

 ```bash

 git clone git@github.com:KCurrinLab/T2D_harmonized_caQTL.git

```

### Build the apptainer image

This step needs to be performed inside the cloned github repository in order for nextflow to find the apptainer image. It should take 5-10 minutes.:

```bash
cd T2D_harmonized_caQTL/regulatory_elements/
apptainer build dependencies.sif dependencies.def
```

### Make a variable pointing to the pipeline folder

```bash

harmonize_RE="<path_where_github_repo_was_cloned>/T2D_harmonized_caQTL/regulatory_elements/"

```

## Running the pipeline

### Running with the reproducible peaks step

The examples below use slurm for job submission. Replace with the job scheduler on your system if needed:

```bash

sbatch -o run_pipeline.out \
--mem 4g --time 24:00:00 \
--wrap="nextflow -C ${harmonize_RE}/nextflow.config \
run ${harmonize_RE}/harmonize_regulatory_elements.nf \
--input_file <input_sample_table> \
--out_dir <out_directory> \
--experiment_name 'experiment_name' \
--min_samples <min_samples>"

```

### Running without the reproducible peak step

```bash

sbatch -o run_pipeline.out \
--mem 4g --time 24:00:00 \
--wrap="nextflow -C ${harmonize_RE}/nextflow.config \
run ${harmonize_RE}/harmonize_regulatory_elements.nf \
--input_file <input_sample_table> \
--out_dir <out_directory> \
--experiment_name 'experiment_name' \
--get_reproducible_peaks 'no'"

```

#### Required parameters:

- --input_file: A tab-separated file with two columns: sample_name and bam_file. The file should have a header with the names "sample_name" and "bam_file". The bam_file column should contain the full bam file path.
- --out_dir: The path of the output folder where files will be written.
- --experiment_name: The name of your experiment, such as the tissue or cell type name.

#### Optional parameters:

- --get_reproducible_peaks: Whether to run the step to get peaks present in a minimum number of samples. Possible values are "yes" (default) and "no".
- --min_samples: The minimum number of samples a peak must be present in when using the --get_reproducible_peaks step. The default is 3.
- --summit_extend: The number of basepairs summits will be extend by in each direction before summit pruning. Default: 150.
- --genome: Default "hg38".
- --exclude_regions: A set of problematic regions for genomic assays. Peaks overlapping these regions will be removed. Default: ${projectDir}/files/ENCFF356LFX.bed.gz
- --chrom_sizes: File with sizes of each chromosome. Default: ${projectDir}/files/hg38.chrom.sizes
- --primary_nuclear_chr: BED file with the coordinates of primary nuclear chromosomes (chrs 1-22, X, Y). Only alignments in these regions will be used for peak calling. Default: ${projectDir}/files/hg38_primary_nuclear_chr.bed
- --macs_genome: Which genome macs should use. Default: hs

## Commands used to retrieve genome files

These commands do not need to be run by the user. The resulting files are packaged with this pipeline. The commands are tracked here for reproducibility. 

These commands were run in the folder:
T2D_harmonized_caQTL/regulatory_elements/files/

```bash
#Download ENCODE exclusion regions:
wget https://www.encodeproject.org/files/ENCFF356LFX/@@download/ENCFF356LFX.bed.gz

#Download hg38 chromosome sizes:
wget https://hgdownload.soe.ucsc.edu/goldenpath/hg38/bigZips/latest/hg38.chrom.sizes

#Make a bed file of primary nuclear chromosomes
/bin/bash makeBedFile_primaryNuclearChr.sh \
hg38.chrom.sizes \
hg38_primary_nuclear_chr.bed

```
