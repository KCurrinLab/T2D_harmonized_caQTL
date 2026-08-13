process addSignalToPeaks {

	input:
	tuple val(sample_name), path(peaks), path(signal)

	output:
	tuple val(sample_name), path("${sample_name}_peaks_withMaxNormalizedSignal.bed.gz")

	"""

	# Use ucsctools bigWigAverageOverBed to get the maximum signal in each peak
	# bigWigAverageOverBed tries to parse some of the columns beyond the 4th column in the bed file, which I don't want it to do.
	# So I will make a bed4 file of the peaks.
	zcat ${peaks} \
	| awk 'BEGIN {FS = "\\t"; OFS = "\\t"};
	{print \$1,\$2,\$3,\$4}' \
	> peaks_bed4.bed

	bigWigAverageOverBed -minMax -tsv \
	${signal} peaks_bed4.bed signal_stats.txt

	# Merge max signal into the narrowPeak file
	addSignalMaxToPeaks.R ${peaks} \
	signal_stats.txt \
	${sample_name}_peaks_withMaxNormalizedSignal.bed

	gzip ${sample_name}_peaks_withMaxNormalizedSignal.bed

	"""

}
