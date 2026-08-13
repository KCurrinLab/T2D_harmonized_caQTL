#!/usr/bin/env python

import sys
import gzip
import collections

def main():

	in_fn = sys.argv[1]
	out_fn = sys.argv[2]

	current_cluster_id = None
	current_cluster_records = []

	with open(in_fn, "r") as in_file, \
	gzip.open(out_fn, "wt") as out_file:

		for line in in_file:
			if line[0] == "#": continue

			data = line.strip().split("\t")

			chrom = data[0]
			start = int(data[1])
			end = int(data[2])
			name = data[3]
			max_signal = data[4]
			# Max normalized signal in the peak is now used for peak tie breaker instead of minusLog10PVal
			# -log10 pval, so higher is more significant
			# Keep it as a string so no weird conversions happen in the output file.
			# I will sort on the float of the pval later
			#pval = data[4]
			# Cluster ID from bedtools cluster
			cluster_id = data[-1]

			# New cluster encountered -> process the completed cluster
			if current_cluster_id is not None and cluster_id != current_cluster_id:
				final_records = prune_cluster(current_cluster_records)
				for f in final_records:
					f_str = str.join("\t",[str(i) for i in f])
					out_file.write(f"{f_str}\n")
				current_cluster_records = []

			current_cluster_id = cluster_id
			current_cluster_records.append((chrom, start, end, name, max_signal))

		# Process the final cluster
		if current_cluster_records:
			final_records = prune_cluster(current_cluster_records)
			for f in final_records:
				f_str = str.join("\t",[str(i) for i in f])
				out_file.write(f"{f_str}\n")

	return

def prune_cluster(cluster_records):
	"""
	Greedy elimination of overlapping intervals within a single cluster.
	cluster_records: list of tuples (chrom, start, end, name, max signal)
	"""

	# Sort regions in this cluster by max normalized signal (descending order)
	cluster_records.sort(key=lambda x: float(x[4]), reverse=True)

	kept_regions = []

	for candidate in cluster_records:
		c_chrom, c_start, c_end, c_name, c_signal = candidate

		# Check if candidate overlaps with any already selected (stronger) region
		overlaps = False
		for k_chrom, k_start, k_end, _, _ in kept_regions:
			# Overlap condition: start1 < end2 and start2 < end1
			if (c_start < k_end) and (k_start < c_end):
				overlaps = True
				break  # Prune candidate: it overlaps a stronger peak

		if not overlaps:
			kept_regions.append(candidate)

	return kept_regions

if __name__ == "__main__":
	main()
