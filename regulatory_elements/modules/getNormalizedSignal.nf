process getNormalizedSignal {

	input:
	tuple val(sample_name), path(alignment_bed)
	path chrom_sizes

	output:
	tuple val(sample_name), path("${sample_name}_normalizedSignal.bw")
	
	"""

	# Subset the chrom sizes file to primary nuclear chr so that bedtools genocov does not compute coverage in these regions
	grep -E '^chr[0-9]\\s|^chr[0-9][0-9]\\s|^chrX\\s|^chrY\\s' \
	${chrom_sizes} \
	| sort -k 1,1 \
	> chrom_sizes_nuclear.txt

	# Calculate reciprocal of reads per million
	RPM_r=\$(zcat ${alignment_bed} \
	| wc -l \
	| awk '{print 1000000/\$1}')

	# The 5' ends of reads have been centered with respect to the Tn5 binding site.
	# The 5' ends of reads will be extended by 100bp on either end to smooth the signal.
	zcat ${alignment_bed} \
	| awk 'BEGIN {FS = "\t"; OFS = "\t"};
	{if(\$6 == "+") {
	print \$1,\$2,\$2+1}
	if(\$6 == "-") {
	print \$1,\$3-1,\$3}}' \
	| slopBed -b 100 -g chrom_sizes_nuclear.txt -i stdin \
	| sort -k 1,1 -k 2,2n \
	> shifted_sorted.bed

	# Make the bedgraph file and scale for reads per million
	bedtools genomecov -bga -scale \${RPM_r} -i shifted_sorted.bed \
	-g chrom_sizes_nuclear.txt \
	| sort -k 1,1 -k 2,2n \
	> normalizedSignal.bdg

	bedGraphToBigWig \
	normalizedSignal.bdg \
	chrom_sizes_nuclear.txt \
	${sample_name}_normalizedSignal.bw

	"""

}
