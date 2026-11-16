process filterBam {

	input:
	tuple val(sample_name), path(bam_file)
	path primary_nuclear_chr
	val out_dir

	publishDir "${out_dir}", mode: 'copy', pattern: 'alignment_filter_report*txt'


	output:
	tuple val(sample_name), path("filtered_sorted.bam"), path("filtered_sorted.bam.bai"), emit: bam
	path "alignment_filter_report_${sample_name}.txt"

	script:
	"""

	samtools view \
	-h -b -f 3 -F 4 -F 8 -F 256 -F 1024 -F 2048 -q 30 \
	--threads 9 \
	-L ${primary_nuclear_chr} \
	-o filtered.bam \
	${bam_file}

	# sort and index
	samtools sort --threads 9 -o filtered_sorted.bam \
	filtered.bam

	samtools index filtered_sorted.bam

	# Count the number of alignments removed by each exclusion filter (except -q)
	echo -e "filter\tnumber_alignments_removed" \
	> alignment_filter_report_${sample_name}.txt

	num_mappedPaired=\$(samtools view -c -F 3 ${bam_file})
	echo -e "not_mapped_paired\t\${num_mappedPaired}" \
	>> alignment_filter_report_${sample_name}.txt

	num_unmapped=\$(samtools view -c -f 4 ${bam_file})
	echo -e "unmapped\t\${num_unmapped}" \
	>> alignment_filter_report_${sample_name}.txt

	num_mateUnmapped=\$(samtools view -c -f 8 ${bam_file})
	echo -e "mate_unmapped\t\${num_mateUnmapped}" \
	>> alignment_filter_report_${sample_name}.txt

	num_notPrimaryAlignment=\$(samtools view -c -f 256 ${bam_file})
	echo -e "not_primary_alignment\t\${num_notPrimaryAlignment}" \
	>> alignment_filter_report_${sample_name}.txt

	num_duplicate=\$(samtools view -c -f 1024 ${bam_file})
	echo -e "duplicate\t\${num_duplicate}" \
	>> alignment_filter_report_${sample_name}.txt

	num_secondaryAlignment=\$(samtools view -c -f 2048 ${bam_file})
	echo -e "secondary_alignment\t\${num_secondaryAlignment}" \
	>> alignment_filter_report_${sample_name}.txt

	"""

}

