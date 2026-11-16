process convertGenotypes {

	input:
	val VCF_dir
	val VCF_glob
	path chrom_sizes
	val out_dir

	publishDir "${out_dir}", mode: 'copy', pattern: 'snp2h5.out'

	output:
	tuple path("haplotypes.h5"), path("snp_index.h5"), path("snp_tab.h5"), emit: geno
	path "snp2h5.out"

	script:
	"""

	snp2h5 \
	--chrom ${chrom_sizes} \
	--format vcf \
	--haplotype haplotypes.h5 \
	--snp_index snp_index.h5 \
	--snp_tab snp_tab.h5 \
	--geno_prob geno_probs.h5 \
	${VCF_dir}/${VCF_glob} \
	2> snp2h5.out

	"""

}