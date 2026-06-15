# Toy Population-Genetics Summary Statistics

These files are tiny synthetic GWAS-style summary-statistics tables intended for
module testing. They are generated from fixed constants by the companion HDL
fixture generator at `../hdl/generate_toy_hdl_data.R`.

## Layout

- `trait1_canonical.tsv`: synthetic canonical summary statistics for trait 1
- `trait2_canonical.tsv`: synthetic canonical summary statistics for trait 2

## Regeneration

From the `hdl/` directory:

```bash
Rscript generate_toy_hdl_data.R
```

From the root of the `nf-core/test-datasets` worktree:

```bash
Rscript data/genomics/homo_sapiens/popgen/hdl/generate_toy_hdl_data.R
```

## Notes

These tables are not HDL-specific at the file-format level. They are kept under
`popgen/sumstats/` so they can be reused by modules that consume small
GWAS-style tabular inputs, while the HDL reference panel assets remain grouped
under `popgen/hdl/reference/`.
