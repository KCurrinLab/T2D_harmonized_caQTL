process callPeaks {

	input:
	tuple val(sample_name), path(alignment_bed)
	val macs_genome
	path exclude_regions

	output:
	tuple val(sample_name), path("${sample_name}_macs2_peaks_excludeRegionsFiltered.narrowPeak.gz")
	
	/*
	 --keep-dup all is used because picard was used to remove duplicates.
	 For paired-end reads, macs2 can't tell duplicates as well as picard.

	 For peak calling purposes, we use each end of a read pair separately (if paired-end) because these represent two independent Tn5 cutting events.
	 So single-end and paired-end are handled the same.
	 The alignment bam file was converted to bed before use with MACS2 because MACS2 will pick only one end of a paired-end fragment if a paired-end bam file is provided.
	 Both ends are used by macs2 when a bed file is provided.

	The --call-summits option attempts to find multiple summits within a peak.

	*/
	"""

	macs3 callpeak -t ${alignment_bed} \
	-g ${macs_genome} \
	-q 0.05 --nomodel --shift -100 --extsize 200 \
	--call-summits \
	--keep-dup all --name ${sample_name}_macs2

	# Remove ENCODE exclusion regions
	intersectBed -v -a ${sample_name}_macs2_peaks.narrowPeak \
	-b ${exclude_regions} \
	| gzip -c > ${sample_name}_macs2_peaks_excludeRegionsFiltered.narrowPeak.gz

	# Retain summits overlapping peaks not overlapping excluded regions.
	# This approach is better than just removing summits overlapping excluded regions because the edge of a peak can overlap an excluded region but not the summit.
	#intersectBed -u -a ${sample_name}_macs2_summits.bed \
	#-b ${sample_name}_macs2_peaks_excludeRegionsFiltered.narrowPeak \
	#> ${sample_name}_macs2_summits_excludeRegionsFiltered.bed

	"""

}
