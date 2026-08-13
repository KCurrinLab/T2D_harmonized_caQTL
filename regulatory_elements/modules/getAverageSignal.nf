process getAverageSignal {

	input:
	path bw_list
	val out_dir
	val experiment_name

	publishDir "${out_dir}", mode: 'copy'

	output:
	path "${experiment_name}_averageNormalizedSignal.bw"

	"""

	bigwigAverage --bigwigs ${bw_list.join(' ')} \
	--binSize 20 \
	--outFileName ${experiment_name}_averageNormalizedSignal.bw \
	--outFileFormat bigwig

	"""

}
