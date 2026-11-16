nextflow.enable.dsl=2

include { filterBam } from './modules/filterBam.nf'
include { convertGenotypes } from './modules/convertGenotypes.nf'
include { getReadsToRemap } from './modules/getReadsToRemap.nf'
include { mapReads } from './modules/mapReads.nf'
include { filterRemappedReads } from './modules/filterRemappedReads.nf'

workflow {

	println "Aligner directory: ${params.aligner_dir}\naligner_name: ${params.aligner_name}"

	if(params.containsKey("help")) {
		error "Usage:\nnextflow -C nextflow.config \\\nrun run_WASP2.nf \\\n--input_file <in_file> \\\n--VCF_dir <VCF_dir> \\\n--VCF_glob < VCF_glob> \\\n--out_dir <out_dir>\nExiting"
	}

	if(!params.containsKey("out_dir")) {
		error "No output folder was provided.\nPlease rerun the pipeline using the commandline parameter '--out_dir' to specify your out folder.\nExiting"
	}

	if(!params.containsKey("input_file")) {
		error "No input file was provided.\nPlease rerun the pipeline using the commandline parameter '--input_file' to specify your input file that contains a tab-separated table with sample_name and BAM_file path.\nExiting"
	}

	println "\nNextflow pipeline script: ${workflow.scriptName}\n"
	println "\nFull pipeline script path: ${workflow.scriptFile}\n"
	println "\nConfiguration file: ${workflow.configFiles}\n"
	println "\nPipeline script launch directory: ${workflow.launchDir}\n"
	println "Full pipeline commandline run\n(Note that commandline parameters override parameters in the configuration files):\n${workflow.commandLine}\n\n\n"

	// The input file should be a tab-separated table with two columns.
	// 1. Sample name and 2. BAM file path.
	bam_ch = Channel.fromPath(params.input_file)
		.splitCsv(header: true, sep: "\t")
		.map{row -> tuple(row.sample_name, file(row.bam_file))}

	filterBam(bam_ch,params.primary_nuclear_chr,params.out_dir)
	convertGenotypes(params.VCF_dir,params.VCF_glob,params.chrom_sizes,params.out_dir)
	getReadsToRemap(filterBam.out.bam,convertGenotypes.out.geno,params.out_dir)
	mapReads(getReadsToRemap.out.sample_name,getReadsToRemap.out.r1_fastq,getReadsToRemap.out.r2_fastq,params.aligner_dir,params.aligner_name,params.genome_index_dir,params.genome_index_prefix)
	filterRemappedReads(mapReads.out,getReadsToRemap.out.bam_to_remap,getReadsToRemap.out.bam_not_overlapping_geno,params.out_dir,params.experiment_name)

}

