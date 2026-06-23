#!/usr/bin/env bash
set -euo pipefail

### INPUTS
FASTA="Homo_sapiens.GRCh38.dna.primary_assembly.fa"
GTF="Homo_sapiens.GRCh38.110.gtf"

OUTDIR="minigenome_arriba"
THREADS=8
PAD=100000   # window around genes (controls final size)

mkdir -p "$OUTDIR"

echo "=============================="
echo "Step 1: index FASTA"
echo "=============================="
samtools faidx "$FASTA"

echo "=============================="
echo "Step 2: define genes"
echo "=============================="

GENES=(
  AKAP9 ALK ATF1 BRAF BRD4 CD74 EML4 ETV1 ETV6
  EWSR1 FLI1 HOOK3 NTRK3 NUTM1 RET ROS1 TMPRSS2
)

echo "=============================="
echo "Step 3: build gene BED (FIXED)"
echo "=============================="

printf "%s\n" "${GENES[@]}" > "$OUTDIR/genes.tmp"

awk -F'\t' -v OFS='\t' -v pad="$PAD" '
BEGIN {
  while ((getline < "'$OUTDIR'/genes.tmp") > 0) g[$1]=1
}

$3=="gene" {
  if (match($9, /gene_name "([^"]+)"/, m)) {
    if (m[1] in g) {
      start=$4-pad; if (start<1) start=1;
      print $1, start, $5+pad, m[1]
    }
  }
}
' "$GTF" > "$OUTDIR/genes.bed"

rm -f "$OUTDIR/genes.tmp"

echo "=============================="
echo "Step 4: build compact FASTA (FIXED)"
echo "=============================="

> "$OUTDIR/minigenome.fa"

while read -r chr start end gene; do

  region="${chr}:${start}-${end}"
  echo "Extracting $gene -> $region"

  seq=$(samtools faidx "$FASTA" "$region" 2>/dev/null | tail -n +2 || true)

  if [[ -z "$seq" ]]; then
    echo "WARNING: skipping empty region $region"
    continue
  fi

  {
    echo ">$gene"
    printf "%s\n" "$seq" | fold -w 60
  } >> "$OUTDIR/minigenome.fa"

done < "$OUTDIR/genes.bed"

# HARD VALIDATION (important)
if [[ ! -s "$OUTDIR/minigenome.fa" ]]; then
  echo "ERROR: FASTA is empty — check BED extraction"
  exit 1
fi

samtools faidx "$OUTDIR/minigenome.fa"

echo "=============================="
echo "Fixing GTF (gene-name based, STAR-safe)"
echo "=============================="

awk -F'\t' -v OFS='\t' '
BEGIN {
  while ((getline < "'$OUTDIR'/genes.tmp") > 0) g[$1]=1
}

$3=="exon" {
  if (match($9, /gene_name "([^"]+)"/, m)) {
    if (m[1] in g) {
      # rewrite chromosome to match FASTA contig (gene name)
      $1 = m[1]
      print
    }
  }
}
' "$GTF" > "$OUTDIR/minigenome.gtf"

echo "=============================="
echo "Step 6: sanity check (CRITICAL)"
echo "=============================="

echo "FASTA size:"
du -h "$OUTDIR/minigenome.fa"

echo "Contigs:"
cut -f1 "$OUTDIR/minigenome.fa.fai"

echo "GTF features:"
cut -f3 "$OUTDIR/minigenome.gtf" | sort | uniq -c

echo "=============================="
echo "Step 7: STAR index (GitHub-safe settings)"
echo "=============================="

STAR \
  --runThreadN "$THREADS" \
  --runMode genomeGenerate \
  --genomeDir "$OUTDIR/star_index" \
  --genomeFastaFiles "$OUTDIR/minigenome.fa" \
  --sjdbGTFfile "$OUTDIR/minigenome.gtf" \
  --sjdbOverhang 149 \
  --genomeSAindexNbases 10 \
  --limitGenomeGenerateRAM 20000000000

echo "=============================="
echo "DONE"
echo "=============================="