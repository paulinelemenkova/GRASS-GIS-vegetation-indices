# GRASS GIS Vegetation Indices — Woodland Mapping and Deforestation in Central Angola

GRASS GIS shell-scripting workflow computing ten vegetation indices (NDVI, DVI, ARVI, EVI, GEMI, MSAVI2, NDWI, PVI, GARI, IPVI) from Landsat OLI/TIRS imagery to map woodlands and quantify deforestation over the Bié and Huambo plateaus of central Angola between 2013 and 2023. The pipeline covers radiometric calibration (DN to surface reflectance), QA-based cloud masking, per-index raster algebra via the i.vi module, univariate statistics, NDVI-threshold forest classification, bitemporal change detection and publication-quality cartographic export.

## Associated publication

Lemenkova, P. (2024). Mapping Woodlands in Angola, Tropical Africa: Calculation of Vegetation Indices From Remote Sensing Data. Agriculture and Forestry, 70(3), 185–202. DOI: 10.17707/AgricultForest.70.3.13

- Journal: http://www.agricultforest.ac.me/paper.php?id=3305
- HAL (open access): https://hal.science/hal-04714823v1
- SSRN: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4971605
- Code archive (Zenodo): https://doi.org/10.5281/zenodo.13862029

## Data

Landsat 8/9 OLI/TIRS Level-2 Surface Reflectance (L2SP), Path/Row 177/070, acquired 2013-07-12 and 2023-07-08, projected in WGS 84 / UTM zone 33S (EPSG:32733) at 30 m resolution.

## Usage

Start GRASS GIS 8.x in a mapset (EPSG:32733) with the Landsat bands imported, then run:

    bash GRASS_GIS_10_VI_script.sh

## Citation

    @article{Lemenkova2024AngolaVI,
      author  = {Polina Lemenkova},
      title   = {{Mapping Woodlands in Angola, Tropical Africa: Calculation of Vegetation Indices From Remote Sensing Data}},
      journal = {Agriculture and Forestry},
      volume  = {70},
      number  = {3},
      pages   = {185--202},
      year    = {2024},
      doi     = {10.17707/AgricultForest.70.3.13}
    }

## Author

Polina Lemenkova — ORCID 0000-0002-5759-1089
