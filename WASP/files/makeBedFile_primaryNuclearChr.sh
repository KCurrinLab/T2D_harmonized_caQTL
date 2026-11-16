# This works for human.
# Other species may need a different script.

chrom_sizes=${1}
out_fn=${2}

grep -E 'chr[0-9]\s|chr[0-9][0-9]\s|chrX\s|chrY\s' ${chrom_sizes} \
| awk '{print $1"\t"0"\t"$2}' \
> ${out_fn}
