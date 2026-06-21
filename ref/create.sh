#!/usr/bin/env bash
set -euo pipefail

GTF="Homo_sapiens.GRCh38.110.gtf"
FASTA="Homo_sapiens.GRCh38.dna.primary_assembly.fa"
THREADS=8
PAD=50000

cat > genes.txt <<EOF
AKAP9
ALK
ATF1
BRAF
BRD4
CD74
EML4
ETV1
ETV6
EWSR1
FLI1
HOOK3
NTRK3
NUTM1
RET
ROS1
TMPRSS2
EOF

echo "Step 1: extract gene coordinates..."

awk -F'\t' '
BEGIN{
    while((getline < "genes.txt") > 0) g[$1]=1
}
$3=="gene" {
    if(match($9,/gene_name "([^"]+)"/,m)) {
        if(m[1] in g)
            print $1"\t"$4"\t"$5"\t"m[1]
    }
}
' "$GTF" > genes.bed

echo "Step 2: add padding..."

awk -v pad="$PAD" '
BEGIN{OFS="\t"}
{
    s=$2-pad; if(s<1) s=1;
    e=$3+pad;
    print $1,s,e,$4
}
' genes.bed > genes.padded.bed

echo "Step 3: extract gene FASTA (IMPORTANT CHANGE)"

# --- NEW: gene-centric FASTA contigs ---
while read chr start end gene; do
    samtools faidx "$FASTA" "${chr}:${start}-${end}" \
        | sed "1s/.*/>${gene}/"
done < genes.padded.bed > mini_genome.fa

echo "Step 4: build coordinate map for GTF rebasing..."

awk '
BEGIN{OFS="\t"}
{
    gene=$4
    print gene,$1,$2,$3
}
' genes.padded.bed > interval_map.tsv

echo "Step 5: filter + rebase GTF to gene contigs"

awk -F'\t' '
BEGIN{
    OFS="\t"
    while((getline < "genes.txt") > 0) g[$1]=1

    while((getline < "interval_map.tsv") > 0){
        gene=$1
        chr[$1]=$2
        start[$1]=$3
    }
}
$3=="gene" || $3=="transcript" || $3=="exon" || $3=="CDS" {
    if(match($9,/gene_name "([^"]+)"/,m)){
        gene=m[1]
        if(!(gene in g)) next

        if($1 != chr[gene]) next

        # rebase coordinates into gene space
        $1 = gene
        $4 = $4 - start[gene]
        $5 = $5 - start[gene]

        if($4 < 1) next
        print
    }
}
' "$GTF" > mini_genome.gtf

echo "Step 6: sanity checks"

awk -F'\t' '{print NF}' mini_genome.gtf | sort -u
cut -f1 mini_genome.gtf | sort -u

echo "Step 7: STAR index"

STAR \
  --runThreadN "$THREADS" \
  --runMode genomeGenerate \
  --genomeDir star_index_mini \
  --genomeFastaFiles mini_genome.fa \
  --sjdbGTFfile mini_genome.gtf \
  --sjdbOverhang 149 \
  --genomeSAindexNbases 10

echo "Step 8: GFF3"

gffread mini_genome.gtf -o mini_genome.gff3

echo "Step 9: gffutils DB"

python - <<'PY'
import gffutils

gffutils.create_db(
    "mini_genome.gff3",
    "mini_genome.gff3.db",
    force=True,
    keep_order=True,
    merge_strategy="merge",
    sort_attribute_values=True
)
PY

echo "DONE (GitHub-safe)"