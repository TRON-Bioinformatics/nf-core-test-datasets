# S. cerevisiae RNA-seq BAM test data

## Source

BAM files sourced from the `rnaseq` branch of this repository (`testdata/GSE110004/`), originally from GEO series [GSE110004](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE110004) (Rap1 degradation in S. cerevisiae).

## Files

- `test.paired_end.sorted.bam`: Coordinate-sorted paired-end BAM, WT replicate 2, ~1.9K reads (~85KB). Downsampled from WT_REP2.sorted.bam with `samtools view -s 42.02`.
- `test.paired_end.sorted.bam.bai`: BAM index.
- `test.single_end.sorted.bam`: Coordinate-sorted single-end BAM, RAP1_UNINDUCED replicate 1, ~2K reads (~88KB). Downsampled from RAP1_UNINDUCED_REP1.sorted.bam with `samtools view -s 42.04`.
- `test.single_end.sorted.bam.bai`: BAM index.

## Downsampling

```bash
samtools view -s 42.02 -b WT_REP2.sorted.bam | samtools sort -o test.paired_end.sorted.bam
samtools view -s 42.04 -b RAP1_UNINDUCED_REP1.sorted.bam | samtools sort -o test.single_end.sorted.bam
samtools index test.paired_end.sorted.bam
samtools index test.single_end.sorted.bam
```

The seed (42) and fractions (0.02 / 0.04) were chosen to produce files under 100KB while retaining enough reads for QC tools (dupradar, qualimap, RSeQC) to produce output.

## Purpose

Used for testing the `bam_qc_rnaseq` subworkflow in nf-core/modules.
