nextflow.enable.dsl=2

include { filterBam; bamToBed } from './modules/preprocessing.nf'
include { callPeaks } from './modules/callPeaks.nf'
include { getNormalizedSignal } from './modules/getNormalizedSignal.nf'
include { addSignalToPeaks } from './modules/addSignalToPeaks.nf'
include { getAverageSignal } from './modules/getAverageSignal.nf'
include { getReproduciblePeaks } from './modules/getReproduciblePeaks.nf'
include { harmonizeElements } from './modules/harmonizeElements.nf'

if(params.containsKey("help")) {
	error "Usage:\nnextflow -C nextflow.config \\\nrun harmonize_regulatory_elements.nf \\\n--input_file <in_file> \\\n--out_dir <out_dir>\\\n--experiment_name <tissue_or_cellType_name>\nExiting"
}

if(!params.containsKey("out_dir")) {
	error "No output folder was provided.\nPlease rerun the pipeline using the commandline parameter '--out_dir' to specify your out folder.\nExiting"
}

if(!params.containsKey("input_file")) {
	error "No input file was provided.\nPlease rerun the pipeline using the commandline parameter '--input_file' to specify your input file that contains a tab-separated table with sample_name and BAM_file path.\nExiting"
}

if(!params.containsKey("experiment_name")) {
	error "No experiment name was provided.\nPlease rerun the pipeline using the commandline parameter '--experiment_name' to specify your experiment name, which should be cell type or tissue name.\nExiting"
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

workflow {

	main:
	filterBam(bam_ch,params.primary_nuclear_chr)
	bamToBed(filterBam.out)
	callPeaks(bamToBed.out,params.macs_genome,params.exclude_regions)
	getNormalizedSignal(bamToBed.out,params.chrom_sizes)

	addSignalToPeaks(callPeaks.out.join(getNormalizedSignal.out))

	if(params.output_signal) {
		averageSignal_in_ch = getNormalizedSignal.out.map { sample, file -> file }
		.collect()

		getAverageSignal(averageSignal_in_ch,params.out_dir,params.experiment_name)
		}

	if(params.get_reproducible_peaks == "yes") {
//		reproducible_in_ch = callPeaks.out.collect(flat: false)
//		.map { it.transpose() }

		reproducible_in_ch = addSignalToPeaks.out
		.toList()
		.map { list -> 
		def samples = list.collect { it[0] }
		def peaks = list.collect { it[1] }
		return tuple(samples, peaks)
		}

		getReproduciblePeaks(reproducible_in_ch,params.min_samples,params.out_dir)
		harmonizeElements(getReproduciblePeaks.out.peaks.collect(),params.chrom_sizes,params.summit_extend,params.out_dir,params.experiment_name)
	}

	else if(params.get_reproducible_peaks == "no") {
		harmonize_in_ch = addSignalToPeaks.out.map { sample, file -> file }
		.collect()

		harmonizeElements(harmonize_in_ch,params.chrom_sizes,params.summit_extend,params.out_dir,params.experiment_name)
	}

}
