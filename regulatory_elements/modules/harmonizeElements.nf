process harmonizeElements {

	input:
	path peak_list
	path chrom_sizes
	val summit_extend
	val out_dir
	val experiment_name

	publishDir "${out_dir}", mode: 'copy'

	output:
	path "${experiment_name}_harmonized_elements.bed.gz"

	"""

	> combined_extended_summits.bed

	peak_array=(${peak_list.join(' ')})
	for peak_file in "\${peak_array[@]}"; do
	zcat \${peak_file} \
	| awk 'BEGIN {FS = "\t"; OFS = "\t"};
	{summit = \$2 + \$10;
	print \$1,summit,(summit+1),\$4,\$8}' \
	| bedtools slop -g ${chrom_sizes} -b ${summit_extend} -i stdin \
	>> combined_extended_summits.bed

	done

	sort -k 1,1 -k 2,2n combined_extended_summits.bed \
	| bedtools cluster -i stdin \
	> clustered_extended_summits.bed

	prune_summits.py \
	clustered_extended_summits.bed \
	${experiment_name}_harmonized_elements.bed.gz

	"""

}
