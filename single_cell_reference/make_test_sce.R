#!/usr/bin/env Rscript
# Generates a minimal SingleCellExperiment RDS for use in module tests.
# Run once: Rscript make_test_sce.R
suppressPackageStartupMessages({
    library(SingleCellExperiment)
})

set.seed(42)
genes   <- paste0("ENSG0000000", seq_len(20))
cells   <- paste0("cell_", seq_len(30))
tissues <- rep(c("liver", "lung", "kidney"), each = 10)
samples <- rep(paste0("donor", seq_len(3)), 10)

counts_mat <- matrix(
    rpois(length(genes) * length(cells), lambda = 5),
    nrow = length(genes),
    ncol = length(cells),
    dimnames = list(genes, cells)
)

sce <- SingleCellExperiment(
    assays  = list(counts = counts_mat),
    colData = DataFrame(tissue = tissues, sample_id = samples)
)

saveRDS(sce, "test_sc_reference.rds")
message("Written: test_sc_reference.rds")
