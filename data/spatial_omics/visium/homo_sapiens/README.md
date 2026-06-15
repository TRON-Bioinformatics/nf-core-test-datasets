# SpatialData from Visium

This test data is originally taken from the Space Ranger test data from the
[spatialvi branch](https://github.com/nf-core/test-datasets/tree/spatialvi) of
this repository, where you can find the details on how it was downloaded and
subset.

```bash
wget https://raw.githubusercontent.com/nf-core/test-datasets/spatialvi/testdata/human-brain-cancer-11-mm-capture-area-ffpe-2-standard_v2_ffpe_cytassist/outs.tar.gz
tar -xvf outs.tar.gz
```

The extracted data was subsequently processed using the `read-visium.py` Python
script included in this directory (using `spatialdata-io` version `0.6.0`).
Finally, as the Zarr format is a directory, it was archived and compressed:

```bash
tar -czvf CytAssist_11mm_FFPE_Human_Glioblastoma_2.zarr.tar.gz CytAssist_11mm_FFPE_Human_Glioblastoma_2.zarr
tar -czvf CytAssist_11mm_FFPE_Human_Glioblastoma_2.2.zarr.tar.gz CytAssist_11mm_FFPE_Human_Glioblastoma_2.2.zarr
```

This means that any testing will need to run the `UNTAR` module before any
actual testing can begin. The original `out.tar.gz` is around 43 MB in size,
while the final archives are around 17 MB.
