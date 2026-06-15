# HDL Toy Test Dataset

These files are synthetic toy fixtures for HDL module testing in the companion
`nf-core/modules` work for `nf-core/modules#10912`. They are intended to exercise
[HDL](https://github.com/zhenin/HDL) inputs in tests, not to provide a
scientific LD reference panel or redistributed upstream reference bundle.

## Layout

- `reference/`: toy HDL LD reference chunks and metadata sidecars
- `../sumstats/`: canonical toy summary-statistics tables aligned to the toy SNPs

## Regeneration

From this directory:

```bash
Rscript generate_toy_hdl_data.R
```

From the root of the `nf-core/test-datasets` worktree:

```bash
Rscript data/genomics/homo_sapiens/popgen/hdl/generate_toy_hdl_data.R
```

## R Objects

The `.bim` sidecars, both canonical `sumstats/*.tsv` files, and the R binary
payloads are all generated locally by `generate_toy_hdl_data.R` from fully
synthetic constants in this directory.

- `reference/chr1.1_toy.rda` and `reference/chr1.2_toy.rda` each contain
  synthetic `LDsc`, `lam`, and `V` objects for one toy HDL chunk.
- `reference/toy_snp_counter.RData` contains `nsnps.list` and
  `nsnps.list.imputed`, each as a named one-element list with the toy chunk SNP
  counts.
- `reference/toy_snp_list.RData` contains `snps.list.imputed.vector`, the four
  synthetic SNP IDs shared by the toy fixtures.
- `../sumstats/trait1_canonical.tsv` and `../sumstats/trait2_canonical.tsv` are
  tiny canonical summary-statistics tables keyed to those synthetic SNP IDs.
