#!/usr/bin/env Rscript
# SPDX-License-Identifier: MIT

args <- commandArgs(trailingOnly = FALSE)
file_arg <- "--file="
script_path <- sub(file_arg, "", args[grep(file_arg, args)])

if (length(script_path) != 1 || script_path == "") {
    stop("Unable to determine the script path from commandArgs().")
}

script_dir <- dirname(normalizePath(script_path))
reference_dir <- file.path(script_dir, "reference")
sumstats_dir <- file.path(script_dir, "..", "sumstats")

dir.create(reference_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(sumstats_dir, recursive = TRUE, showWarnings = FALSE)

writeLines(
    c(
        "1 rs1 0 101 A G",
        "1 rs2 0 102 C T"
    ),
    file.path(reference_dir, "chr1.1_toy.bim")
)

writeLines(
    c(
        "1 rs3 0 201 A C",
        "1 rs4 0 202 G T"
    ),
    file.path(reference_dir, "chr1.2_toy.bim")
)

lam <- c(1.3, 0.85)
LDsc <- c(1.1, 1.4)
V <- diag(2)
save(
    LDsc,
    lam,
    V,
    file = file.path(reference_dir, "chr1.1_toy.rda"),
    compress = "gzip"
)

lam <- c(1.25, 0.9)
LDsc <- c(1.2, 1.35)
V <- diag(2)
save(
    LDsc,
    lam,
    V,
    file = file.path(reference_dir, "chr1.2_toy.rda"),
    compress = "gzip"
)

nsnps.list <- list("1" = c(2, 2))
nsnps.list.imputed <- list("1" = c(2, 2))
save(
    nsnps.list.imputed,
    nsnps.list,
    file = file.path(reference_dir, "toy_snp_counter.RData"),
    compress = "gzip"
)

snps.list.imputed.vector <- c("rs1", "rs2", "rs3", "rs4")
save(
    snps.list.imputed.vector,
    file = file.path(reference_dir, "toy_snp_list.RData"),
    compress = "gzip"
)

trait1 <- data.frame(
    SNP = c("rs1", "rs2", "rs3", "rs4"),
    A1 = c("A", "C", "A", "G"),
    A2 = c("G", "T", "C", "T"),
    CHR = c(1, 1, 1, 1),
    POS = c(101, 102, 201, 202),
    RSID = c("rs1", "rs2", "rs3", "rs4"),
    EffectAllele = c("A", "C", "A", "G"),
    OtherAllele = c("G", "T", "C", "T"),
    N = c(10000, 10000, 10000, 10000),
    Z = c(0.5, -0.2, 0.4, -0.1)
)
write.table(
    trait1,
    file.path(sumstats_dir, "trait1_canonical.tsv"),
    sep = "\t",
    quote = FALSE,
    row.names = FALSE
)

trait2 <- data.frame(
    SNP = c("rs1", "rs2", "rs3", "rs4"),
    A1 = c("A", "C", "A", "G"),
    A2 = c("G", "T", "C", "T"),
    CHR = c(1, 1, 1, 1),
    POS = c(101, 102, 201, 202),
    RSID = c("rs1", "rs2", "rs3", "rs4"),
    EffectAllele = c("A", "C", "A", "G"),
    OtherAllele = c("G", "T", "C", "T"),
    N = c(12000, 12000, 12000, 12000),
    Z = c(0.3, -0.4, 0.2, -0.2)
)
write.table(
    trait2,
    file.path(sumstats_dir, "trait2_canonical.tsv"),
    sep = "\t",
    quote = FALSE,
    row.names = FALSE
)
