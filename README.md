# bhf_consensus

Generate per-exon and concatenated nucleotide consensus sequences from an
aligned BAM, then translate the concatenated coding sequence to amino acids.

This repository contains:
- A Bash script that runs `samtools mpileup | ivar consensus` across BHF exons
  (BED intervals), concatenates exon consensus FASTAs, and translates with
  EMBOSS `transeq`.
- `bhf_consensus.yml` for creating a conda environment with dependencies.
- BED files in `./bed/` defining BHF exon coordinates for the *new Botryllus*
  genome available at: TBD

## Outputs

Given an input BAM `path/to/sample.bam`, the script writes:

- `./na_consensus/sample.all_exons.fa`  
  Concatenated nucleotide consensus across exons 1–3.

- `./aa_consensus/sample.all_exons.protein.fa`  
  Amino-acid translation of the concatenated nucleotide consensus.

(Intermediate per-exon FASTAs are created then removed; `*qual.txt*` files are
also removed.)

## Dependencies

- `samtools`
- `ivar`
- `transeq` (provided by the `emboss` package)

## Install (conda)

Create the environment from the provided YAML:

```bash
conda env create -f bhf_consensus.yml
conda activate bhf_consensus
```

## Usage

Run the script with a single argument: the BAM file.

```bash
bash ./bhf_consensus.sh path/to/HISeq-Sample_bb_Aligned.sortedByCoord.out.bam
```
