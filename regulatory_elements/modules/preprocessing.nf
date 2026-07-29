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

	bamToBed -i ${bam_file} \
	| gzip -c > alignments.bed.gz

	"""

}
