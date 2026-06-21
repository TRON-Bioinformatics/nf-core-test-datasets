#!/usr/bin/env bash
set -euo pipefail

FASTA="minigenome.fa"
OUTDIR="synthetic_reads"

mkdir -p "$OUTDIR"/{genes,fusions}

echo "====================================="
echo "Step 1: index FASTA"
echo "====================================="
samtools faidx "$FASTA"

echo "====================================="
echo "Step 2: define gene list (NO coordinates)"
echo "====================================="

GENES=(
  AKAP9 ALK ATF1 BRAF BRD4 CD74 EML4 ETV1 ETV6
  EWSR1 FLI1 HOOK3 NTRK3 NUTM1 RET ROS1 TMPRSS2
)

echo "====================================="
echo "Step 3: build normal gene transcripts"
echo "====================================="

for gene in "${GENES[@]}"; do
  seq=$(samtools faidx "$FASTA" "$gene" | tail -n +2)

  echo ">${gene}_normal" > "$OUTDIR/genes/${gene}.fa"
  echo "$seq" >> "$OUTDIR/genes/${gene}.fa"
done

cat "$OUTDIR"/genes/*.fa > "$OUTDIR/all_genes.fa"

echo "====================================="
echo "Step 4: build fusion transcripts"
echo "====================================="

FUSIONS=(
  "ALK EML4"
  "ROS1 CD74"
  "RET NTRK3"
  "BRAF ETV6"
  "EWSR1 FLI1"
  "TMPRSS2 ALK"
)

i=0
for pair in "${FUSIONS[@]}"; do
  g1=$(echo $pair | awk '{print $1}')
  g2=$(echo $pair | awk '{print $2}')

  seq1=$(samtools faidx "$FASTA" "$g1" | tail -n +2)
  seq2=$(samtools faidx "$FASTA" "$g2" | tail -n +2)

  mid1=$(( ${#seq1} / 2 ))
  mid2=$(( ${#seq2} / 3 ))

  fusion_seq="${seq1:0:$mid1}${seq2:$mid2}"

  echo ">fusion_${g1}_${g2}_${i}" > "$OUTDIR/fusions/fusion_${i}.fa"
  echo "$fusion_seq" >> "$OUTDIR/fusions/fusion_${i}.fa"

  i=$((i+1))
done

cat "$OUTDIR"/fusions/*.fa > "$OUTDIR/all_fusions.fa"

echo "====================================="
echo "Step 5: combine transcriptome"
echo "====================================="

cat "$OUTDIR/all_genes.fa" "$OUTDIR/all_fusions.fa" > "$OUTDIR/transcriptome.fa"

echo "====================================="
echo "Step 6: simulate reads"
echo "====================================="

art_illumina \
  -ss HS25 \
  -i "$OUTDIR/all_genes.fa" \
  -p -l 150 -f 30 -m 200 -s 10 -rs 42 \
  -o "$OUTDIR/normal_"

art_illumina \
  -ss HS25 \
  -i "$OUTDIR/all_fusions.fa" \
  -p -l 150 -f 5 -m 200 -s 10 -rs 42 \
  -o "$OUTDIR/fusion_"

echo "====================================="
echo "Step 7: merge reads"
echo "====================================="

cat "$OUTDIR/normal_1.fq" "$OUTDIR/fusion_1.fq" > "$OUTDIR/final_1.fq"
cat "$OUTDIR/normal_2.fq" "$OUTDIR/fusion_2.fq" > "$OUTDIR/final_2.fq"

gzip -f "$OUTDIR/final_1.fq"
gzip -f "$OUTDIR/final_2.fq"

echo "DONE"