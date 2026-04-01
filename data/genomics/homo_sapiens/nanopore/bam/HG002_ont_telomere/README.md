# HG002 ONT telomere test data

Small BAM containing 17 real ONT telomeric reads from GIAB HG002, for testing telomere analysis tools (e.g. telogator2).

- **Source**: [GIAB 2025.01 ONT release](https://ont-open-data.s3.amazonaws.com/giab_2025.01/basecalling/sup/HG002/PAW70337/calls.sorted.bam), SUP basecalling, R10.4.1 flowcell (PAW70337)
- **Regions**: Last 10 kb of chr1 (`chr1:248946422-248956422`) and chr2 (`chr2:242183529-242193529`)
- **Downsampled**: `samtools view -s 42.12` to ~17 reads
- **Size**: ~491 KB (BAM) + ~236 KB (BAI)
- **All reads contain TTAGGG telomere repeats**

## How to regenerate

Requires Docker and internet access:

```bash
IMAGE="community.wave.seqera.io/library/telseq_samtools_bamtools:0674b50fa5a173e1"
BAM="https://ont-open-data.s3.amazonaws.com/giab_2025.01/basecalling/sup/HG002/PAW70337/calls.sorted.bam"

docker run --rm -v "$(pwd):/out" "${IMAGE}" bash -c "
  samtools view -b '${BAM}' 'chr1:248946422-248956422' 'chr2:242183529-242193529' -o /tmp/tel_full.bam
  samtools index /tmp/tel_full.bam
  samtools view -s 42.12 -b /tmp/tel_full.bam -o /out/HG002_ont_tel_sub.bam
  samtools index /out/HG002_ont_tel_sub.bam
"
```
