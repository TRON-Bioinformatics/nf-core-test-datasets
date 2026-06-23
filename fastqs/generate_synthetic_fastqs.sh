#!/usr/bin/env bash
set -euo pipefail

FASTA="minigenome.fa"
OUTDIR="synthetic_reads"

mkdir -p "$OUTDIR"/{genes,fusions}

echo "== Index FASTA =="
samtools faidx "$FASTA"

GENES=(
  AKAP9 ALK ATF1 BRAF BRD4 CD74 EML4 ETV1 ETV6
  EWSR1 FLI1 HOOK3 NTRK3 NUTM1 RET ROS1 TMPRSS2
)

extract_gene() {
  samtools faidx "$FASTA" "$1" 2>/dev/null \
    | tail -n +2 \
    | tr -d '\n'
}

echo "== Build breakpoint fusion fragments =="

FUSIONS=(
  "ALK EML4"
  "ROS1 CD74"
  "RET NTRK3"
  "BRAF ETV6"
  "EWSR1 FLI1"
  "TMPRSS2 ALK"
)

rm -f "$OUTDIR"/fusions/*.fa

i=0

for pair in "${FUSIONS[@]}"; do

  g1=$(echo "$pair" | awk '{print $1}')
  g2=$(echo "$pair" | awk '{print $2}')

  seq1=$(extract_gene "$g1")
  seq2=$(extract_gene "$g2")

  [[ -z "$seq1" || -z "$seq2" ]] && continue

  bp1=$(( ${#seq1} / 2 ))
  bp2=$(( ${#seq2} / 3 ))

  # 200 bp on each side of breakpoint
  left_start=$(( bp1 - 200 ))
  (( left_start < 0 )) && left_start=0

  left_seq="${seq1:$left_start:200}"
  right_seq="${seq2:$bp2:200}"

  fusion_fragment="${left_seq}${right_seq}"

  {
    echo ">fusion_${g1}_${g2}_${i}"
    echo "$fusion_fragment"
  } > "$OUTDIR/fusions/fusion_${i}.fa"

  ((i+=1))
done

cat "$OUTDIR"/fusions/*.fa > "$OUTDIR/all_fusions.fa"

echo "== Simulate normal background reads =="

# Keep background modest.
# With a 4.4 Mb minigenome this produces ~40-60 MB gzipped FASTQs.

art_illumina \
  -ss HS25 \
  -i "$FASTA" \
  -p \
  -l 150 \
  -f 50 \
  -m 250 \
  -s 25 \
  -rs 42 \
  -o "$OUTDIR/normal_"

echo "== Simulate breakpoint-spanning fusion reads =="

# High coverage on tiny breakpoint fragments
# Generates many split/chimeric reads without huge files

art_illumina \
  -ss HS25 \
  -i "$OUTDIR/all_fusions.fa" \
  -p \
  -l 150 \
  -f 600 \
  -m 250 \
  -s 25 \
  -rs 43 \
  -o "$OUTDIR/fusion_"

echo "== Merge =="

cat \
  "$OUTDIR/normal_1.fq" \
  "$OUTDIR/fusion_1.fq" \
  > "$OUTDIR/test_sample_R1.fastq"

cat \
  "$OUTDIR/normal_2.fq" \
  "$OUTDIR/fusion_2.fq" \
  > "$OUTDIR/test_sample_R2.fastq"

echo "== Compress =="

gzip -f "$OUTDIR/test_sample_R1.fastq"
gzip -f "$OUTDIR/test_sample_R2.fastq"

echo
echo "Final sizes:"
du -h "$OUTDIR/test_sample_R1.fastq.gz"
du -h "$OUTDIR/test_sample_R2.fastq.gz"

echo
echo "Read counts:"
echo -n "R1: "
zcat "$OUTDIR/test_sample_R1.fastq.gz" | awk 'END{print NR/4}'

echo -n "R2: "
zcat "$OUTDIR/test_sample_R2.fastq.gz" | awk 'END{print NR/4}'

echo
echo "Done"