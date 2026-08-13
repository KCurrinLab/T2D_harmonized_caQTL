process getReproduciblePeaks {

	input:
	tuple val(sample_name_list), path(peak_list)
	val min_samples
	val out_dir

	publishDir "${out_dir}/reproducible_peaks/", mode: 'copy'

	output:
	path "*_peaks_reproducible.narrowPeak.gz", emit: peaks
	path "reproducible_peaks.bed.gz"

	"""

	> temp.bed

	sample_array=(${sample_name_list.join(' ')})
	peak_array=(${peak_list.join(' ')})
	
	for i in "\${!sample_array[@]}"; do
	s_name=\${sample_array[\$i]}
	peak_file=\${peak_array[\$i]}

	# bedtools 2.31.1 thinks 12 column bed files are in bed12 format, which is not what I want.
	# So we will use bed4 for merging
	zgrep -v "#chr" \${peak_file} \
	| awk -v s=\${s_name} 'BEGIN {FS = "\\t"; OFS = "\\t"};
	{print \$1,\$2,\$3,s}' \
	>> temp.bed
	done

	sort -k 1,1 -k 2,2n temp.bed \
	| mergeBed -i stdin -c 4 -o count_distinct,distinct \
	> union_peaks.bed

	awk -v n=${min_samples} '{if(\$4 >= n) {
	print \$0}}' \
	union_peaks.bed \
	| gzip -c > reproducible_peaks.bed.gz

	for i in "\${!sample_array[@]}"; do
	s_name=\${sample_array[\$i]}
	peak_file=\${peak_array[\$i]}

	intersectBed -u -a \${peak_file} -b reproducible_peaks.bed.gz \
	| gzip -c > \${s_name}_peaks_reproducible.narrowPeak.gz
	done

	"""

}
