#!/bin/bash

# Check if the user provided a BAM file as argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <bam_file>"
    exit 1
fi

bam_file="$1"

# Check if the specified file exists and is a BAM file
if [ ! -e "$bam_file" ] || [[ "$bam_file" != *.bam ]]; then
    echo "Error: '$bam_file' is not a valid BAM file."
    exit 1
fi

# Print the name of the file
echo "File: $bam_file"

# Get the total number of mapped reads
total_mapped=$(samtools view -c -F 4 "$bam_file")
echo "Total Mapped Reads: $total_mapped"

# Get the number of properly paired reads
properly_paired=$(samtools view -c -f 2 "$bam_file")
echo "Properly Paired Reads: $properly_paired"

# Count properly paired reads within the BED file regions
bed_file="./bhf_exons.bed"
if [ ! -e "$bed_file" ]; then
    echo "Error: BED file '$bed_file' not found."
    exit 1
fi

# Total mapped reads in BED regions
total_mapped_in_bed=$(samtools view -c -L "$bed_file" "$bam_file")
echo "Total Mapped Reads in BED Regions: $total_mapped_in_bed"

properly_paired_in_bed=$(samtools view -c -f 2 -L "$bed_file" "$bam_file")
echo "Properly Paired Reads in BED Regions: $properly_paired_in_bed"

# Print a separator
echo "------------------------------------"


