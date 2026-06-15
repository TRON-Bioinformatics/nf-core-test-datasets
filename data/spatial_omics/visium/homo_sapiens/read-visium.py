#!/usr/bin/env python3

import spatialdata_io

# Create two sample names for modules requiring multiple sdata inputs
samples = [
    'CytAssist_11mm_FFPE_Human_Glioblastoma_2',
    'CytAssist_11mm_FFPE_Human_Glioblastoma_2.2'
]

for sample_id in samples:

    # Sample ID must only contain alphanumerics, underscores and dashes
    sample_id_clean = "".join(
        filter(lambda x: x.isalnum() or x in ["_", "-"], sample_id)
    )

    sdata = spatialdata_io.visium(
        path='outs',
        counts_file='raw_feature_bc_matrix.h5',
        dataset_id=sample_id_clean
    )

    # Rename table to include sample ID
    sdata.tables[f"{sample_id_clean}_table"] = sdata.tables["table"]
    del sdata.tables["table"]

    sdata.write(f'{sample_id}.zarr')
