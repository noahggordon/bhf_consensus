#!/bin/bash
#
#Dependencies: transeq, ivar, samtools

# Check if BAM file argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <BAM file>"
    exit 1
fi

mkdir -p ./na_consensus


BAM_FILE=$1
OUTPUT_PREFIX="./na_consensus/$(basename "$BAM_FILE" .bam)"


# Define the BED files
BED_FILES=(
    "./bed/bhf_exon1.bed"
    "./bed/bhf_exon2.bed"
    "./bed/bhf_exon3.bed"
)

# Loop through the BED files and run the consensus command
for BED_FILE in "${BED_FILES[@]}"; do
    # Extract the prefix from the BED filename (just the exon number)
    EXON=$(basename "$BED_FILE" .bed | sed 's/bhf_exon//')
    
    # Run the samtools mpileup and ivar consensus command
    samtools mpileup -l "$BED_FILE" -d 0 "$BAM_FILE" | ivar consensus -m 4 -n N -q 20 -t 0 -p "${OUTPUT_PREFIX}.exon${EXON}"
done

# Generate consensus sequence from BAM alignment file
# samtools mpileup: creates pileup of bases at each position
#   -l "$BED_FILE" : only positions in BED file (restrict to regions)
#   -d 0           : no max depth limit (include all reads)
#   "$BAM_FILE"    : input alignment file
# | ivar consensus: calls consensus sequence from pileup
#   -m 4   : min depth to call consensus (<4 reads → ambiguous)
#   -n N   : use 'N' for ambiguous bases (low depth/quality)
#   -q 20  : min base quality (Phred ≥20, ~99% accuracy)
#   -t: min frequency threshold to call winner default 0 (off)
#   -p "${OUTPUT_PREFIX}.exon${EXON}" : output prefix (.fa/.qual)


# Concatenate all the consensus files into one
cat "${OUTPUT_PREFIX}.exon1.fa" "${OUTPUT_PREFIX}.exon2.fa" "${OUTPUT_PREFIX}.exon3.fa" > "${OUTPUT_PREFIX}.all_exons.fa"

# Clean up the temporary consensus files
rm "${OUTPUT_PREFIX}.exon1.fa" "${OUTPUT_PREFIX}.exon2.fa" "${OUTPUT_PREFIX}.exon3.fa"

rm ./na_consensus/*qual.txt*

echo "Consensus generation complete. Final file: ${OUTPUT_PREFIX}.all_exons.consensus.fasta"

mkdir -p ./aa_consensus

# Now, create a temporary file with only the 2nd, 4th, and 6th lines (sequences)
TEMP_FASTA="./aa_consensus/$(basename "$OUTPUT_PREFIX").temp.fa"

# Extract the 2nd, 4th, and 6th lines, and combine them into a single sequence
{
    # Extract the header (name) from the first line of the all_exons.fa
    echo ">$(head -n 1 ${OUTPUT_PREFIX}.all_exons.fa | sed 's/>//')"

    # Extract lines 2, 4, and 6 (sequences) and concatenate them into one sequence line
    sed -n '2p;4p;6p' ${OUTPUT_PREFIX}.all_exons.fa | tr -d '\n'
    echo
} > "$TEMP_FASTA"

echo "Temporary FASTA for translation created: $TEMP_FASTA"

# Translate the combined DNA sequence into protein using transeq
TRANSLATED_PROTEIN="${OUTPUT_PREFIX}.all_exons.protein.fa"
transeq -sequence "$TEMP_FASTA" -outseq "./aa_consensus/$(basename "$TRANSLATED_PROTEIN")"

rm "./aa_consensus/$(basename "$OUTPUT_PREFIX").temp.fa"

echo "Translation complete. Final protein sequence saved to: ./aa_consensus/$(basename "$TRANSLATED_PROTEIN")"
