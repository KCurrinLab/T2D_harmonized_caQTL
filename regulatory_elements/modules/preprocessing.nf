process filterBam {

	input:
	tuple val(sample_name), path(bam_file)
	path primary_nuclear_chr

	output:
	tuple val(sample_name), path("filtered_sorted.bam"), path("filtered_sorted.bam.bai")

	"""

	samtools view \
	-h -b -f 3 -F 4 -F 8 -F 256 -F 2048 -q 30 \
	--threads 9 \
	-L ${primary_nuclear_chr} \
	-o filtered.bam \
	${bam_file}

	# sort and index
	samtools sort --threads 9 -o filtered_sorted.bam \
	filtered.bam

	samtools index filtered_sorted.bam

	"""

}

process bamToBed {

	input:
	tuple val(sample_name), path(bam_file), path(bam_index)

	output:
	tuple val(sample_name), path("alignments.bed.gz")

	"""

	# Convert the bam file to bed and shift the read 5' ends to be the center of the Tn5 cut site.
	# Note that 4 was subtracted from the 5' end of - strand reads instead of 5 because the end coordinates of BED files are 1-based, not 0-based
	bamToBed -i ${bam_file} \
	| awk 'BEGIN {FS = "\t"};
	{if(\$6 == "+") {
	print \$1"\t"\$2+4"\t"\$3"\t"\$4"\t"\$5"\t"\$6}
	if(\$6 == "-") {
	print \$1"\t"\$2"\t"\$3-4"\t"\$4"\t"\$5"\t"\$6}}' \
	| gzip -c > alignments.bed.gz

	"""

}
